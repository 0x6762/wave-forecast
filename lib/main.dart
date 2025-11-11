import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'repositories/weather_repository.dart';
import 'repositories/open_meteo_repository.dart';
import 'example_usage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set up dependency injection with Provider
    // To switch to a different API provider, simply replace OpenMeteoRepository
    // with another implementation of WeatherRepository
    return Provider<WeatherRepository>(
      create: (_) => OpenMeteoRepository(),
      dispose: (_, repository) {
        if (repository is OpenMeteoRepository) {
          repository.dispose();
        }
      },
      child: MaterialApp(
        title: 'Wave Forecast',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const ExampleSurfSpotScreen(),
      ),
    );
  }
}
