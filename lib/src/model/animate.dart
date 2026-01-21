part of '../../kakao_map_plugin.dart';

/// 지도 애니메이션 효과 설정을 나타내는 클래스입니다.
///
/// 지도의 이동, 확대/축소 등의 동작에 애니메이션 효과를 적용할 때 사용됩니다.
/// 애니메이션의 지속 시간을 밀리초(ms) 단위로 지정할 수 있습니다.
///
/// 예시:
/// ```dart
/// // 500ms 동안 부드럽게 이동
/// final animate = Animate(duration: 500);
///
/// // 애니메이션 없이 즉시 이동 (duration: 0)
/// final noAnimate = Animate(duration: 0);
/// ```
class Animate {
  /// 애니메이션 효과의 지속 시간입니다 (단위: 밀리초).
  ///
  /// - 0: 애니메이션 없이 즉시 실행
  /// - 양수: 지정된 시간 동안 부드럽게 애니메이션
  ///
  /// 일반적으로 300~500ms 사이의 값이 자연스러운 애니메이션을 제공합니다.
  ///
  /// 예시:
  /// ```dart
  /// final quickAnimate = Animate(duration: 300);  // 빠른 애니메이션
  /// final smoothAnimate = Animate(duration: 500);  // 부드러운 애니메이션
  /// final slowAnimate = Animate(duration: 1000);   // 느린 애니메이션
  /// ```
  final int duration;

  /// [duration]을 받아 Animate 객체를 생성합니다.
  ///
  /// [duration]은 밀리초(ms) 단위로 지정합니다.
  ///
  /// 예시:
  /// ```dart
  /// final animate = Animate(duration: 500);
  /// ```
  Animate({
    required this.duration,
  });

  /// JSON Map으로부터 Animate 객체를 생성합니다.
  ///
  /// [json]은 'duration' 키를 포함해야 합니다.
  ///
  /// 예시:
  /// ```dart
  /// final json = {'duration': 500};
  /// final animate = Animate.fromJson(json);
  /// ```
  factory Animate.fromJson(Map<String, dynamic> json) =>
      _$AnimateFromJson(json);

  /// Animate 객체를 JSON Map으로 변환합니다.
  ///
  /// 반환값은 'duration' 키를 포함합니다.
  ///
  /// 예시:
  /// ```dart
  /// final animate = Animate(duration: 500);
  /// final json = animate.toJson();
  /// // {"duration": 500}
  /// ```
  Map<String, dynamic> toJson() => _$AnimateToJson(this);

  /// Animate 객체의 문자열 표현을 반환합니다.
  ///
  /// 디버깅 및 로깅 용도로 사용됩니다.
  @override
  String toString() {
    return 'Animate{duration: $duration}';
  }
}

Animate _$AnimateFromJson(Map<String, dynamic> json) => Animate(
      duration: json['duration'] as int,
    );

Map<String, dynamic> _$AnimateToJson(Animate instance) => <String, dynamic>{
      'duration': instance.duration,
    };
