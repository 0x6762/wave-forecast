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
  - Helper methods for surf quality assessment

- **`SurfForecast`** - Collection of surf conditions over time
  - Location information
  - List of hourly conditions
  - Helper methods to filter by date

### 2. Repositories (`lib/repositories/`)

#### Abstract Interface
**`WeatherRepository`** - Defines the contract for any weather data provider
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

#### Concrete Implementation
**`OpenMeteoRepository`** - Current implementation using Open-Meteo API
- Implements the `WeatherRepository` interface
- Handles API calls to Open-Meteo's marine and weather endpoints
- Transforms API responses into our domain models

### 3. Dependency Injection

The app uses **Provider** for dependency injection in `main.dart`:

```dart
Provider<WeatherRepository>(
  create: (_) => OpenMeteoRepository(),
  child: MaterialApp(...),
)
```

To use the repository anywhere in your app:
```dart
final repository = Provider.of<WeatherRepository>(context, listen: false);
final forecast = await repository.getSurfForecast(
  latitude: -33.865143,
  longitude: 151.209900,
);
```

## How to Switch API Providers

Switching to a different API provider is simple:

### Step 1: Create a new repository implementation

```dart
// lib/repositories/stormglass_repository.dart
import 'weather_repository.dart';
import '../models/surf_forecast.dart';

class StormglassRepository implements WeatherRepository {
  @override
  Future<SurfForecast> getSurfForecast({
    required double latitude,
    required double longitude,
    int days = 7,
  }) async {
    // Your Stormglass API implementation
    // Transform their data into SurfForecast model
  }

  @override
  Future<String> getLocationName({
    required double latitude,
    required double longitude,
  }) async {
    // Your implementation
  }
}
```

### Step 2: Update main.dart

Simply replace `OpenMeteoRepository()` with your new implementation:

```dart
Provider<WeatherRepository>(
  create: (_) => StormglassRepository(), // Changed this line only!
  child: MaterialApp(...),
)
```

That's it! The rest of your app continues to work without any changes.

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

## File Structure

```
lib/
├── main.dart                          # App entry point, DI setup
├── models/
│   ├── surf_conditions.dart           # Single point-in-time data
│   └── surf_forecast.dart             # Collection of conditions
└── repositories/
    ├── weather_repository.dart        # Abstract interface
    └── open_meteo_repository.dart     # Open-Meteo implementation
```

## Benefits of This Architecture

1. **Flexibility** - Easy to switch providers without touching UI code
2. **Testability** - Can mock the repository interface for testing
3. **Maintainability** - Clear separation of concerns
4. **Scalability** - Easy to add new data sources
5. **Type Safety** - Compile-time checks for API contracts

## Future Enhancements

- Add caching layer (local storage)
- Support multiple simultaneous providers
- Add retry logic and error handling
- Implement rate limiting
- Add offline mode support

