class LocationSearchResult {
  final String displayName;
  final double latitude;
  final double longitude;
  final String type;
  final double importance;
  final Map<String, dynamic>? address;

  LocationSearchResult({
    required this.displayName,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.importance,
    this.address,
  });

  factory LocationSearchResult.fromJson(Map<String, dynamic> json) {
    return LocationSearchResult(
      displayName: json['display_name'] as String? ?? '',
      latitude: double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['lon']?.toString() ?? '0') ?? 0.0,
      type: json['type'] as String? ?? '',
      importance: double.tryParse(json['importance']?.toString() ?? '0') ?? 0.0,
      address: json['address'] as Map<String, dynamic>?,
    );
  }

  /// Get a clean, user-friendly name (max 3 parts: location, state, country)
  String get cleanName {
    // Try to build name from address components first (more accurate)
    if (address != null) {
      final parts = <String>[];
      
      // Get location name (prefer specific to general)
      final name = address!['beach'] as String? ??
          address!['suburb'] as String? ??
          address!['neighbourhood'] as String? ??
          address!['city'] as String? ??
          address!['town'] as String? ??
          address!['village'] as String? ??
          address!['municipality'] as String?;
      
      // Get state (skip region)
      final state = address!['state'] as String?;
      
      // Get country
      final country = address!['country'] as String?;
      
      if (name != null && name.isNotEmpty) parts.add(name);
      if (state != null && state.isNotEmpty && state != name) parts.add(state);
      if (country != null && country.isNotEmpty) parts.add(country);
      
      if (parts.isNotEmpty) {
        return parts.join(', ');
      }
    }
    
    // Fallback to parsing display_name
    final parts = displayName.split(', ');
    
    if (parts.isEmpty) return displayName;
    
    if (parts.length <= 2) {
      return displayName;
    } else if (parts.length == 3) {
      return displayName;
    } else {
      // Take: first (location), second-to-last (hopefully state), last (country)
      final location = parts.first;
      final region = parts[parts.length - 2];
      final country = parts.last;
      
      // Avoid duplicates
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

