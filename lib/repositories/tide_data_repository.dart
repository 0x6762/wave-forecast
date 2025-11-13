import '../models/tide_data.dart';

/// Abstract interface for tide data providers
/// This allows easy swapping between different API providers (Stormglass, NOAA, WorldTides, etc.)
abstract class TideDataRepository {
  /// Fetches tide data for a given location
  /// 
  /// [latitude] - Location latitude
  /// [longitude] - Location longitude
  /// [days] - Number of days to forecast (default: 7)
  /// [cacheRadiusKm] - Optional cache radius for proximity searches
  /// 
  /// Returns [TideData] with hourly points and extremes, or null if unavailable
  Future<TideData?> getTideData({
    required double latitude,
    required double longitude,
    int days = 7,
    double? cacheRadiusKm,
  });

  /// Clear all cached tide data
  Future<void> clearCache();

  /// Dispose of any resources (HTTP clients, etc.)
  void dispose();
}

