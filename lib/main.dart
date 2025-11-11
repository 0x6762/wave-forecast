import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'repositories/weather_repository.dart';
import 'repositories/open_meteo_repository.dart';
import 'models/surf_forecast.dart';
import 'models/location_search_result.dart';

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
        home: const SurfSpotScreen(),
      ),
    );
  }
}

class SurfSpotScreen extends StatefulWidget {
  const SurfSpotScreen({super.key});

  @override
  State<SurfSpotScreen> createState() => _SurfSpotScreenState();
}

class _SurfSpotScreenState extends State<SurfSpotScreen> {
  SurfForecast? _forecast;
  bool _isLoading = false;
  String? _error;
  String? _selectedLocationName; // Store the clean name from search

  // Default location: Rio de Janeiro, Brazil area
  double _latitude = -23.0165;
  double _longitude = -43.308;

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
      final repository = Provider.of<WeatherRepository>(context, listen: false);

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
        title: Text(_selectedLocationName ?? _forecast?.locationName ?? 'Loading...'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadForecast),
        ],
      ),
      body: _buildBody(),
    );
  }

  Future<void> _showSearchDialog() async {
    final result = await showDialog<LocationSearchResult>(
      context: context,
      builder: (context) => const LocationSearchDialog(),
    );

    if (result != null) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
        _selectedLocationName = result.cleanName; // Store the clean name
      });
      _loadForecast();
    }
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
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

// Location Search Dialog
class LocationSearchDialog extends StatefulWidget {
  const LocationSearchDialog({super.key});

  @override
  State<LocationSearchDialog> createState() => _LocationSearchDialogState();
}

class _LocationSearchDialogState extends State<LocationSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<LocationSearchResult> _results = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final repository = Provider.of<WeatherRepository>(context, listen: false);
      final results = await repository.searchLocations(query);

      setState(() {
        _results = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search surf spot (e.g., Bondi Beach)',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _results = [];
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {}); // Update clear button visibility
                },
                onSubmitted: _search,
              ),
            ),

            // Search button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _search(_searchController.text),
                  child: const Text('Search'),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Results list
            Expanded(child: _buildResultsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Search for a surf spot',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Try: Bondi Beach, Pipeline, Malibu',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        return ListTile(
          leading: const Icon(Icons.location_on),
          title: Text(result.cleanName),
          subtitle: Text(
            '${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}',
            style: const TextStyle(fontSize: 12),
          ),
          onTap: () {
            Navigator.of(context).pop(result);
          },
        );
      },
    );
  }
}
