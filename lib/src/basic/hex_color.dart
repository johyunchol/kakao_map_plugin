part of '../../kakao_map_plugin.dart';

/// Color 클래스를 위한 16진수 변환 확장 메서드입니다.
///
/// 16진수 문자열과 Color 객체 간의 변환 기능을 제공합니다.
extension HexColor on Color {
  /// 16진수 문자열을 Color 객체로 변환합니다.
  ///
  /// [hexString] 변환할 16진수 색상 코드
  /// - 형식: "aabbcc" 또는 "ffaabbcc" (선택적으로 "#" 접두사 가능)
  /// - 6자리 또는 7자리(# 포함)인 경우 자동으로 불투명도(ff)가 추가됩니다.
  ///
  /// 예시:
  /// ```dart
  /// Color color1 = HexColor.fromHex("#FF5733");
  /// Color color2 = HexColor.fromHex("FF5733");
  /// Color color3 = HexColor.fromHex("#AABBCCDD"); // 투명도 포함
  /// ```
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Color 객체를 투명도를 포함한 16진수 문자열로 변환합니다.
  ///
  /// [leadingHashSign] true이면 "#" 접두사를 추가합니다 (기본값: true)
  ///
  /// 반환 형식: "#AARRGGBB" (A: 투명도, R: 빨강, G: 녹색, B: 파랑)
  ///
  /// 예시:
  /// ```dart
  /// String hex1 = color.toHexColorWithAlpha(); // "#FFAABBCC"
  /// String hex2 = color.toHexColorWithAlpha(leadingHashSign: false); // "FFAABBCC"
  /// ```
  String toHexColorWithAlpha({bool leadingHashSign = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${(a * 255).toInt().toRadixString(16).padLeft(2, '0')}'
      '${(r * 255).toInt().toRadixString(16).padLeft(2, '0')}'
      '${(g * 255).toInt().toRadixString(16).padLeft(2, '0')}'
      '${(b * 255).toInt().toRadixString(16).padLeft(2, '0')}';

  /// Color 객체를 16진수 문자열로 변환합니다 (투명도 제외).
  ///
  /// [leadingHashSign] true이면 "#" 접두사를 추가합니다 (기본값: true)
  ///
  /// 반환 형식: "#RRGGBB" (R: 빨강, G: 녹색, B: 파랑)
  ///
  /// 예시:
  /// ```dart
  /// String hex1 = color.toHexColor(); // "#AABBCC"
  /// String hex2 = color.toHexColor(leadingHashSign: false); // "AABBCC"
  /// ```
  String toHexColor({bool leadingHashSign = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${(r * 255).toInt().toRadixString(16).padLeft(2, '0')}'
      '${(g * 255).toInt().toRadixString(16).padLeft(2, '0')}'
      '${(b * 255).toInt().toRadixString(16).padLeft(2, '0')}';
}
