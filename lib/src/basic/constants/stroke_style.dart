/// 선 스타일을 나타내는 열거형입니다.
///
/// 지도 위에 그려지는 도형(선, 다각형 등)의 테두리 선 스타일을 정의합니다.
/// 패턴에 따라 11종류의 스타일을 제공합니다.
///
/// 참고: https://apis.map.kakao.com/web/documentation/#StrokeStyles
enum StrokeStyle {
  /// 실선 (기본값)
  solid('solid'),

  /// 짧은 대시선
  shortDash('shortdash'),

  /// 짧은 점선
  shortDot('shortdot'),

  /// 짧은 대시-점선
  shortDashDot('shortdashdot'),

  /// 짧은 대시-점-점선
  shortDashDotDot('shortdashdotdot'),

  /// 점선
  dot('dot'),

  /// 대시선
  dash('dash'),

  /// 대시-점선
  dashDot('dashdot'),

  /// 긴 대시선
  longDash('longdash'),

  /// 긴 대시-점선
  longDashDot('longdashdot'),

  /// 긴 대시-점-점선
  longDashDotDot('longdashdotdot');

  const StrokeStyle(this.name);

  /// 스타일 이름
  final String name;

  /// 이름으로 선 스타일을 찾습니다.
  ///
  /// [styleName] 찾을 스타일의 이름
  /// 해당하는 이름이 없으면 [StrokeStyle.solid]를 반환합니다.
  factory StrokeStyle.getByName(String styleName) {
    return StrokeStyle.values.firstWhere((value) => value.name == styleName,
        orElse: () => StrokeStyle.solid);
  }
}
