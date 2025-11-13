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
  
  // Optional tide information
  final double? tideHeight; // meters (can be null if tide data unavailable)
  final bool? isTideRising; // true = rising, false = falling

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
    this.tideHeight,
    this.isTideRising,
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

