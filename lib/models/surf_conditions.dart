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
  /// This is a simplified algorithm for demonstration
  int get qualityScore {
    double score = 0;

    // Wave Height (0-40 points)
    // Ideal range: 1.5m - 3.0m
    if (waveHeight < 0.5) score += 5;
    else if (waveHeight < 1.0) score += 15;
    else if (waveHeight < 1.5) score += 25;
    else if (waveHeight < 2.5) score += 40;
    else if (waveHeight < 3.5) score += 35; // Getting too big for some
    else score += 30;

    // Wave Period (0-30 points)
    // Longer period is better
    if (wavePeriod < 6) score += 5;
    else if (wavePeriod < 8) score += 10;
    else if (wavePeriod < 10) score += 20;
    else if (wavePeriod < 12) score += 25;
    else score += 30;

    // Wind Speed (0-30 points)
    // Lower wind is better
    if (windSpeed < 5) score += 30;
    else if (windSpeed < 10) score += 25;
    else if (windSpeed < 15) score += 20;
    else if (windSpeed < 20) score += 10;
    else if (windSpeed < 30) score += 5;
    else score += 0;

    return score.clamp(0, 100).toInt();
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
