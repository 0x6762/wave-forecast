/// Application-wide constants and configuration values
///
/// Centralizes all magic numbers, URLs, and configuration to make
/// the app easier to maintain and configure.
class AppConstants {
  // Prevent instantiation
  AppConstants._();

  // =============================================================================
  // API URLs
  // =============================================================================

  /// Open-Meteo Marine API for wave data
  static const String marineApiUrl =
      'https://marine-api.open-meteo.com/v1/marine';

  /// Open-Meteo Weather API for weather conditions
  static const String weatherApiUrl = 'https://api.open-meteo.com/v1/forecast';

  /// Stormglass Tide API base URL
  static const String stormglassTideApiUrl =
      'https://api.stormglass.io/v2/tide';

  /// OpenStreetMap Nominatim for geocoding
  static const String osmGeocodingUrl = 'https://nominatim.openstreetmap.org';

  // =============================================================================
  // Cache Configuration
  // =============================================================================

  /// Default cache radius in kilometers
  /// Data within this radius from a previous request will be reused
  static const double defaultCacheRadiusKm = 25.0;

  /// Default cache duration for tide data
  /// Cached tide data is considered valid for this period
  static const Duration tideCacheDuration = Duration(days: 7);

  /// Cache type identifier for tide data
  static const String tideCacheType = 'tide';

  // =============================================================================
  // Forecast Configuration
  // =============================================================================

  /// Default number of forecast days
  static const int defaultForecastDays = 7;

  /// Number of hourly conditions to show in the "Next Hours" section
  static const int hourlyForecastDisplayCount = 12;

  // =============================================================================
  // Location Search
  // =============================================================================

  /// Maximum number of location search results
  static const int maxLocationSearchResults = 10;

  /// Geocoding zoom level (10 = city/town level)
  static const String geocodingZoomLevel = '10';

  // =============================================================================
  // App Metadata
  // =============================================================================

  /// User-Agent string for API requests (required by some services like OSM)
  static const String appUserAgent = 'WaveForecastApp/1.0';
}
