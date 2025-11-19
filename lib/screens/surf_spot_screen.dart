import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/weather_repository.dart';
import '../models/surf_forecast.dart';
import '../models/location_search_result.dart';
import '../config/app_constants.dart';
import '../utils/daily_summary_generator.dart';
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
  String? _selectedLocationName;

  // Layout data
  DailySummary? _todaySummary;
  List<BetterConditionOption> _betterConditions = [];
  bool _isSummaryExpanded = false;

  double _latitude = -23.0165; // Rio
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

      // Generate summaries
      final todayConditions = forecast.getConditionsForDay(DateTime.now());
      final summary = DailySummaryGenerator.generate(
        todayConditions,
        forecast.currentConditions,
      );
      final betterConditions = DailySummaryGenerator.findBetterConditions(
        forecast,
      );

      setState(() {
        _forecast = forecast;
        _todaySummary = summary;
        _betterConditions = betterConditions;
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
    final parts = fullName.split(', ');
    return parts.isNotEmpty ? parts.first : fullName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error!, style: const TextStyle(color: Colors.white)),
                  ElevatedButton(
                    onPressed: _loadForecast,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header Section (Unified background)
                  _buildHeaderSection(),

                  const SizedBox(height: 8), // Gap between sections
                  // Bottom Section (Light Card)
                  _buildBottomSection(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderSection() {
    final summary = _todaySummary;
    if (summary == null) return const SizedBox();

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E), // Dark background
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AppBar (now inside the header card)
              _buildAppBar(),

              const SizedBox(height: 32),

              // Date Label
              Text(
                "${_getWeekdayName(DateTime.now().weekday)}, ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 12),

              // Headline
              Text(
                summary.headline,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  height: 1.1,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 8),

              // Sub-headline (Verdict)
              Text(
                summary.subHeadline,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  height: 1.1,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 32),

              // Stats Pills
              Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildExpandButton(),
                        const SizedBox(width: 12),
                        // Fade out pills when expanded
                        AnimatedOpacity(
                          opacity: _isSummaryExpanded ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOutCubicEmphasized,
                          child: Row(
                            children: [
                              _buildStatPill(Icons.waves, summary.waveLabel),
                              const SizedBox(width: 12),
                              _buildStatPill(Icons.air, summary.windLabel),
                              const SizedBox(width: 12),
                              _buildStatPill(
                                Icons.wb_cloudy,
                                summary.tempLabel,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Expandable Details Section
                  AnimatedCrossFade(
                    firstChild: const SizedBox(width: double.infinity),
                    secondChild: Container(
                      margin: const EdgeInsets.only(top: 24),
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _buildExpandedDetails(),
                    ),
                    crossFadeState: _isSummaryExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 500),
                    firstCurve: Curves.easeInOutCubicEmphasized,
                    secondCurve: Curves.easeInOutCubicEmphasized,
                    sizeCurve: Curves.easeInOutCubicEmphasized,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Location Pill
        GestureDetector(
          onTap: _showSearchDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A), // Dark grey pill
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.redAccent,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _getPrimaryLocationName(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5), // Light card background
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Better conditions" Header
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.black87, size: 20),
              const SizedBox(width: 8),
              Text(
                "Better conditions",
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Suggestions List
          ..._betterConditions.map(
            (option) => _buildBetterConditionCard(option),
          ),

          if (_betterConditions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text("No significantly better conditions found nearby."),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSummaryExpanded = !_isSummaryExpanded;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(
            0.2,
          ), // Slightly lighter to indicate interactivity
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(
          _isSummaryExpanded ? Icons.expand_less : Icons.expand_more,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildExpandedDetails() {
    if (_forecast == null || _forecast!.currentConditions == null)
      return const SizedBox();

    final current = _forecast!.currentConditions!;
    final tide = _forecast!.tideData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "DETAILED CONDITIONS",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 24),

        // Primary Stats (Wave, Wind, Air Temp)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailItem(
                    Icons.waves,
                    "Wave Height",
                    "${current.waveHeight.toStringAsFixed(1)}m",
                  ),
                  const SizedBox(height: 20),
                  _buildDetailItem(
                    Icons.waves,
                    "Swell Period",
                    "${current.wavePeriod.toStringAsFixed(1)}s",
                  ),
                  const SizedBox(height: 20),
                  _buildDetailItem(
                    Icons.explore,
                    "Swell Dir",
                    "${current.waveDirection.round()}°",
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailItem(
                    Icons.air,
                    "Wind Speed",
                    "${current.windSpeed.round()}km/h",
                  ),
                  const SizedBox(height: 20),
                  _buildDetailItem(
                    Icons.flag,
                    "Wind Dir",
                    "${current.windDirection.round()}° ${_getWindDirection(current.windDirection)}",
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailItem(
                    Icons.wb_cloudy,
                    "Air Temp",
                    "${current.airTemperature.round()}°C",
                  ),
                  const SizedBox(height: 20),
                  _buildDetailItem(
                    Icons.water_drop,
                    "Water Temp",
                    "${current.waterTemperature.round()}°C",
                  ),
                  const SizedBox(height: 20),
                  if (tide != null && tide.getNextHighTide() != null)
                    _buildDetailItem(
                      Icons.trending_up,
                      "High Tide",
                      "${tide.getNextHighTide()!.timestamp.hour}:${tide.getNextHighTide()!.timestamp.minute.toString().padLeft(2, '0')}",
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.white.withOpacity(0.5)),
            const SizedBox(width: 6),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildStatPill(IconData icon, String text) {
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

  Widget _buildBetterConditionCard(BetterConditionOption option) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(
          0xFFE8E8E8,
        ), // Slightly darker grey for internal cards
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      option.timeLabel,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      option.chanceLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Compact details row
                Row(
                  children: [
                    _buildCompactDetail(
                      Icons.waves,
                      "${option.waveHeight.toStringAsFixed(1)}m",
                    ),
                    const SizedBox(width: 12),
                    _buildCompactDetail(
                      Icons.timer,
                      "${option.wavePeriod.round()}s",
                    ),
                    const SizedBox(width: 12),
                    _buildCompactDetail(
                      Icons.air,
                      "${option.windSpeed.round()}km/h",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
        _selectedLocationName = result.cleanName;
      });
      _loadForecast();
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

  String _getWeekdayName(int weekday) {
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
