part of '../../kakao_map_plugin.dart';

class ClustererStyle {
  /// cluster width
  int? width;

  /// cluster height
  int? height;

  /// cluster background color
  Color? background;

  /// cluster background border radius
  int? borderRadius;

  /// cluster color
  Color? color;

  /// cluster text align
  String? textAlign;

  /// cluster line height
  int? lineHeight;

  ClustererStyle({
    this.width,
    this.height,
    this.background,
    this.borderRadius = 0,
    this.color,
    this.textAlign,
    this.lineHeight,
  });

  Map<String, dynamic> toJson() {
    return {
      'width': '${width}px',
      'height': '${height}px',
      'background': background?.toHexColorWithAlpha(),
      'borderRadius': '${borderRadius}px',
      'color': color?.toHexColor(),
      'textAlign': textAlign,
      'lineHeight': '${lineHeight}px',
    };
  }
}
