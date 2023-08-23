part of kakao_map_plugin;

/// kakao map latitude, longtitude
class LatLng {
  /// latitude
  double latitude;

  /// longitude
  double longitude;

  LatLng(this.latitude, this.longitude);

  factory LatLng.fromJson(Map<String, dynamic> json) => _$LatLngFromJson(json);

  Map<String, dynamic> toJson() => _$LatLngToJson(this);

  @override
  String toString() {
    return 'LatLng{latitude: $latitude, longitude: $longitude}';
  }
}

LatLng _$LatLngFromJson(Map<String, dynamic> json) => LatLng(
      json['latitude'] as double,
      json['longitude'] as double,
    );

Map<String, dynamic> _$LatLngToJson(LatLng instance) => <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
