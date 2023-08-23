part of kakao_map_plugin;

/// StrokeStyle
/// 지도 위에 올라가는 각종 도형의 선 스타일을 의미한다.
/// 스타일은 패턴에 따라 11종류가 있으며 그 값은 문자열로 지정한다.
/// https://apis.map.kakao.com/web/documentation/#StrokeStyles
enum StrokeStyle {
  solid('solid'),
  shortDash('shortdash'),
  shortDot('shortdot'),
  shortDashDot('shortdashdot'),
  shortDashDotDot('shortdashdotdot'),
  dot('dot'),
  dash('dash'),
  dashDot('dashdot'),
  longDash('longdash'),
  longDashDot('longdashdot'),
  longDashDotDot('longdashdotdot');

  const StrokeStyle(this.name);

  final String name;

  factory StrokeStyle.getByName(String styleName) {
    return StrokeStyle.values.firstWhere((value) => value.name == styleName,
        orElse: () => StrokeStyle.solid);
  }
}
