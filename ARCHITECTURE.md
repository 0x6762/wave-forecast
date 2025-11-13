# Wave Forecast - Architecture Documentation

## Overview

This app uses a clean architecture with the **Repository Pattern** to allow easy swapping between different weather/surf API providers.

## Architecture Components

### 1. Models (`lib/models/`)
Data classes that represent surf conditions, independent of any API provider.

- **`SurfConditions`** - Represents weather/surf conditions at a specific time
  - Wave height, period, direction
  - Wind speed and direction
  - Air/water temperature
  - Weather description
  - Tide height and direction (optional)
  - Helper methods for surf quality assessment

- **`SurfForecast`** - Collection of surf conditions over time
  - Location information
  - List of hourly conditions
  - Optional tide data
  - Helper methods to filter by date

- **`TideData`** - Tide information for a location
  - Tide station details
  - Hourly tide points
  - High/low tide extremes
  - Helper methods (getNextHighTide, isRising, etc.)

### 2. Repositories (`lib/repositories/`)

#### Weather Data Repository

**Abstract Interface: `WeatherRepository`**
```dart
abstract class WeatherRepository {
  Future<SurfForecast> getSurfForecast({
    required double latitude,
    required double longitude,
    int days = 7,
  });
  
  Future<String> getLocationName({
    required double latitude,
    required double longitude,
  });
}
```

**Implementation: `OpenMeteoRepository`**
- Implements the `WeatherRepository` interface
- Handles API calls to Open-Meteo's marine and weather endpoints
- Integrates tide data from TideDataRepository
- Transforms API responses into our domain models

#### Tide Data Repository

**Abstract Interface: `TideDataRepository`**
```dart
abstract class TideDataRepository {
  Future<TideData?> getTideData({
    required double latitude,
    required double longitude,
    int days = 7,
    double? cacheRadiusKm,
  });
  
  Future<void> clearCache();
  void dispose();
}
```

**Implementation: `StormglassTideRepository`**
- Implements the `TideDataRepository` interface
- Fetches tide data from Stormglass API
- Smart proximity-based caching (reuses data within 25km)
- Persistent storage via Drift database

### 3. Database Layer (`lib/database/`)

**`AppCacheDatabase`** - Generic caching system using Drift
- Stores location-based data with proximity search
- Extensible schema supports multiple data types (tide, weather, etc.)
- Automatic expiration management
- Haversine distance calculations for nearby cache lookup

See [`.cursor/rules/tide-integration.mdc`](.cursor/rules/tide-integration.mdc) for complete caching details.

### 4. Dependency Injection

The app uses **Provider** for dependency injection in `main.dart`:

```dart
MultiProvider(
  providers: [
    Provider<AppCacheDatabase>.value(value: database),
    Provider<TideDataRepository>.value(value: tideRepository),
    Provider<WeatherRepository>(
      create: (_) => OpenMeteoRepository(tideRepository: tideRepository),
    ),
  ],
  child: MaterialApp(...),
)
```

To use repositories anywhere in your app:
```dart
final repository = Provider.of<WeatherRepository>(context, listen: false);
final forecast = await repository.getSurfForecast(
  latitude: -33.865143,
  longitude: 151.209900,
);
```

## How to Switch API Providers

Both weather and tide data follow the same repository pattern for easy provider swapping.

### Example: Switching Tide Provider

**Step 1: Create a new repository implementation**

```dart
// lib/repositories/noaa_tide_repository.dart
import 'tide_data_repository.dart';
import '../models/tide_data.dart';
import '../database/app_cache_database.dart';

class NOAATideRepository implements TideDataRepository {
  @override
  Future<TideData?> getTideData({
    required double latitude,
    required double longitude,
    int days = 7,
    double? cacheRadiusKm,
  }) async {
    // Your NOAA API implementation
    // Transform their data into TideData model
  }

  @override
  Future<void> clearCache() async { /* ... */ }
  
  @override
  void dispose() { /* ... */ }
}
```

**Step 2: Update main.dart**

Simply replace `StormglassTideRepository()` with your new implementation:

```dart
final tideRepository = NOAATideRepository(  // Changed this line only!
  database: database,
  apiKey: 'NOAA_KEY',
);
```

That's it! The rest of your app continues to work without any changes.

### Example: Switching Weather Provider

Follow the same pattern for weather data - implement `WeatherRepository` and update `main.dart`.

## Current API: Open-Meteo

**Documentation:** https://open-meteo.com/en/docs

**Endpoints used:**
- Marine API: `https://marine-api.open-meteo.com/v1/marine`
  - Wave height, direction, period
  - Swell data
  
- Weather API: `https://api.open-meteo.com/v1/forecast`
  - Temperature
  - Wind speed and direction
  - Weather codes

- Geocoding API: `https://geocoding-api.open-meteo.com/v1/reverse`
  - Location names from coordinates

**Benefits:**
- ✅ Free and open source
- ✅ No API key required
- ✅ Global coverage
- ✅ High resolution forecasts
- ✅ Reasonable rate limits

## Current APIs

### Weather/Surf: Open-Meteo
**Documentation:** https://open-meteo.com/en/docs

**Endpoints:**
- Marine API: Wave height, direction, period, swell data
- Weather API: Temperature, wind, weather codes

**Benefits:**
- ✅ Free and open source, no API key required
- ✅ Global coverage with high resolution forecasts

### Tide: Stormglass
**Documentation:** https://stormglass.io/tide-api

**Endpoints:**
- Tide API: High/low tides, hourly tide heights

**Benefits:**
- ✅ Global tide data, free tier (10 requests/day)
- ✅ Smart caching makes free tier highly effective

## File Structure

```
lib/
├── main.dart                          # App entry point, DI setup
├── models/
│   ├── surf_conditions.dart           # Single point-in-time data
│   ├── surf_forecast.dart             # Collection of conditions
│   ├── tide_data.dart                 # Tide information
│   └── location_search_result.dart    # Location search results
├── repositories/
│   ├── weather_repository.dart        # Weather abstract interface
│   ├── open_meteo_repository.dart     # Open-Meteo implementation
│   ├── tide_data_repository.dart      # Tide abstract interface
│   └── tide_repository.dart           # Stormglass implementation
└── database/
    ├── app_cache_database.dart        # Generic caching system (Drift)
    └── app_cache_database.g.dart      # Generated Drift code
```

## Benefits of This Architecture

1. **Flexibility** - Easy to switch providers without touching UI code
2. **Testability** - Can mock the repository interface for testing
3. **Maintainability** - Clear separation of concerns
4. **Scalability** - Easy to add new data sources
5. **Type Safety** - Compile-time checks for API contracts
6. **Efficient Caching** - Smart proximity-based cache reduces API calls
7. **Extensibility** - Generic database schema supports future data types

## Learn More

- **Tide Integration**: See [`.cursor/rules/tide-integration.mdc`](.cursor/rules/tide-integration.mdc) for complete tide data documentation
- **Cursor Rules**: Check `.cursor/rules/` directory for coding standards and best practices

