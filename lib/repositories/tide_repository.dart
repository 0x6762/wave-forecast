import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/tide_data.dart';
import '../database/app_cache_database.dart';
import 'tide_data_repository.dart';

/// Stormglass API implementation for tide data
/// Documentation: https://stormglass.io/tide-api
class StormglassTideRepository implements TideDataRepository {
  final http.Client _client;
  final AppCacheDatabase _db;
  final String? _apiKey;
  
  // Default cache settings
  static const String _cacheType = 'tide';
  static const double _defaultCacheRadiusKm = 25.0; // Reuse data within 25km (generous for most coastlines)
  static const Duration _defaultCacheDuration = Duration(days: 7); // Tide forecasts valid for 7 days
  
  static const String _baseUrl = 'https://api.stormglass.io/v2/tide';

  StormglassTideRepository({
    http.Client? client,
    required AppCacheDatabase database,
    String? apiKey,
  })  : _client = client ?? http.Client(),
        _db = database,
        _apiKey = apiKey;

  @override
  Future<TideData?> getTideData({
    required double latitude,
    required double longitude,
    int days = 7,
    double? cacheRadiusKm,
  }) async {
    // If no API key, return null
    if (_apiKey == null || _apiKey.isEmpty) {
      print('⚠️ No Stormglass API key provided - tide data unavailable');
      return null;
    }

    final radius = cacheRadiusKm ?? _defaultCacheRadiusKm;

    // Check cache first
    try {
      final cached = await _db.findNearby(
        dataType: _cacheType,
        latitude: latitude,
        longitude: longitude,
        radiusKm: radius,
      );

      if (cached != null) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          cached.latitude,
          cached.longitude,
        );
        
        print('✅ Tide cache HIT! Using data from ${distance.toStringAsFixed(1)}km away');
        print('   Cache valid until: ${cached.validUntil}');
        
        final data = jsonDecode(cached.dataJson) as Map<String, dynamic>;
        return TideData.fromJson(data);
      }
    } catch (e) {
      print('⚠️ Error checking tide cache: $e');
    }

    // Cache miss - fetch from API
    print('🌊 Tide cache MISS - fetching from Stormglass API...');
    return await _fetchFromApi(latitude, longitude, days);
  }

  /// Fetch tide data from Stormglass API
  Future<TideData?> _fetchFromApi(
    double latitude,
    double longitude,
    int days,
  ) async {
    try {
      // Request tide extremes (high/low tides) for the forecast period
      final now = DateTime.now();
      final end = now.add(Duration(days: days));
      
      final url = Uri.parse('$_baseUrl/extremes/point').replace(
        queryParameters: {
          'lat': latitude.toString(),
          'lng': longitude.toString(),
          'start': now.toIso8601String(),
          'end': end.toIso8601String(),
        },
      );

      print('🌊 Stormglass API URL: $url');
      
      final response = await _client.get(
        url,
        headers: {
          'Authorization': _apiKey ?? '',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final tideData = _parseTideResponse(json, latitude, longitude);
        
        print('✅ Tide data received for ${tideData.stationName}');
        print('   Station: ${tideData.distanceFromRequest.toStringAsFixed(1)}km away');
        print('   Extremes: ${tideData.extremes.length}');

        // Cache the response
        await _cacheData(tideData);
        
        return tideData;
      } else {
        print('❌ Stormglass API error: ${response.statusCode}');
        print('   Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching tide data: $e');
      return null;
    }
  }

  /// Parse Stormglass API response into TideData
  TideData _parseTideResponse(
    Map<String, dynamic> json,
    double requestLat,
    double requestLon,
  ) {
    // Parse extremes (high/low tides) - convert to local time
    final extremesList = json['data'] as List;
    final extremes = extremesList.map((e) {
      final timestamp = DateTime.parse(e['time'] as String).toLocal(); // Convert to local time
      final height = (e['height'] as num).toDouble();
      final type = e['type'] as String;
      
      return TideExtreme(
        timestamp: timestamp,
        height: height,
        type: type == 'high' ? TideType.high : TideType.low,
      );
    }).toList();

    // Get station metadata
    final meta = json['meta'] as Map<String, dynamic>?;
    final stationLat = meta?['lat'] as num? ?? requestLat;
    final stationLon = meta?['lng'] as num? ?? requestLon;
    final stationName = meta?['station']?['name'] as String? ?? 'Unknown Station';
    
    final distance = _calculateDistance(
      requestLat,
      requestLon,
      stationLat.toDouble(),
      stationLon.toDouble(),
    );

    return TideData(
      stationId: meta?['station']?['source'] as String? ?? 'unknown',
      stationName: stationName,
      latitude: stationLat.toDouble(),
      longitude: stationLon.toDouble(),
      distanceFromRequest: distance,
      extremes: extremes,
      fetchedAt: DateTime.now(),
    );
  }

  /// Cache tide data for future use
  Future<void> _cacheData(TideData data) async {
    try {
      final validUntil = DateTime.now().add(_defaultCacheDuration);
      
      await _db.saveCache(
        dataType: _cacheType,
        key: data.stationId,
        latitude: data.latitude,
        longitude: data.longitude,
        data: data.toJson(),
        validUntil: validUntil,
        metadata: 'distance: ${data.distanceFromRequest.toStringAsFixed(1)}km',
      );
      
      print('💾 Cached tide data for ${data.stationName}');
    } catch (e) {
      print('⚠️ Failed to cache tide data: $e');
    }
  }

  /// Calculate distance between two points (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;
    
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }

  @override
  Future<void> clearCache() async {
    await _db.clearCacheByType(_cacheType);
    print('🗑️ Cleared tide cache');
  }

  @override
  void dispose() {
    _client.close();
  }
}

