part of '../../kakao_map_plugin.dart';

/// 지도 확대/축소 레벨 변경 시 적용할 옵션을 나타내는 클래스입니다.
///
/// 지도의 확대 수준(zoom level)을 변경할 때 애니메이션 효과와 기준 좌표를 지정할 수 있습니다.
///
/// 예시:
/// ```dart
/// // 애니메이션과 함께 특정 위치를 중심으로 확대
/// final options = LevelOptions(
///   animate: Animate(duration: 500),
///   anchor: LatLng(37.5665, 126.9780),
/// );
///
/// // 애니메이션 없이 즉시 확대
/// final quickOptions = LevelOptions();
/// ```
class LevelOptions {
  /// 지도 확대수준 변경 시 적용할 애니메이션 효과입니다.
  ///
  /// null인 경우 애니메이션 없이 즉시 변경됩니다.
  ///
  /// 주의: 현재 지도 레벨과의 차이가 2 이하인 경우에만 애니메이션 효과가 적용됩니다.
  /// 레벨 차이가 3 이상인 경우 애니메이션 없이 즉시 변경됩니다.
  ///
  /// 예시:
  /// ```dart
  /// // 부드러운 애니메이션 효과
  /// final options = LevelOptions(
  ///   animate: Animate(duration: 500),
  /// );
  ///
  /// // 애니메이션 없음
  /// final noAnimateOptions = LevelOptions();
  /// ```
  Animate? animate;

  /// 지도 확대수준 변경 시 기준이 되는 좌표입니다.
  ///
  /// null인 경우 지도의 중심점을 기준으로 확대/축소됩니다.
  /// 값이 있는 경우 해당 좌표를 중심으로 확대/축소됩니다.
  ///
  /// 예시:
  /// ```dart
  /// // 서울 시청을 중심으로 확대
  /// final options = LevelOptions(
  ///   anchor: LatLng(37.5665, 126.9780),
  /// );
  ///
  /// // 현재 지도 중심을 기준으로 확대
  /// final centerOptions = LevelOptions();
  /// ```
  LatLng? anchor;

  /// [animate]와 [anchor]를 받아 LevelOptions 객체를 생성합니다.
  ///
  /// 모든 매개변수는 선택사항입니다.
  ///
  /// 예시:
  /// ```dart
  /// // 모든 옵션 지정
  /// final fullOptions = LevelOptions(
  ///   animate: Animate(duration: 500),
  ///   anchor: LatLng(37.5665, 126.9780),
  /// );
  ///
  /// // 기본 옵션 사용
  /// final defaultOptions = LevelOptions();
  /// ```
  LevelOptions({
    this.animate,
    this.anchor,
  });

  /// JSON Map으로부터 LevelOptions 객체를 생성합니다.
  ///
  /// [json]은 선택적으로 'animate'와 'anchor' 키를 포함할 수 있습니다.
  factory LevelOptions.fromJson(Map<String, dynamic> json) =>
      _$LevelOptionsFromJson(json);

  /// LevelOptions 객체를 JSON Map으로 변환합니다.
  ///
  /// 반환값은 null이 아닌 필드만 포함합니다.
  Map<String, dynamic> toJson() => _$LevelOptionsToJson(this);

  /// LevelOptions 객체의 문자열 표현을 반환합니다.
  ///
  /// 디버깅 및 로깅 용도로 사용됩니다.
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
