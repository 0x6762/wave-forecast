import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/surf_conditions.dart';
import '../models/surf_forecast.dart';
import 'weather_repository.dart';

/// Open-Meteo API implementation
/// Documentation: https://open-meteo.com/en/docs
class OpenMeteoRepository implements WeatherRepository {
  final http.Client _client;
  
  static const String _marineApiUrl = 'https://marine-api.open-meteo.com/v1/marine';
  static const String _weatherApiUrl = 'https://api.open-meteo.com/v1/forecast';

  OpenMeteoRepository({http.Client? client}) 
      : _client = client ?? http.Client();

  @override
  Future<SurfForecast> getSurfForecast({
    required double latitude,
    required double longitude,
    int days = 7,
  }) async {
    try {
      print('🌊 Fetching surf forecast for: $latitude, $longitude');
      
      // Fetch marine data (waves) and weather data in parallel
      final results = await Future.wait([
        _fetchMarineData(latitude, longitude, days),
        _fetchWeatherData(latitude, longitude, days),
      ]);

      final marineData = results[0];
      final weatherData = results[1];
      
      print('✅ Marine data received');
      print('✅ Weather data received');

      // Get location name
      String locationName = await getLocationName(
        latitude: latitude,
        longitude: longitude,
      );
      
      print('📍 Location: $locationName');

      // Combine data into SurfConditions
      final conditions = _combineData(marineData, weatherData);
      
      print('✅ Combined ${conditions.length} hourly conditions');

      return SurfForecast(
        locationName: locationName,
        latitude: latitude,
        longitude: longitude,
        hourlyConditions: conditions,
        fetchedAt: DateTime.now(),
      );
    } catch (e, stackTrace) {
      print('❌ Error fetching surf forecast: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to fetch surf forecast: $e');
    }
  }

  Future<Map<String, dynamic>> _fetchMarineData(
    double latitude,
    double longitude,
    int days,
  ) async {
    final url = Uri.parse(_marineApiUrl).replace(queryParameters: {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'hourly': [
        'wave_height',
        'wave_direction',
        'wave_period',
        'swell_wave_height',
        'swell_wave_direction',
        'swell_wave_period',
      ].join(','),
      'forecast_days': days.toString(),
      'timezone': 'auto',
    });

    print('🌊 Marine API URL: $url');
    final response = await _client.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Marine API response received');
      return data;
    } else {
      print('❌ Marine API failed: ${response.statusCode}');
      print('Response: ${response.body}');
      throw Exception('Marine API request failed: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Map<String, dynamic>> _fetchWeatherData(
    double latitude,
    double longitude,
    int days,
  ) async {
    final url = Uri.parse(_weatherApiUrl).replace(queryParameters: {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'hourly': [
        'temperature_2m',
        'wind_speed_10m',
        'wind_direction_10m',
        'weather_code',
      ].join(','),
      'forecast_days': days.toString(),
      'timezone': 'auto',
    });

    print('☀️ Weather API URL: $url');
    final response = await _client.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Weather API response received');
      return data;
    } else {
      print('❌ Weather API failed: ${response.statusCode}');
      print('Response: ${response.body}');
      throw Exception('Weather API request failed: ${response.statusCode} - ${response.body}');
    }
  }

  @override
  Future<String> getLocationName({
    required double latitude,
    required double longitude,
  }) async {
    // Use OpenStreetMap Nominatim (excellent for coastal areas and beaches)
    final osmName = await _getLocationFromOSM(latitude, longitude);
    if (osmName != null) return osmName;
    
    // Fallback to coordinates if geocoding fails
    return '${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)}';
  }

