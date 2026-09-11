import 'package:flutter/painting.dart';

import 'hex_color.dart';

/// 마커 인포윈도우의 모양입니다.
///
/// 지정하면 카카오 SDK 기본 인포윈도우(흰 사각형 + 남색 테두리 + gif 닫기 버튼) 대신
/// 플러그인이 같은 위치에 앱 스타일의 말풍선을 그립니다. 마커별로
/// [Marker.infoWindowStyle] 에 주거나, [KakaoMapTheme.infoWindowStyle] 로 지도 전체
/// 기본값을 정할 수 있습니다. 지정하지 않으면 기존과 같은 SDK 기본 모양입니다.
///
/// 예시:
/// ```dart
/// Marker(
///   markerId: 'm1',
///   latLng: LatLng(37.5665, 126.9780),
///   infoWindowContent: '<b>서울시청</b><br>02-120',
///   infoWindowStyle: const InfoWindowStyle.material(),
/// )
/// ```
class InfoWindowStyle {
  /// 배경색입니다.
  final Color backgroundColor;

  /// 글자색입니다. 콘텐츠 HTML 이 색을 직접 지정하면 그 값이 우선합니다.
  final Color textColor;

  /// 테두리 색입니다. null 이면 테두리가 없습니다.
  final Color? borderColor;

  /// 모서리 반지름(px)입니다.
  final double borderRadius;

  /// 안쪽 여백입니다.
  final EdgeInsets padding;

  /// 기본 글자 크기(px)입니다.
  final double fontSize;

  /// 최대 너비(px)입니다. null 이면 한 줄로 늘어납니다.
  final double? maxWidth;

  /// 그림자를 그릴지 여부입니다.
  final bool shadow;

  /// 마커를 가리키는 꼬리를 그릴지 여부입니다.
  final bool showArrow;

  /// 꼬리 크기(px)입니다.
  final double arrowSize;

  /// 마커 위로 띄울 간격(px)입니다.
  final double gap;

  /// 인포윈도우 스타일을 만듭니다.
  const InfoWindowStyle({
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.textColor = const Color(0xFF191919),
    this.borderColor,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    this.fontSize = 14,
    this.maxWidth,
    this.shadow = true,
    this.showArrow = true,
    this.arrowSize = 8,
    this.gap = 6,
  });

  /// Material 느낌: 흰 카드, 둥근 모서리, 은은한 그림자.
  const InfoWindowStyle.material({Color? backgroundColor, Color? textColor})
      : this(
          backgroundColor: backgroundColor ?? const Color(0xFFFFFFFF),
          textColor: textColor ?? const Color(0xFF191919),
          borderRadius: 12,
        );

  /// iOS 느낌: 밝은 회색 카드, 가는 테두리, 큰 모서리.
  const InfoWindowStyle.cupertino()
      : this(
          backgroundColor: const Color(0xFFF9F9F9),
          textColor: const Color(0xFF000000),
          borderColor: const Color(0xFFD1D1D6),
          borderRadius: 14,
          fontSize: 15,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        );

  /// 어두운 카드.
  const InfoWindowStyle.dark()
      : this(
          backgroundColor: const Color(0xFF1C1C1E),
          textColor: const Color(0xFFFFFFFF),
          borderRadius: 12,
        );

  /// JS 로 전달할 Map 으로 변환합니다.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'backgroundColor': backgroundColor.toCssColor(),
        'textColor': textColor.toCssColor(),
        if (borderColor != null) 'borderColor': borderColor!.toCssColor(),
        'borderRadius': borderRadius,
        'padding':
            '${padding.top}px ${padding.right}px ${padding.bottom}px ${padding.left}px',
        'fontSize': fontSize,
        if (maxWidth != null) 'maxWidth': maxWidth,
        'shadow': shadow,
        'showArrow': showArrow,
        'arrowSize': arrowSize,
        'gap': gap,
      };

  @override
  bool operator ==(Object other) =>
      other is InfoWindowStyle &&
      other.backgroundColor == backgroundColor &&
      other.textColor == textColor &&
      other.borderColor == borderColor &&
      other.borderRadius == borderRadius &&
      other.padding == padding &&
      other.fontSize == fontSize &&
      other.maxWidth == maxWidth &&
      other.shadow == shadow &&
      other.showArrow == showArrow &&
      other.arrowSize == arrowSize &&
      other.gap == gap;

  @override
  int get hashCode => Object.hash(
      backgroundColor,
      textColor,
      borderColor,
      borderRadius,
      padding,
      fontSize,
      maxWidth,
      shadow,
      showArrow,
      arrowSize,
      gap);
}
