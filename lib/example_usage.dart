import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'repositories/weather_repository.dart';
import 'models/surf_forecast.dart';

/// Example widget showing how to use the WeatherRepository
/// 
/// This demonstrates:
/// 1. Accessing the repository via Provider
/// 2. Making API calls
/// 3. Handling loading/error states
/// 4. Displaying the data
class ExampleSurfSpotScreen extends StatefulWidget {
  const ExampleSurfSpotScreen({super.key});

  @override
  State<ExampleSurfSpotScreen> createState() => _ExampleSurfSpotScreenState();
}

class _ExampleSurfSpotScreenState extends State<ExampleSurfSpotScreen> {
  SurfForecast? _forecast;
  bool _isLoading = false;
  String? _error;

  // Rio de Janeiro, Brazil area
  final double _latitude = -23.0165;
  final double _longitude = -43.308;

  @override
  void initState() {
    super.initState();
    _loadForecast();
  }

  Future<void> _loadForecast() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get the repository from Provider - this is the key!
      final repository = Provider.of<WeatherRepository>(context, listen: false);
      
      // Make the API call
      final forecast = await repository.getSurfForecast(
        latitude: _latitude,
        longitude: _longitude,
        days: 7,
      );

      setState(() {
        _forecast = forecast;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_forecast?.locationName ?? 'Loading...'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadForecast,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading surf conditions...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadForecast,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_forecast == null) {
      return const Center(child: Text('No data available'));
    }

    final current = _forecast!.currentConditions;
    if (current == null) {
      return const Center(child: Text('No current conditions'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current conditions card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Conditions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildConditionRow(
                    Icons.waves,
                    'Wave Height',
                    '${current.waveHeight.toStringAsFixed(1)}m',
                  ),
                  _buildConditionRow(
                    Icons.timer,
                    'Wave Period',
                    '${current.wavePeriod.toStringAsFixed(0)}s',
                  ),
                  _buildConditionRow(
                    Icons.air,
                    'Wind Speed',
                    '${current.windSpeed.toStringAsFixed(0)} km/h',
                  ),
                  _buildConditionRow(
                    Icons.thermostat,
                    'Air Temp',
                    '${current.airTemperature.toStringAsFixed(0)}°C',
                  ),
                  _buildConditionRow(
                    Icons.wb_sunny,
                    'Weather',
                    current.weatherDescription,
                  ),
                  const Divider(),
                  Center(
                    child: Text(
                      'Surf Quality: ${current.surfQuality}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getSurfQualityColor(current.surfQuality),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Hourly forecast
          const Text(
            'Next 24 Hours',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _forecast!.hourlyConditions.length > 24 
                  ? 24 
                  : _forecast!.hourlyConditions.length,
              itemBuilder: (context, index) {
                final condition = _forecast!.hourlyConditions[index];
                return Card(
                  margin: const EdgeInsets.only(right: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${condition.timestamp.hour}:00',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Icon(Icons.waves, size: 20),
                        Text('${condition.waveHeight.toStringAsFixed(1)}m'),
                        const SizedBox(height: 4),
                        Text(
                          '${condition.windSpeed.toStringAsFixed(0)} km/h',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getSurfQualityColor(String quality) {
    switch (quality.toLowerCase()) {
      case 'flat':
        return Colors.grey;
      case 'small':
        return Colors.orange;
      case 'fun':
        return Colors.blue;
      case 'good':
        return Colors.green;
      case 'epic':
        return Colors.purple;
      case 'pumping':
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}

