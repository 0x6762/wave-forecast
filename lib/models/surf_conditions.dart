import 'tide_data.dart';

class SurfConditions {
  final DateTime timestamp;
  final double waveHeight; // meters
  final double wavePeriod; // seconds
  final double waveDirection; // degrees
  final double windSpeed; // km/h
  final double windDirection; // degrees
  final double waterTemperature; // celsius
  final double airTemperature; // celsius
  final String weatherDescription;

  SurfConditions({
    required this.timestamp,
    required this.waveHeight,
    required this.wavePeriod,
    required this.waveDirection,
    required this.windSpeed,
    required this.windDirection,
    required this.waterTemperature,
    required this.airTemperature,
    required this.weatherDescription,
  });

  // Helper method to determine surf quality
  String get surfQuality {
    if (waveHeight < 0.5) return 'Flat';
    if (waveHeight < 1.0) return 'Small';
    if (waveHeight < 1.5) return 'Fun';
    if (waveHeight < 2.5) return 'Good';
    if (waveHeight < 3.5) return 'Epic';
    return 'Pumping';
  }

  /// Numeric score from 0 to 100 indicating surf quality
  /// Optionally considers tide data if provided
  int getQualityScore([TideData? tideData]) {
    double score = 0;

    // Wave Height (Max 30 points)
    // Adjusted to be stricter. Ideal range: 1.2m - 2.5m
    if (waveHeight < 0.5) score += 0;       // Too small (was 5)
    else if (waveHeight < 0.8) score += 10; // Small loggable (was 15)
    else if (waveHeight < 1.2) score += 20; // Fun (was 25)
    else if (waveHeight < 2.0) score += 30; // Perfect size (was 40)
    else if (waveHeight < 3.0) score += 25; // Getting big (was 35)
    else score += 15;                       // Too big for most (was 30)

    // Wave Period (Max 25 points)
    // Heavily penalized short periods
    if (wavePeriod < 6) score += 0;         // Chop (was 5)
    else if (wavePeriod < 8) score += 5;    // Weak windswell (was 10)
    else if (wavePeriod < 10) score += 15;  // Decent (was 20)
    else if (wavePeriod < 12) score += 20;  // Good (was 25)
    else score += 25;                       // Groundswell (was 30)

    // Wind Speed (Max 35 points)
    // CRITICAL FACTOR: Onshore wind ruins surf quickly
    if (windSpeed < 5) score += 35;         // Glassy (was 30)
    else if (windSpeed < 10) score += 30;   // Light (was 25)
    else if (windSpeed < 15) score += 20;   // Texture (was 20)
    else if (windSpeed < 20) score += 5;    // Choppy (was 10) - Huge penalty
    else if (windSpeed < 25) score += 0;    // Blown out (was 5)
    else score -= 10;                       // Stormy (Negative score)

    // Tide Factor (Bonus -10 to +10 points)
    // Mid-tide rising is generally best (+10)
    // Dead low or dead high is generally worst (-5)
    if (tideData != null) {
      score += _calculateTideScore(tideData);
    }

    return score.clamp(0, 100).toInt();
  }

  int _calculateTideScore(TideData tideData) {
    // Find the tide events surrounding this timestamp
    final surroundingTides = _findSurroundingTides(tideData);
    if (surroundingTides.length < 2) return 0;

    final previousTide = surroundingTides[0];
    final nextTide = surroundingTides[1];

    // Calculate where we are in the tide cycle (0.0 = previous, 1.0 = next)
    final totalDuration = nextTide.timestamp.difference(previousTide.timestamp).inMinutes;
    final timeSincePrevious = timestamp.difference(previousTide.timestamp).inMinutes;
    
    if (totalDuration == 0) return 0;
    final progress = timeSincePrevious / totalDuration;

    // Determine if rising or falling
    final isRising = previousTide.type == TideType.low;

    // Mid-tide is roughly 25% to 75% of the way through
    final isMidTide = progress > 0.25 && progress < 0.75;

    if (isMidTide && isRising) {
      return 10; // Best case: Mid-tide rising (pushing)
    } else if (isMidTide && !isRising) {
      return 5; // Good case: Mid-tide falling
    } else {
      return -5; // Slack tide (dead low or dead high) often slow
    }
  }

  List<TideExtreme> _findSurroundingTides(TideData tideData) {
    // Sort tides chronologically just in case
    final sorted = List<TideExtreme>.from(tideData.extremes)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    for (int i = 0; i < sorted.length - 1; i++) {
      if (sorted[i].timestamp.isBefore(timestamp) && 
          sorted[i+1].timestamp.isAfter(timestamp)) {
        return [sorted[i], sorted[i+1]];
      }
    }
    return [];
  }

  // Check if wind is offshore (generally better for surfing)
  bool isOffshore(double beachOrientation) {
    final diff = (windDirection - beachOrientation).abs();
    return diff > 135 && diff < 225; // Roughly offshore
  }

  @override
  String toString() {
    return 'SurfConditions(wave: ${waveHeight}m, period: ${wavePeriod}s, wind: ${windSpeed}km/h)';
  }
}
