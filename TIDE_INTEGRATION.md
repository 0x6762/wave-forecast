# Tide Data Integration Guide

Complete documentation for tide data integration using Drift caching and Stormglass API.

> **⚡ AI Context**: Essential patterns are in [`.cursor/rules/tide-integration.mdc`](.cursor/rules/tide-integration.mdc) (optimized for token efficiency)

## Quick Setup

1. **Get API Key**: Sign up at [stormglass.io](https://stormglass.io) (free: 10 requests/day)

2. **Add Key**: In `lib/main.dart` line 30:
   ```dart
   final tideRepository = StormglassTideRepository(
     database: database,
     apiKey: 'YOUR_API_KEY_HERE',  // Replace null with your key
   );
   ```

3. **Run**: 
   ```bash
   flutter pub get
   flutter run
   ```

## Features

### ✅ Implemented
- **Repository Pattern**: Easy provider swapping (follows same pattern as `WeatherRepository`)
- **Drift Database**: Generic caching system for any location-based data
- **Smart Proximity Caching**: Reuses tide data within 25km radius (configurable)
- **Stormglass Implementation**: Global tide data via `StormglassTideRepository`
- **Automatic Cache Management**: 7-day cache duration with automatic expiration cleanup
- **UI Integration**: Displays tide height, rising/falling status, and next high/low tides
- **Graceful Degradation**: App works without tide data if no API key is provided

## Architecture

### Repository Pattern (Same as Weather)

Follows the exact same pattern as weather data for consistency:

```dart
// Abstract interface (lib/repositories/tide_data_repository.dart)
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

// Current implementation (lib/repositories/tide_repository.dart)
class StormglassTideRepository implements TideDataRepository {
  // Stormglass API + smart caching implementation
}

// Easy to swap providers in main.dart:
final tideRepository = StormglassTideRepository(...);  // Current
// final tideRepository = NOAATideRepository(...);     // Future alternative
// final tideRepository = WorldTidesRepository(...);   // Another option
```

### Integration Flow

```
User Request → OpenMeteoRepository
    ↓
    ├─→ Open-Meteo API (waves, weather)
    └─→ TideDataRepository (interface)
        ↓
        └─→ StormglassTideRepository (implementation)
            ↓
            ├─→ Check Database Cache (findNearby within 15km)
            │   └─→ Cache Hit? Return cached data ✅
            │
            └─→ Cache Miss? Fetch from Stormglass API
                └─→ Save to Database → Return data
```

## Smart Caching Strategy

### How It Works

1. **First Request** for a location:
   - Checks database for cached data within 25km radius
   - If none found, fetches from Stormglass API
   - Caches response for 7 days

2. **Subsequent Requests** for nearby locations:
   - If location is within 25km of cached station, reuses cached data
   - No API call needed! ✅

3. **Cache Key**: Uses tide station ID (multiple locations can share same station)

### Example Efficiency (Rio de Janeiro)

```
Search Ipanema       → API call (1/10)     ✅ Cached for 7 days
Search Copacabana    → Cache hit (5km)     🎯 No API call
Search Leblon        → Cache hit (3km)     🎯 No API call
Search Barra         → Cache hit (15km)    🎯 No API call
Search Macumba       → Cache hit (20km)    🎯 No API call
Search Grumari       → Cache hit (24km)    🎯 No API call
```

**Result**: 1 API call can serve entire Rio coast! Cache persists across app restarts

## Database Schema

### Generic Caching Table

```dart
// lib/database/app_cache_database.dart
class CachedData extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get dataType => text();        // 'tide', 'weather', etc.
  TextColumn get key => text();             // Unique identifier (station ID)
  RealColumn get latitude => real();        // For proximity search
  RealColumn get longitude => real();
  TextColumn get dataJson => text();        // Cached JSON data
  DateTimeColumn get fetchedAt => dateTime();
  DateTimeColumn get validUntil => dateTime();
  TextColumn get metadata => text().nullable();
}
```

**Extensible Design**: Can cache other data types by using different `dataType` values:
- `'tide'` - Tide data (current use)
- `'weather'` - Weather alerts (future)
- `'swell'` - Swell forecasts (future)
- `'forecast'` - Long-range forecasts (future)

## Configuration

### Cache Settings

In `lib/repositories/tide_repository.dart`:

```dart
// Default cache settings (adjust as needed)
static const double _defaultCacheRadiusKm = 15.0;      // Proximity threshold
static const Duration _defaultCacheDuration = Duration(days: 7);  // Cache lifetime
```

**Current Setting**: 25km radius (generous for most coastlines)

**Adjust if needed**:
- **30-40km radius**: For very straight coastlines with consistent tides
- **15-20km radius**: For complex coastlines (bays, estuaries)
- **10km radius**: For areas with significant tidal variations
- **7 days duration**: Standard (current, tide patterns repeat)
- **14 days duration**: For slower-changing areas

### Setup in App

In `lib/main.dart`:

```dart
// Initialize database
final database = AppCacheDatabase();

// Initialize tide repository with your API key
final tideRepository = StormglassTideRepository(
  database: database,
  apiKey: 'YOUR_STORMGLASS_API_KEY', // Get from stormglass.io
);

// Provide to app
Provider<TideDataRepository>.value(value: tideRepository)
```

**Security Note**: For production apps, use environment variables or secure storage instead of hardcoding API keys.

## Usage Patterns

### Fetch Tide Data

```dart
final tideData = await tideRepository.getTideData(
  latitude: -23.0165,
  longitude: -43.308,
  days: 7,
  cacheRadiusKm: 15.0,  // Optional, defaults to 15km
);

if (tideData != null) {
  // Tide data available
  print('Station: ${tideData.stationName}');
  print('Distance: ${tideData.distanceFromRequest}km');
  print('Next high: ${tideData.getNextHighTide()?.timestamp}');
} else {
  // No tide data (no API key, error, etc.)
}
```

### Cache Management

```dart
// Clear all tide cache
await tideRepository.clearCache();

// Clear all expired cache entries (automatic cleanup)
await database.clearExpiredCache();

// Get cache statistics
final stats = await database.getCacheStats();
print(stats);
// Output:
// {
//   'total_entries': 5,
//   'valid_entries': 4,
//   'expired_entries': 1,
//   'types': {'tide': 4}
// }
```

### Adjust Cache Settings at Runtime

```dart
// Use custom cache radius for specific request
final tideData = await tideRepository.getTideData(
  latitude: lat,
  longitude: lon,
  cacheRadiusKm: 40.0,  // Even larger radius for this specific request
);
```

## Data Models

### TideData

```dart
class TideData {
  final String stationId;           // Unique station identifier
  final String stationName;         // Human-readable name
  final double latitude;            // Station location
  final double longitude;
  final double distanceFromRequest; // km from requested location
  final List<TidePoint> tidePoints; // Hourly tide heights
  final List<TideExtreme> extremes; // High and low tides
  final DateTime fetchedAt;

  // Helper methods
  TidePoint? getCurrentTide();      // Closest to now
  TideExtreme? getNextHighTide();   // Next high tide
  TideExtreme? getNextLowTide();    // Next low tide
  bool get isRising;                // Tide direction
}
```

### TidePoint

```dart
class TidePoint {
  final DateTime timestamp;
  final double height;  // meters
}
```

### TideExtreme

```dart
class TideExtreme {
  final DateTime timestamp;
  final double height;  // meters
  final TideType type;  // high or low
}
```

### Integration with SurfConditions

```dart
class SurfConditions {
  // Existing fields (wave height, wind, etc.)
  
  // New optional tide fields
  final double? tideHeight;      // Current tide height (meters)
  final bool? isTideRising;      // true = rising, false = falling
}
```

## UI Integration

### Current Conditions Card

Shows tide information in the main conditions card:

```dart
if (current.tideHeight != null) {
  _buildConditionRow(
    current.isTideRising == true ? Icons.arrow_upward : Icons.arrow_downward,
    'Tide',
    '${current.tideHeight!.toStringAsFixed(2)}m ${current.isTideRising == true ? "Rising" : "Falling"}',
  ),
}
```

### Tide Information Section

Dedicated section showing detailed tide info:

```dart
if (_forecast!.tideData != null) {
  Card(
    child: Column(
      children: [
        Text('Station: ${tideData.stationName}'),
        Text('Distance: ${tideData.distanceFromRequest.toStringAsFixed(1)}km'),
        
        // Next high tide
        _buildTideExtreme('Next High Tide', tideData.getNextHighTide(), ...),
        
        // Next low tide
        _buildTideExtreme('Next Low Tide', tideData.getNextLowTide(), ...),
      ],
    ),
  )
}
```

### Graceful Degradation

- If no API key provided: Tide section doesn't appear
- If API call fails: Tide data is null, no errors shown
- App functions normally without tide data

## API Limits & Optimization

### Stormglass Free Tier

**Limits**: 10 requests per day

**Effectiveness with Caching**:
- **Without caching**: 10 unique locations per day
- **With 25km radius caching**: 100-200+ locations per day
- **With persistence**: Unlimited (after initial fetch, cache lasts 7 days)

### Tips to Maximize Free Tier

1. **Already optimized**: Default 25km radius works great for most coastlines
   ```dart
   static const double _defaultCacheRadiusKm = 40.0;  // Even more aggressive if needed
   ```

2. **Persistent storage**: Cache survives app restarts automatically

3. **Preload popular locations** on app startup (optional):
   ```dart
   // In initState or app startup
   await tideRepository.getTideData(
     latitude: popularSpots[0].lat,
     longitude: popularSpots[0].lon,
   );
   ```

4. **Backend cache sharing** (future enhancement):
   - One API call on server serves all users
   - Even more effective with free tier

## Switching Providers

### Example: Adding NOAA Tide Provider

**Step 1**: Create implementation

```dart
// lib/repositories/noaa_tide_repository.dart
import 'tide_data_repository.dart';
import '../models/tide_data.dart';
import '../database/app_cache_database.dart';

class NOAATideRepository implements TideDataRepository {
  final AppCacheDatabase _db;
  final String? _apiKey;
  
  NOAATideRepository({required AppCacheDatabase database, String? apiKey})
      : _db = database, _apiKey = apiKey;

  @override
  Future<TideData?> getTideData({
    required double latitude,
    required double longitude,
    int days = 7,
    double? cacheRadiusKm,
  }) async {
    // 1. Check cache first (reuse same caching logic)
    // 2. If miss, fetch from NOAA API
    // 3. Transform NOAA response to TideData model
    // 4. Cache and return
  }

  @override
  Future<void> clearCache() async {
    await _db.clearCacheByType('tide');
  }

  @override
  void dispose() {
    // Cleanup
  }
}
```

**Step 2**: Update main.dart (one line change!)

```dart
// Before:
final tideRepository = StormglassTideRepository(
  database: database,
  apiKey: 'STORMGLASS_KEY',
);

// After:
final tideRepository = NOAATideRepository(  // Changed this line only!
  database: database,
  apiKey: 'NOAA_KEY',
);
```

**That's it!** The rest of your app continues to work without any changes.

## Troubleshooting

### No Tide Data Showing

**Check API Key**:
```dart
// lib/main.dart, line 30
apiKey: 'YOUR_KEY_HERE',  // Make sure this is set
```

**Check Console Logs**:
- Look for `⚠️ No Stormglass API key provided`
- Look for `❌ Stormglass API error: 401` (invalid key)
- Look for `❌ Stormglass API error: 429` (rate limit exceeded)

**Check Internet Connection**: Tide data requires network access

**Check Daily Limit**: Free tier = 10 requests/day

### Database Issues

**Regenerate Drift Code**:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Clear App Data**:
- Android: Settings → Apps → Wave Forecast → Clear Data
- iOS: Uninstall and reinstall

**Database Location**: `<app_documents>/app_cache.sqlite`

### Inaccurate Tide Times

**Station Distance**: Stormglass uses nearest station (typically < 20km)
- Distance is shown in UI
- For very specific locations, consider paid tier

**Local Variations**: Complex coastlines may have local variations
- Consider reducing cache radius for better accuracy

### Performance Issues

**Slow Loads**: Check if database has too many expired entries
```dart
await database.clearExpiredCache();  // Manual cleanup
```

**Memory Issues**: Large cache (shouldn't happen with tide data)
```dart
final stats = await database.getCacheStats();
print(stats);  // Check cache size
```

## Best Practices

### When to Clear Cache

```dart
// After changing API key
await tideRepository.clearCache();

// After updating cache radius settings
await tideRepository.clearCache();

// Periodic maintenance (optional, auto-expires after 7 days)
await database.clearExpiredCache();
```

### Error Handling

```dart
// Repository handles errors gracefully
final tideData = await tideRepository.getTideData(
  latitude: lat,
  longitude: lon,
);

if (tideData == null) {
  // No tide data available
  // Reasons: No API key, network error, rate limit, etc.
  // UI automatically handles this (no tide section shown)
} else {
  // Tide data available, use it
}
```

### Performance Optimization

```dart
// Tide data is fetched in parallel with wave/weather data
final results = await Future.wait([
  _fetchMarineData(lat, lon, days),      // Open-Meteo
  _fetchWeatherData(lat, lon, days),     // Open-Meteo
  _fetchTideData(lat, lon, days),        // Stormglass (parallel!)
]);
```

### Testing

```dart
// Mock for testing
class MockTideRepository implements TideDataRepository {
  @override
  Future<TideData?> getTideData({...}) async {
    return TideData(/* mock data */);
  }
}

// Use in tests
final tideRepository = MockTideRepository();
```

## Future Enhancements

Potential improvements:
- [ ] Tide charts/graphs visualization
- [ ] User-configurable cache settings in UI
- [ ] Export cache data for offline use
- [ ] Sync cache across devices (with backend)
- [ ] Add other data types (swell forecasts, wind alerts, etc.)
- [ ] Multiple provider fallback chain
- [ ] Backend cache sharing across users
- [ ] Tide prediction algorithms (offline mode)

## Related Documentation

- [`.cursor/rules/tide-integration.mdc`](.cursor/rules/tide-integration.mdc) - AI-optimized patterns (token-efficient)
- [`ARCHITECTURE.md`](ARCHITECTURE.md) - Overall app architecture  
- [`README.md`](README.md) - General project information

## License & Attribution

This implementation uses:
- **Drift** (MIT License) - Local database
- **Stormglass API** - Tide data (Terms of Service apply)
- **Open-Meteo API** - Wave/weather data (CC BY 4.0)
