import '../models/surf_forecast.dart';
import '../models/location_search_result.dart';

/// Abstract interface for weather/surf data providers
/// This allows easy swapping between different API providers (Open-Meteo, Stormglass, etc.)
abstract class WeatherRepository {
  /// Fetches surf forecast for a given location
  /// 
  /// [latitude] - Location latitude
  /// [longitude] - Location longitude
  /// [days] - Number of days to forecast (default: 7)
  /// 
  /// Returns a [SurfForecast] with hourly conditions
  /// Throws an exception if the request fails
  Future<SurfForecast> getSurfForecast({
    required double latitude,
    required double longitude,
    int days = 7,
  });

  /// Optional: Get location name from coordinates (reverse geocoding)
  /// Returns a human-readable location name
  Future<String> getLocationName({
    required double latitude,
    required double longitude,
  });

  /// Search for locations by name
  /// Returns a list of matching locations with coordinates
  Future<List<LocationSearchResult>> searchLocations(String query);
}

