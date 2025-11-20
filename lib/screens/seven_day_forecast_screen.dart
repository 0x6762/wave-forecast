import 'package:flutter/material.dart';
import '../models/surf_forecast.dart';
import '../models/surf_conditions.dart';

class SevenDayForecastScreen extends StatefulWidget {
  final SurfForecast forecast;

  const SevenDayForecastScreen({super.key, required this.forecast});

  @override
  State<SevenDayForecastScreen> createState() => _SevenDayForecastScreenState();
}

class _SevenDayForecastScreenState extends State<SevenDayForecastScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  final Set<DateTime> _expandedDays = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 10 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 10 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  void _toggleDayExpansion(DateTime day) {
    setState(() {
      if (_expandedDays.contains(day)) {
        _expandedDays.remove(day);
      } else {
        _expandedDays.add(day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Group conditions by day
    final Map<DateTime, List<SurfConditions>> conditionsByDay = {};

    for (final condition in widget.forecast.hourlyConditions) {
      final dayKey = DateTime(
        condition.timestamp.year,
        condition.timestamp.month,
        condition.timestamp.day,
      );

      if (!conditionsByDay.containsKey(dayKey)) {
        conditionsByDay[dayKey] = [];
      }
      conditionsByDay[dayKey]!.add(condition);
    }

    final days = conditionsByDay.keys.toList()..sort();

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: _isScrolled
            ? const Color(0xFF1E1E1E)
            : Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '7-Day Forecast',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(
          16,
          MediaQuery.of(context).padding.top + kToolbarHeight + 16,
          16,
          16,
        ),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final dayConditions = conditionsByDay[day]!;

          return _buildDayCard(day, dayConditions);
        },
      ),
    );
  }

  Widget _buildDayCard(DateTime day, List<SurfConditions> conditions) {
    final now = DateTime.now();
    final isToday =
        day.year == now.year && day.month == now.month && day.day == now.day;
    final isTomorrow = day.difference(now).inDays == 1;
    final isExpanded = _expandedDays.contains(day);

    String dayLabel;
    if (isToday) {
      dayLabel = "Today";
    } else if (isTomorrow) {
      dayLabel = "Tomorrow";
    } else {
      dayLabel = _getDayName(day.weekday);
    }

    // Calculate day stats (min and max)
    final waveHeights = conditions.map((c) => c.waveHeight).toList();
    final minWaveHeight = waveHeights.reduce((a, b) => a < b ? a : b);
    final maxWaveHeight = waveHeights.reduce((a, b) => a > b ? a : b);

    final wavePeriods = conditions.map((c) => c.wavePeriod).toList();
    final minWavePeriod = wavePeriods.reduce((a, b) => a < b ? a : b);
    final maxWavePeriod = wavePeriods.reduce((a, b) => a > b ? a : b);

    final windSpeeds = conditions.map((c) => c.windSpeed).toList();
    final minWindSpeed = windSpeeds.reduce((a, b) => a < b ? a : b);
    final maxWindSpeed = windSpeeds.reduce((a, b) => a > b ? a : b);

    final temps = conditions.map((c) => c.airTemperature).toList();
    final minTemp = temps.reduce((a, b) => a < b ? a : b);
    final maxTemp = temps.reduce((a, b) => a > b ? a : b);

    final waterTemps = conditions.map((c) => c.waterTemperature).toList();
    final minWaterTemp = waterTemps.reduce((a, b) => a < b ? a : b);
    final maxWaterTemp = waterTemps.reduce((a, b) => a > b ? a : b);

    final waveDirections = conditions.map((c) => c.waveDirection).toList();
    final avgWaveDirection =
        waveDirections.reduce((a, b) => a + b) / waveDirections.length;

    final windDirections = conditions.map((c) => c.windDirection).toList();
    final avgWindDirection =
        windDirections.reduce((a, b) => a + b) / windDirections.length;

    // Get peak quality score
    final peakQuality = conditions
        .map((c) => c.getQualityScore(null))
        .reduce((a, b) => a > b ? a : b);

    return GestureDetector(
      onTap: () => _toggleDayExpansion(day),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${day.day}/${day.month}",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getQualityColor(peakQuality),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "$peakQuality%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Pills row - fades when expanded
            AnimatedOpacity(
              opacity: isExpanded ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubicEmphasized,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildPill(
                      Icons.waves,
                      "${minWaveHeight.toStringAsFixed(1)}-${maxWaveHeight.toStringAsFixed(1)}m",
                    ),
                    const SizedBox(width: 12),
                    _buildPill(
                      Icons.timer,
                      "${minWavePeriod.round()}-${maxWavePeriod.round()}s",
                    ),
                    const SizedBox(width: 12),
                    _buildPill(
                      Icons.air,
                      "${minWindSpeed.round()}-${maxWindSpeed.round()}km/h",
                    ),
                    const SizedBox(width: 12),
                    _buildPill(
                      Icons.wb_sunny,
                      "${minTemp.round()}-${maxTemp.round()}°",
                    ),
                  ],
                ),
              ),
            ),

            // Expanded details section
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "DETAILED CONDITIONS",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      Icons.waves,
                      "WAVE HEIGHT",
                      "${minWaveHeight.toStringAsFixed(1)}-${maxWaveHeight.toStringAsFixed(1)}m",
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      Icons.waves,
                      "SWELL PERIOD",
                      "${minWavePeriod.round()}-${maxWavePeriod.round()}s",
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      Icons.explore,
                      "SWELL DIR",
                      _getWindDirection(avgWaveDirection),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      Icons.air,
                      "WIND SPEED",
                      "${minWindSpeed.round()}-${maxWindSpeed.round()}km/h",
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      Icons.flag,
                      "WIND DIR",
                      _getWindDirection(avgWindDirection),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      Icons.wb_cloudy,
                      "AIR TEMP",
                      "${minTemp.round()}-${maxTemp.round()}°C",
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      Icons.water_drop,
                      "WATER TEMP",
                      "${minWaterTemp.round()}-${maxWaterTemp.round()}°C",
                    ),
                  ],
                ),
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
              firstCurve: Curves.easeInOutCubicEmphasized,
              secondCurve: Curves.easeInOutCubicEmphasized,
              sizeCurve: Curves.easeInOutCubicEmphasized,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.white.withOpacity(0.5)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getQualityColor(int quality) {
    if (quality >= 80) return Colors.green.withOpacity(0.3);
    if (quality >= 60) return Colors.lightGreen.withOpacity(0.3);
    if (quality >= 40) return Colors.orange.withOpacity(0.3);
    return Colors.red.withOpacity(0.3);
  }

  String _getWindDirection(double degrees) {
    // Convert degrees to 16-point compass direction
    const directions = [
      'N',
      'NNE',
      'NE',
      'ENE',
      'E',
      'ESE',
      'SE',
      'SSE',
      'S',
      'SSW',
      'SW',
      'WSW',
      'W',
      'WNW',
      'NW',
      'NNW',
    ];

    // Each direction covers 22.5 degrees (360 / 16)
    // Add 11.25 to offset so North is centered at 0/360
    final index = ((degrees + 11.25) / 22.5).floor() % 16;
    return directions[index];
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
}
