/// Represents tide data for a specific location and time period
class TideData {
  final String stationId;
  final String stationName;
  final double latitude;
  final double longitude;
  final double distanceFromRequest; // km from requested location to station
  final List<TideExtreme> extremes; // High and low tides
  final DateTime fetchedAt;

  TideData({
    required this.stationId,
    required this.stationName,
    required this.latitude,
    required this.longitude,
    required this.distanceFromRequest,
    required this.extremes,
    required this.fetchedAt,
  });

  /// Get next high tide
  TideExtreme? getNextHighTide() {
    final now = DateTime.now();
    final futureTides = extremes
        .where((e) => e.type == TideType.high && e.timestamp.isAfter(now))
        .toList();
    
    if (futureTides.isEmpty) return null;
    futureTides.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return futureTides.first;
  }

  /// Get next low tide
  TideExtreme? getNextLowTide() {
    final now = DateTime.now();
    final futureTides = extremes
        .where((e) => e.type == TideType.low && e.timestamp.isAfter(now))
        .toList();
    
    if (futureTides.isEmpty) return null;
    futureTides.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return futureTides.first;
  }

  /// Get the next two tide extremes (in chronological order)
  List<TideExtreme> getNextTwoTides() {
    final now = DateTime.now();
    final futureTides = extremes
        .where((e) => e.timestamp.isAfter(now))
        .toList();
    
    if (futureTides.isEmpty) return [];
    futureTides.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    // Return first two (or less if not available)
    return futureTides.take(2).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'station_id': stationId,
      'station_name': stationName,
      'latitude': latitude,
      'longitude': longitude,
      'distance_from_request': distanceFromRequest,
      'extremes': extremes.map((e) => e.toJson()).toList(),
      'fetched_at': fetchedAt.toIso8601String(),
    };
  }

  factory TideData.fromJson(Map<String, dynamic> json) {
    return TideData(
      stationId: json['station_id'] as String,
      stationName: json['station_name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      distanceFromRequest: (json['distance_from_request'] as num).toDouble(),
      extremes: (json['extremes'] as List)
          .map((e) => TideExtreme.fromJson(e as Map<String, dynamic>))
          .toList(),
      fetchedAt: DateTime.parse(json['fetched_at'] as String),
    );
  }
}

/// A single point in the tide data (height at a specific time)
class TidePoint {
  final DateTime timestamp;
  final double height; // meters

  TidePoint({
    required this.timestamp,
    required this.height,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'height': height,
    };
  }

  factory TidePoint.fromJson(Map<String, dynamic> json) {
    return TidePoint(
      timestamp: DateTime.parse(json['timestamp'] as String),
      height: (json['height'] as num).toDouble(),
    );
  }
}

/// High or low tide event
class TideExtreme {
  final DateTime timestamp;
  final double height; // meters
  final TideType type;

  TideExtreme({
    required this.timestamp,
    required this.height,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'height': height,
      'type': type.toString().split('.').last,
    };
  }

  factory TideExtreme.fromJson(Map<String, dynamic> json) {
    return TideExtreme(
      timestamp: DateTime.parse(json['timestamp'] as String),
      height: (json['height'] as num).toDouble(),
      type: json['type'] == 'high' ? TideType.high : TideType.low,
    );
  }
}

enum TideType {
  high,
  low,
}

