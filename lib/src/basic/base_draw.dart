part of '../../kakao_map_plugin.dart';

class BaseDraw {
  /// stroke width
  int? strokeWidth;

  /// stroke color
  Color? strokeColor;

  /// stroke opacity
  double? strokeOpacity;

  /// stroke style
  StrokeStyle? strokeStyle = StrokeStyle.solid;

  /// fill color
  Color? fillColor;

  /// fill opacity
  double? fillOpacity;

  int zIndex = 0;

  BaseDraw({
    this.strokeWidth,
    this.strokeColor,
    this.strokeOpacity,
    this.strokeStyle,
    this.fillColor,
    this.fillOpacity,
    this.zIndex = 0,
  });
}
