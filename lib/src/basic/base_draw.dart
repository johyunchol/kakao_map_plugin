part of kakao_map_plugin;

class BaseDraw {
  /// stroke width
  int? strokeWidth;

  /// stroke color
  Color? strokeColor;

  /// stroke opacity
  double? strokeOpacity;

  /// stroke style
  StrokeStyle? strokeStyle;

  /// fill color
  Color? fillColor;

  /// fill opacity
  double? fillOpacity;

  BaseDraw({
    this.strokeWidth,
    this.strokeColor,
    this.strokeOpacity,
    this.strokeStyle,
    this.fillColor,
    this.fillOpacity,
  });
}
