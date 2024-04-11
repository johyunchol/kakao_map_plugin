part of '../../kakao_map_plugin.dart';

class LevelOptions {
  /// 지도 확대수준 변경 시 애니메이션 효과 여부 (현재 지도 레벨과의 차이가 2 이하인 경우에만 애니메이션 효과 가능)
  Animate? animate;

  /// 지도 확대수준 변경 시 기준 좌표
  LatLng? anchor;

  LevelOptions({
    this.animate,
    this.anchor,
  });

  factory LevelOptions.fromJson(Map<String, dynamic> json) =>
      _$LevelOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$LevelOptionsToJson(this);

  @override
  String toString() {
    return 'LevelOptions{animate: $animate, anchor: $anchor}';
  }
}

LevelOptions _$LevelOptionsFromJson(Map<String, dynamic> json) => LevelOptions(
      animate:
          json['animate'] == null ? null : Animate.fromJson(json['animate']),
      anchor: json['anchor'] == null ? null : LatLng.fromJson(json['anchor']),
    );

Map<String, dynamic> _$LevelOptionsToJson(LevelOptions instance) =>
    <String, dynamic>{
      'animate': instance.animate?.toJson(),
      'anchor': instance.anchor?.toJson(),
    };
