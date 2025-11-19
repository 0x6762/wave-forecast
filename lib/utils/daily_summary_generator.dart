import 'dart:math';
import '../models/surf_conditions.dart';
import '../models/surf_forecast.dart';

class DailySummary {
  final String headline;
  final String subHeadline;
  final String waveLabel;
  final String windLabel;
  final String tempLabel;
  final String weatherIcon; // Simplified for now

  DailySummary({
    required this.headline,
    required this.subHeadline,
    required this.waveLabel,
    required this.windLabel,
    required this.tempLabel,
    required this.weatherIcon,
  });
}

class BetterConditionOption {
  final String timeLabel;
  final String chanceLabel;
  final DateTime timestamp;
  final double waveHeight;
  final double wavePeriod;
  final double windSpeed;
  final String? tideType; // 'High', 'Low', 'Mid', etc.

  BetterConditionOption({
    required this.timeLabel,
    required this.chanceLabel,
    required this.timestamp,
    required this.waveHeight,
    required this.wavePeriod,
    required this.windSpeed,
    this.tideType,
  });
}

class DailySummaryGenerator {
  /// Generates a structured summary for the UI
  static DailySummary generate(List<SurfConditions> dayConditions) {
    if (dayConditions.isEmpty) {
      return DailySummary(
        headline: "No Data",
        subHeadline: "Forecast unavailable",
        waveLabel: "-",
        windLabel: "-",
        tempLabel: "-",
        weatherIcon: "cloud",
      );
    }

    // Filter for daylight/active hours to get representative conditions
    final daylightConditions = dayConditions.where((c) {
      return c.timestamp.hour >= 6 && c.timestamp.hour <= 18;
    }).toList();
    
    final activeConditions = daylightConditions.isNotEmpty ? daylightConditions : dayConditions;
    
    // Calculate stats
    final maxWave = activeConditions.map((c) => c.waveHeight).reduce(max);
    final minWave = activeConditions.map((c) => c.waveHeight).reduce(min);
    final avgWind = activeConditions.map((c) => c.windSpeed).reduce((a, b) => a + b) / activeConditions.length;
    final windDir = activeConditions.first.windDirection; // Approximate
    final temp = activeConditions.map((c) => c.airTemperature).reduce(max);

    // Generate Text
    final String headline;
    final String subHeadline;

    // Logic for text
    if (avgWind > 25) {
      headline = "Strong onshore winds, messy conditions.";
      subHeadline = "Not ideal conditions.";
    } else if (maxWave < 0.5) {
      headline = "Small waves, barely rideable.";
      subHeadline = "Flat conditions.";
    } else if (maxWave < 1.0 && avgWind < 15) {
      headline = "Small but clean waves.";
      subHeadline = "Good for beginners.";
    } else if (maxWave >= 1.5 && avgWind < 20) {
      headline = "Solid swell with decent winds.";
      subHeadline = "Good conditions.";
    } else {
      headline = "Mixed conditions, check the wind.";
      subHeadline = "Average surf.";
    }

    // Formatted Labels
    // Wave: "1-2 m" (Keeping metric as per system, but could toggle)
    final waveLabel = (maxWave - minWave).abs() < 0.2
        ? "${maxWave.toStringAsFixed(1)} m"
        : "${minWave.toStringAsFixed(1)}-${maxWave.toStringAsFixed(1)} m";
        
    // Wind: "SE 12km/h"
    final windLabel = "${_getCardinalDirection(windDir)} ${avgWind.round()}km/h";
    
    // Temp: "26°"
    final tempLabel = "${temp.round()}°";

    return DailySummary(
      headline: headline,
      subHeadline: subHeadline,
      waveLabel: waveLabel,
      windLabel: windLabel,
      tempLabel: tempLabel,
      weatherIcon: "sun", // placeholder
    );
  }

  /// Finds better surf opportunities in the future
  static List<BetterConditionOption> findBetterConditions(SurfForecast forecast) {
    final now = DateTime.now();
    final options = <BetterConditionOption>[];
    
    // Look at next 3 days
    for (int i = 0; i < 3; i++) {
      final targetDay = now.add(Duration(days: i));
      final dayConditions = forecast.getConditionsForDay(targetDay);
      
      if (dayConditions.isEmpty) continue;

      // Find best individual hour for this day
      SurfConditions? bestHour;
      int bestHourScore = -1;

      for (final c in dayConditions) {
        // Skip past hours for "Today"
        if (i == 0 && c.timestamp.isBefore(now)) continue;
        
        // Skip non-daylight hours (approx 6am - 6pm)
        if (c.timestamp.hour < 6 || c.timestamp.hour >= 18) continue;
        
        final score = c.getQualityScore(forecast.tideData);
        if (score > bestHourScore) {
          bestHourScore = score;
          bestHour = c;
        }
      }

      if (bestHour != null && bestHourScore > 50) {
          final dayName = i == 0 ? "Today" : i == 1 ? "Tomorrow" : _getDayName(targetDay.weekday);
          
          final hour = bestHour.timestamp.hour;
          final period = hour >= 12 ? 'pm' : 'am';
          final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

          options.add(BetterConditionOption(
            timeLabel: "$dayName, $displayHour$period",
            chanceLabel: "$bestHourScore% quality",
            timestamp: bestHour.timestamp,
            waveHeight: bestHour.waveHeight,
            wavePeriod: bestHour.wavePeriod,
            windSpeed: bestHour.windSpeed,
            // TODO: Add tide type lookup if needed, for now leaving null or simple
            tideType: null, 
          ));
      }
      
      // If we already have enough, stop
      if (options.length >= 3) break;
    }
    
    // Fallback if no "Good" days found, just show the best available
    if (options.isEmpty) {
       // Find the absolute best hour in the next 48 hours
       SurfConditions? best;
       int bestScore = -1;
       
       for (final c in forecast.hourlyConditions) {
         if (c.timestamp.isBefore(now)) continue;
         if (c.timestamp.difference(now).inHours > 48) break;
         
         // Skip non-daylight hours (approx 6am - 6pm)
         if (c.timestamp.hour < 6 || c.timestamp.hour >= 18) continue;
         
         final score = c.getQualityScore(forecast.tideData);
         if (score > bestScore) {
           bestScore = score;
           best = c;
         }
       }
       
       if (best != null) {
          final dayName = best.timestamp.day == now.day ? "Today" : "Tomorrow";
          final hour = best.timestamp.hour;
          final period = hour >= 12 ? 'pm' : 'am';
          final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
          
          options.add(BetterConditionOption(
            timeLabel: "$dayName, $displayHour$period",
            chanceLabel: "$bestScore% quality",
            timestamp: best.timestamp,
            waveHeight: best.waveHeight,
            wavePeriod: best.wavePeriod,
            windSpeed: best.windSpeed,
            tideType: null,
          ));
       }
    }

    return options;
  }

  static String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }
  
  static String _getCardinalDirection(double degrees) {
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
