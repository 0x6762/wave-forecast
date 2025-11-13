import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_cache_database.g.dart';

/// Generic cache table for storing location-based data
/// Can be used for tides, weather, or any other cached API responses
class CachedData extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // Type of cached data (e.g., 'tide', 'weather', 'forecast')
  TextColumn get dataType => text()();
  
  // Unique identifier for this cache entry (e.g., station ID, location key)
  TextColumn get key => text()();
  
  // Location data for proximity searches
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  
  // Cached data as JSON
  TextColumn get dataJson => text()();
  
  // Metadata
  DateTimeColumn get fetchedAt => dateTime()();
  DateTimeColumn get validUntil => dateTime()();
  
  // Optional: Additional metadata
  TextColumn get metadata => text().nullable()();
}

@DriftDatabase(tables: [CachedData])
class AppCacheDatabase extends _$AppCacheDatabase {
  AppCacheDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  /// Find cached data by exact key
  Future<CachedDataData?> findByKey(String dataType, String key) async {
    final query = select(cachedData)
      ..where((t) => t.dataType.equals(dataType) & t.key.equals(key));
    
    final results = await query.get();
    if (results.isEmpty) return null;
    
    final entry = results.first;
    if (entry.validUntil.isBefore(DateTime.now())) {
      // Expired, remove it
      await _deleteCachedEntry(entry.id);
      return null;
    }
    
    return entry;
  }

  /// Find cached data within a radius (in kilometers)
  /// Returns the closest valid entry within the radius
  Future<CachedDataData?> findNearby({
    required String dataType,
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    final query = select(cachedData)
      ..where((t) => t.dataType.equals(dataType));
    
    final results = await query.get();
    final now = DateTime.now();
    
    CachedDataData? closest;
    double closestDistance = double.infinity;
    
    for (final entry in results) {
      // Skip expired entries
      if (entry.validUntil.isBefore(now)) {
        _deleteCachedEntry(entry.id);
        continue;
      }
      
      final distance = _haversineDistance(
        latitude,
        longitude,
        entry.latitude,
        entry.longitude,
      );
      
      if (distance <= radiusKm && distance < closestDistance) {
        closest = entry;
        closestDistance = distance;
      }
    }
    
    return closest;
  }

  /// Save or update cached data
  Future<int> saveCache({
    required String dataType,
    required String key,
    required double latitude,
    required double longitude,
    required Map<String, dynamic> data,
    required DateTime validUntil,
    String? metadata,
  }) async {
    final entry = CachedDataCompanion(
      dataType: Value(dataType),
      key: Value(key),
      latitude: Value(latitude),
      longitude: Value(longitude),
      dataJson: Value(jsonEncode(data)),
      fetchedAt: Value(DateTime.now()),
      validUntil: Value(validUntil),
      metadata: Value(metadata),
    );

    return await into(cachedData).insertOnConflictUpdate(entry);
  }

  /// Delete a specific cache entry
  Future<int> _deleteCachedEntry(int id) async {
    return await (delete(cachedData)..where((t) => t.id.equals(id))).go();
  }

  /// Clear all expired cache entries
  Future<int> clearExpiredCache() async {
    return await (delete(cachedData)
          ..where((t) => t.validUntil.isSmallerThan(Variable(DateTime.now()))))
        .go();
  }

  /// Clear all cache entries of a specific type
  Future<int> clearCacheByType(String dataType) async {
    return await (delete(cachedData)..where((t) => t.dataType.equals(dataType)))
        .go();
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    final allEntries = await select(cachedData).get();
    final now = DateTime.now();
    
    final validEntries = allEntries.where((e) => e.validUntil.isAfter(now));
    final expiredEntries = allEntries.where((e) => e.validUntil.isBefore(now));
    
    final typeStats = <String, int>{};
    for (final entry in validEntries) {
      typeStats[entry.dataType] = (typeStats[entry.dataType] ?? 0) + 1;
    }
    
    return {
      'total_entries': allEntries.length,
      'valid_entries': validEntries.length,
      'expired_entries': expiredEntries.length,
      'types': typeStats,
    };
  }

  /// Calculate distance between two points using Haversine formula
  /// Returns distance in kilometers
  double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
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
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_cache.sqlite'));
    
    return driftDatabase(
      name: file.path,
      // Enable foreign keys and other optimizations
      native: DriftNativeOptions(
        shareAcrossIsolates: true,
      ),
    );
  });
}

