part of kakao_map_plugin;

class ClustererStyle {
  /// cluster width
  int? width;

  /// cluster height
  int? height;

  /// cluster background color
  String? background;

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
    this.color,
    this.textAlign,
    this.lineHeight,
  });
}
