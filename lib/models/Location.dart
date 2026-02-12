class Location {
  
  double? latitude;
  double? longitude;
  double? fenceDiameter;
  double? fenceCenterLatitude;
  double? fenceCenterLongitude;
  bool outOfFence;
  bool geoFence;

  
  
  Location({
    this.latitude,
    this.longitude,
    this.fenceDiameter,
    this.fenceCenterLatitude,
    this.fenceCenterLongitude,
    this.outOfFence = false,
    this.geoFence = false,
  });

  
  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      fenceDiameter: (map['fenceDiameter'] as num?)?.toDouble(),
      fenceCenterLatitude: (map['fenceCenterLatitude'] as num?)?.toDouble(),
      fenceCenterLongitude: (map['fenceCenterLongitude'] as num?)?.toDouble(),
      outOfFence: map['outOfFence'] ?? false,
      geoFence: map['geoFence'] ?? false,
    );
  }

  
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'fenceDiameter': fenceDiameter,
      'fenceCenterLatitude': fenceCenterLatitude,
      'fenceCenterLongitude': fenceCenterLongitude,
      'outOfFence': outOfFence,
      'geoFence': geoFence,
    };
  }
}