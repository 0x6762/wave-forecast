import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'repositories/weather_repository.dart';
import 'repositories/open_meteo_repository.dart';
import 'repositories/tide_data_repository.dart';
import 'repositories/tide_repository.dart';
import 'database/app_cache_database.dart';
import 'screens/surf_spot_screen.dart';

Future<void> main() async {
  // Load environment variables
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize database (singleton)
    final database = AppCacheDatabase();

    // Initialize tide repository with Stormglass API
    // API key loaded from .env file (see .env.example)
    // To switch to a different tide provider, simply replace StormglassTideRepository
    // with another implementation of TideDataRepository
    //
    // DEV MODE: Set apiKey to null to use cached data only (saves API quota during testing)
    final tideRepository = StormglassTideRepository(
      database: database,
      apiKey: dotenv.env['STORMGLASS_API_KEY'],
    );

    // Set up dependency injection with Provider
    // To switch to a different API provider, simply replace OpenMeteoRepository
    // with another implementation of WeatherRepository
    return MultiProvider(
      providers: [
        Provider<AppCacheDatabase>.value(value: database),
        Provider<TideDataRepository>.value(value: tideRepository),
        Provider<WeatherRepository>(
          create: (_) => OpenMeteoRepository(tideRepository: tideRepository),
          dispose: (_, repository) {
            if (repository is OpenMeteoRepository) {
              repository.dispose();
            }
          },
        ),
      ],
      child: MaterialApp(
        title: 'Wave Forecast',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.dark,
        home: const SurfSpotScreen(),
      ),
    );
  }
}
