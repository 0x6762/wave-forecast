# Wave Forecast 🏄‍♂️

A Flutter surf forecast app providing real-time wave conditions for surfers worldwide.

## Features

- 🌊 Wave height, period, and direction
- 🌊 Tide data with high/low tide times (optional)
- 💨 Wind speed and direction
- 🌡️ Air and water temperature
- ☀️ Weather conditions
- 📅 7-day forecast
- 🗺️ Global coverage
- 💾 Smart caching (25km proximity, 7-day persistence)

## Architecture

This app uses a **clean architecture with the Repository Pattern** that allows easy swapping between different weather API providers.

### Current API Providers
- **Open-Meteo** - Free, open-source weather and marine forecast API
  - Documentation: https://open-meteo.com/en/docs
- **Stormglass** (optional) - Tide data with smart caching
  - Documentation: https://stormglass.io/tide-api
  - Free tier: 10 requests/day (100-200+ locations with caching)

### Key Components

```
lib/
├── models/              # Data models (SurfConditions, TideData, etc.)
├── repositories/        # Data layer with abstract interfaces
│   ├── weather_repository.dart          # Weather abstract interface
│   ├── open_meteo_repository.dart       # Open-Meteo implementation
│   ├── tide_data_repository.dart        # Tide abstract interface
│   └── tide_repository.dart             # Stormglass implementation
├── database/            # Drift caching layer (generic, extensible)
└── main.dart            # App entry point with DI setup
```

### Switching API Providers

Want to use a different API? Just create a new class that implements `WeatherRepository` and swap it in `main.dart`. See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed instructions.

## Getting Started

### Prerequisites
- Flutter SDK (^3.8.1)
- Dart SDK

### Installation

1. Clone the repository
2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Dependencies
- `http` - HTTP client for API requests
- `provider` - State management and dependency injection
- `drift` - Local database for smart caching
- `drift_flutter` - Flutter integration for Drift

## Usage Example

```dart
// Get the repository from Provider
final repository = Provider.of<WeatherRepository>(context, listen: false);

// Fetch surf forecast
final forecast = await repository.getSurfForecast(
  latitude: -33.890542,  // Bondi Beach
  longitude: 151.274856,
  days: 7,
);

// Access current conditions
final current = forecast.currentConditions;
print('Wave height: ${current.waveHeight}m');
print('Surf quality: ${current.surfQuality}');
```

See `lib/example_usage.dart` for a complete working example.

## Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) - Detailed architecture documentation and how to switch API providers
- [TIDE_INTEGRATION.md](TIDE_INTEGRATION.md) - Complete tide data integration guide with smart caching

## License

This project is open source.

## Acknowledgments

- Weather and marine data provided by [Open-Meteo](https://open-meteo.com/)
- Tide data provided by [Stormglass](https://stormglass.io/) (optional)
