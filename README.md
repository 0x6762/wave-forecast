# Wave Forecast 🏄‍♂️

A Flutter surf forecast app providing real-time wave conditions for surfers worldwide.

## Features

- 🌊 Wave height, period, and direction
- 💨 Wind speed and direction
- 🌡️ Air and water temperature
- ☀️ Weather conditions
- 📅 7-day forecast
- 🗺️ Global coverage

## Architecture

This app uses a **clean architecture with the Repository Pattern** that allows easy swapping between different weather API providers.

### Current API Provider
- **Open-Meteo** - Free, open-source weather and marine forecast API
- Documentation: https://open-meteo.com/en/docs

### Key Components

```
lib/
├── models/              # Data models (API-agnostic)
├── repositories/        # Data layer with abstract interface
│   ├── weather_repository.dart          # Abstract interface
│   └── open_meteo_repository.dart       # Open-Meteo implementation
├── example_usage.dart   # Example of how to use the repository
└── main.dart           # App entry point with DI setup
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

## License

This project is open source.

## Acknowledgments

- Weather data provided by [Open-Meteo](https://open-meteo.com/)
