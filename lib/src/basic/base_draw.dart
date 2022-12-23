part of kakao_map_plugin;

class BaseDraw {
  int? strokeWidth;
  Color? strokeColor;
  double? strokeOpacity;
  StrokeStyle? strokeStyle;
  Color? fillColor;
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
