import 'surf_conditions.dart';
import 'tide_data.dart';

class SurfForecast {
  final String locationName;
  final double latitude;
  final double longitude;
  final List<SurfConditions> hourlyConditions;
  final DateTime fetchedAt;
  final TideData? tideData; // Optional tide information

  SurfForecast({
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.hourlyConditions,
    required this.fetchedAt,
    this.tideData,
  });

  // Get current conditions (closest to now)
  SurfConditions? get currentConditions {
    if (hourlyConditions.isEmpty) return null;
    
    final now = DateTime.now();
    return hourlyConditions.reduce((a, b) {
      final aDiff = a.timestamp.difference(now).abs();
      final bDiff = b.timestamp.difference(now).abs();
      return aDiff < bDiff ? a : b;
    });
  }

  // Get conditions for a specific day
  List<SurfConditions> getConditionsForDay(DateTime day) {
    return hourlyConditions.where((condition) {
      return condition.timestamp.year == day.year &&
          condition.timestamp.month == day.month &&
          condition.timestamp.day == day.day;
    }).toList();
  }

  @override
  String toString() {
    return 'SurfForecast($locationName: ${hourlyConditions.length} hours)';
  }
}

