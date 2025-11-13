import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/weather_repository.dart';
import '../models/surf_forecast.dart';
import '../models/location_search_result.dart';
import '../models/tide_data.dart';
import '../config/app_constants.dart';
import 'location_search_screen.dart';

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
        days: AppConstants.defaultForecastDays,
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

  String _getPrimaryLocationName() {
    final fullName =
        _selectedLocationName ?? _forecast?.locationName ?? 'Loading...';
    // Extract only the first part before the comma
    final parts = fullName.split(', ');
    return parts.isNotEmpty ? parts.first : fullName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, size: 20),
            const SizedBox(width: 8),
            Text(
              _getPrimaryLocationName(),
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
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
    final result = await Navigator.push<LocationSearchResult>(
      context,
      MaterialPageRoute(builder: (context) => const LocationSearchScreen()),
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
          // Current conditions title
          const Text(
            'Current Conditions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Current conditions card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    'Wind',
                    '${current.windSpeed.toStringAsFixed(0)} km/h ${_getWindDirection(current.windDirection)}',
                  ),
                  _buildConditionRow(
                    Icons.thermostat,
                    'Air Temp',
                    '${current.airTemperature.toStringAsFixed(0)}°C',
                  ),
                  _buildConditionRow(
                    Icons.water,
                    'Water Temp',
                    '${current.waterTemperature.toStringAsFixed(0)}°C',
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

          // Tide information section
          if (_forecast!.tideData != null) ...[
            const Text(
              'Tide Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                final nextTides = _forecast!.tideData!.getNextTwoTides();

                if (nextTides.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: const Text('No upcoming tide data'),
                    ),
                  );
                }

                return Row(
                  children: [
                    // First tide
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildTideExtreme(
                            nextTides[0].type == TideType.high
                                ? 'High Tide'
                                : 'Low Tide',
                            nextTides[0],
                            nextTides[0].type == TideType.high
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            nextTides[0].type == TideType.high
                                ? Colors.blue
                                : Colors.orange,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Second tide (if available)
                    Expanded(
                      child: nextTides.length > 1
                          ? Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: _buildTideExtreme(
                                  nextTides[1].type == TideType.high
                                      ? 'High Tide'
                                      : 'Low Tide',
                                  nextTides[1],
                                  nextTides[1].type == TideType.high
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  nextTides[1].type == TideType.high
                                      ? Colors.blue
                                      : Colors.orange,
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
          ],

          // Hourly forecast
          const Text(
            'Next 12 Hours',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 130,
            child: Builder(
              builder: (context) {
                // Filter to show only future hours
                final now = DateTime.now();
                final futureConditions = _forecast!.hourlyConditions
                    .where((c) => c.timestamp.isAfter(now))
                    .take(AppConstants.hourlyForecastDisplayCount)
                    .toList();

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: futureConditions.length,
                  itemBuilder: (context, index) {
                    final condition = futureConditions[index];
                    final isNow = index == 0;

                    return Card(
                      margin: const EdgeInsets.only(right: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isNow ? 'Now' : '${condition.timestamp.hour}:00',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isNow ? Colors.blue : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Icon(Icons.waves, size: 20),
                            Text('${condition.waveHeight.toStringAsFixed(1)}m'),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.air, size: 12),
                                const SizedBox(width: 2),
                                Text(
                                  '${condition.windSpeed.toStringAsFixed(0)} ${_getWindDirection(condition.windDirection)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Daily forecast
          const Text(
            '7-Day Forecast',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._buildDailyCards(),
        ],
      ),
    );
  }

  List<Widget> _buildDailyCards() {
    if (_forecast == null) return [];

    final now = DateTime.now();
    final cards = <Widget>[];

    // Group conditions by day for the next days
    for (int dayOffset = 0; dayOffset < AppConstants.defaultForecastDays; dayOffset++) {
      final targetDay = now.add(Duration(days: dayOffset));
      final dayConditions = _forecast!.getConditionsForDay(targetDay);

      if (dayConditions.isEmpty) continue;

      // Calculate daily stats - min and max values
      final minWaveHeight = dayConditions
          .map((c) => c.waveHeight)
          .reduce((a, b) => a < b ? a : b);
      final maxWaveHeight = dayConditions
          .map((c) => c.waveHeight)
          .reduce((a, b) => a > b ? a : b);

      final minWindSpeed = dayConditions
          .map((c) => c.windSpeed)
          .reduce((a, b) => a < b ? a : b);
      final maxWindSpeed = dayConditions
          .map((c) => c.windSpeed)
          .reduce((a, b) => a > b ? a : b);

      final minAirTemp = dayConditions
          .map((c) => c.airTemperature)
          .reduce((a, b) => a < b ? a : b);
      final maxAirTemp = dayConditions
          .map((c) => c.airTemperature)
          .reduce((a, b) => a > b ? a : b);

      final minWaterTemp = dayConditions
          .map((c) => c.waterTemperature)
          .reduce((a, b) => a < b ? a : b);
      final maxWaterTemp = dayConditions
          .map((c) => c.waterTemperature)
          .reduce((a, b) => a > b ? a : b);

      final dayName = dayOffset == 0
          ? 'Today'
          : dayOffset == 1
          ? 'Tomorrow'
          : _getDayName(targetDay.weekday);

      cards.add(
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${targetDay.month}/${targetDay.day}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDailyStat(
                        Icons.waves,
                        'Waves',
                        '${minWaveHeight.toStringAsFixed(1)}-${maxWaveHeight.toStringAsFixed(1)}m',
                      ),
                    ),
                    Expanded(
                      child: _buildDailyStat(
                        Icons.air,
                        'Wind',
                        '${minWindSpeed.toStringAsFixed(0)}-${maxWindSpeed.toStringAsFixed(0)}km/h',
                      ),
                    ),
                    Expanded(
                      child: _buildDailyStat(
                        Icons.thermostat,
                        'Air',
                        '${minAirTemp.toStringAsFixed(0)}-${maxAirTemp.toStringAsFixed(0)}°C',
                      ),
                    ),
                    Expanded(
                      child: _buildDailyStat(
                        Icons.water,
                        'Water',
                        '${minWaterTemp.toStringAsFixed(0)}-${maxWaterTemp.toStringAsFixed(0)}°C',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return cards;
  }

  Widget _buildDailyStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTideExtreme(
    String label,
    dynamic tideExtreme,
    IconData icon,
    Color color,
  ) {
    if (tideExtreme == null) {
      return Column(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 2),
          const Text('N/A', style: TextStyle(fontSize: 14)),
        ],
      );
    }

    final time = tideExtreme.timestamp;
    final height = tideExtreme.height;
    final now = DateTime.now();

    // Format time as HH:MM with AM/PM
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    // Show time, and date if not today
    String timeStr;
    if (time.year == now.year &&
        time.month == now.month &&
        time.day == now.day) {
      timeStr = '$displayHour:$minute $period';
    } else {
      timeStr = '$displayHour:$minute $period (${time.day}/${time.month})';
    }

    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 2),
        Text(
          '${height.toStringAsFixed(2)}m',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(timeStr, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      ],
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
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

  String _getWindDirection(double degrees) {
    // Convert degrees to compass direction
    if (degrees >= 337.5 || degrees < 22.5) return 'N';
    if (degrees >= 22.5 && degrees < 67.5) return 'NE';
    if (degrees >= 67.5 && degrees < 112.5) return 'E';
    if (degrees >= 112.5 && degrees < 157.5) return 'SE';
    if (degrees >= 157.5 && degrees < 202.5) return 'S';
    if (degrees >= 202.5 && degrees < 247.5) return 'SW';
    if (degrees >= 247.5 && degrees < 292.5) return 'W';
    if (degrees >= 292.5 && degrees < 337.5) return 'NW';
    return '';
  }
}

