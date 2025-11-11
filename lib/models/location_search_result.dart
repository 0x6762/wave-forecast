class LocationSearchResult {
  final String displayName;
  final double latitude;
  final double longitude;
  final String type;
  final double importance;

  LocationSearchResult({
    required this.displayName,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.importance,
  });

  factory LocationSearchResult.fromJson(Map<String, dynamic> json) {
    return LocationSearchResult(
      displayName: json['display_name'] as String? ?? '',
      latitude: double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['lon']?.toString() ?? '0') ?? 0.0,
      type: json['type'] as String? ?? '',
      importance: double.tryParse(json['importance']?.toString() ?? '0') ?? 0.0,
    );
  }

  /// Get a clean, user-friendly name (max 3 parts: location, region, country)
  String get cleanName {
    final parts = displayName.split(', ');
    
    if (parts.isEmpty) return displayName;
    
    // Take first part (main location), maybe middle part, and last part (country)
    if (parts.length <= 2) {
      return displayName; // Short enough already
    } else if (parts.length == 3) {
      return displayName; // Perfect length
    } else {
      // Take: first (location), second-to-last (state/region), last (country)
      final location = parts.first;
      final region = parts[parts.length - 2];
      final country = parts.last;
      
      // Avoid duplicates (e.g., "Rio de Janeiro, Rio de Janeiro, Brasil")
      if (location == region) {
        return '$location, $country';
      }
      
      return '$location, $region, $country';
    }
  }

  @override
  String toString() {
    return 'LocationSearchResult($displayName, $latitude, $longitude)';
  }
}