  Future<String?> _getLocationFromOSM(double latitude, double longitude) async {
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse').replace(queryParameters: {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'format': 'json',
        'zoom': '10', // City/town level
        'addressdetails': '1',
      });

      print('🗺️ OSM Nominatim API URL: $url');
      
      final response = await _client.get(
        url,
        headers: {
          'User-Agent': 'WaveForecastApp/1.0', // Required by OSM
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🗺️ OSM response: $data');
        
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          // Try to build a meaningful location name
          final parts = <String>[];
          
          // Check for various location types in order of preference
          final beach = address['beach'] as String?;
          final suburb = address['suburb'] as String?;
          final neighbourhood = address['neighbourhood'] as String?;
          final city = address['city'] as String?;
          final town = address['town'] as String?;
          final village = address['village'] as String?;
          final municipality = address['municipality'] as String?;
          final state = address['state'] as String?;
          final country = address['country'] as String?;
          
          print('🏖️ Beach: $beach, Suburb: $suburb, City: $city, State: $state, Country: $country');
          
          if (beach != null && beach.isNotEmpty) {
            parts.add(beach);
          } else if (suburb != null && suburb.isNotEmpty) {
            parts.add(suburb);
          } else if (neighbourhood != null && neighbourhood.isNotEmpty) {
            parts.add(neighbourhood);
          } else if (city != null && city.isNotEmpty) {
            parts.add(city);
          } else if (town != null && town.isNotEmpty) {
            parts.add(town);
          } else if (village != null && village.isNotEmpty) {
            parts.add(village);
          } else if (municipality != null && municipality.isNotEmpty) {
            parts.add(municipality);
          }
          
          if (state != null && state.isNotEmpty) parts.add(state);
          if (country != null && country.isNotEmpty) parts.add(country);
          
          if (parts.isNotEmpty) {
            final locationName = parts.join(', ');
            print('✅ OSM location: $locationName');
            return locationName;
          }
        }
      } else {
        print('⚠️ OSM API returned: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ OSM geocoding error: $e');
    }
    
    return null;
  }

  List<SurfConditions> _combineData(
    Map<String, dynamic> marineData,
    Map<String, dynamic> weatherData,
  ) {
    final List<SurfConditions> conditions = [];

    final marineHourly = marineData['hourly'] as Map<String, dynamic>;
    final weatherHourly = weatherData['hourly'] as Map<String, dynamic>;

    final times = (marineHourly['time'] as List);
    final waveHeights = (marineHourly['wave_height'] as List);
    final wavePeriods = (marineHourly['wave_period'] as List);
    final waveDirections = (marineHourly['wave_direction'] as List);
    
    final temperatures = (weatherHourly['temperature_2m'] as List);
    final windSpeeds = (weatherHourly['wind_speed_10m'] as List);
    final windDirections = (weatherHourly['wind_direction_10m'] as List);
    final weatherCodes = (weatherHourly['weather_code'] as List);

    for (int i = 0; i < times.length; i++) {
      conditions.add(SurfConditions(
        timestamp: DateTime.parse(times[i].toString()),
        waveHeight: _toDouble(waveHeights[i]),
        wavePeriod: _toDouble(wavePeriods[i]),
        waveDirection: _toDouble(waveDirections[i]),
        windSpeed: _toDouble(windSpeeds[i]),
        windDirection: _toDouble(windDirections[i]),
        waterTemperature: 0.0, // Open-Meteo marine API doesn't provide this in free tier
        airTemperature: _toDouble(temperatures[i]),
        weatherDescription: _getWeatherDescription(_toInt(weatherCodes[i])),
      ));
    }

    return conditions;
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  String _getWeatherDescription(int code) {
    // WMO Weather interpretation codes
    switch (code) {
      case 0:
        return 'Clear sky';
      case 1:
        return 'Mainly clear';
      case 2:
        return 'Partly cloudy';
      case 3:
        return 'Overcast';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 80:
      case 81:
      case 82:
        return 'Rain showers';
      case 95:
        return 'Thunderstorm';
      case 96:
      case 99:
        return 'Thunderstorm with hail';
      default:
        return 'Unknown';
    }
  }

  void dispose() {
    _client.close();
  }
}

