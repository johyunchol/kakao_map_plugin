import 'dart:ui' show Color;

import 'hex_color.dart';
import 'info_window_style.dart';

/// 지도 문서 전체에 적용되는 모양 기본값입니다.
///
/// 앱 전역은 `AuthRepository.initialize(theme:)`, 지도별로는 `KakaoMap(theme:)` 으로
/// 지정합니다. 지정하지 않은 항목은 플러그인 기본값(시스템 글꼴, SDK 기본 배경,
/// SDK 기본 인포윈도우)을 씁니다.
///
/// 예시:
/// ```dart
/// AuthRepository.initialize(
///   appKey: '...',
///   theme: const KakaoMapTheme(
///     infoWindowStyle: InfoWindowStyle.material(),
///     backgroundColor: Color(0xFFF5F5F5),
///   ),
/// );
/// ```
class KakaoMapTheme {
  /// 지도 문서의 글꼴입니다. CSS `font-family` 값 그대로 씁니다.
  ///
  /// null 이면 플러그인 기본 시스템 글꼴 스택을 씁니다.
  final String? fontFamily;

  /// 타일이 뜨기 전 보이는 지도 배경색입니다. null 이면 SDK 기본(회색 격자)입니다.
  final Color? backgroundColor;

  /// 이 지도의 마커 인포윈도우 기본 스타일입니다. [Marker.infoWindowStyle] 이 우선합니다.
  final InfoWindowStyle? infoWindowStyle;

  /// 지도 문서에 추가로 넣을 CSS 입니다. 커스텀 오버레이 공통 스타일 등에 씁니다.
  final String? customCss;

  /// 테마를 만듭니다.
  const KakaoMapTheme({
    this.fontFamily,
    this.backgroundColor,
    this.infoWindowStyle,
    this.customCss,
  });

  /// 문서 `<style>` 에 넣을 CSS 를 만듭니다.
  String toCss() {
    final buffer = StringBuffer();
    if (fontFamily != null) {
      buffer.writeln('    body { font-family: $fontFamily; }');
    }
    if (backgroundColor != null) {
      // SDK 가 #map 에 인라인으로 격자 배경을 넣으므로 !important 가 필요합니다.
      buffer.writeln(
          '    #map { background: ${backgroundColor!.toCssColor()} !important; }');
    }
    if (customCss != null) buffer.writeln(customCss);
    return buffer.toString();
  }
}
