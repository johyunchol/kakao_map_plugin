part of kakao_map_plugin;

class LatLngBounds {
  LatLng sw;
  LatLng ne;

  LatLngBounds(this.sw, this.ne);

  factory LatLngBounds.fromJson(Map<String, dynamic> json) => _$LatLngBoundsFromJson(json);

  Map<String, dynamic> toJson() => _$LatLngBoundsToJson(this);

  LatLng getSouthWest() => sw;

  LatLng getNorthEast() => ne;

  @override
  String toString() {
    return 'LatLngBounds{sw: $sw, ne: $ne}';
  }
}

LatLngBounds _$LatLngBoundsFromJson(Map<String, dynamic> json) => LatLngBounds(
  json['sw'] as LatLng,
  json['ne'] as LatLng,
);

Map<String, dynamic> _$LatLngBoundsToJson(LatLngBounds instance) => <String, dynamic>{
  'sw': instance.sw,
  'ne': instance.ne,
};
