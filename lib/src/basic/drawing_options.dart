import 'package:flutter/material.dart';

import 'constants/drawing_overlay_type.dart';
import 'constants/stroke_style.dart';
import 'hex_color.dart';

/// Drawing Library 로 그린 도형의 스타일입니다.
///
/// 지정하지 않은 값은 카카오 SDK 기본값을 사용합니다.
///
/// 예시:
/// ```dart
/// const DrawingStyle(
///   strokeColor: Colors.blue,
///   strokeWidth: 3,
///   fillColor: Colors.blue,
///   fillOpacity: 0.3,
/// )
/// ```
class DrawingStyle {
  /// 선 색상입니다.
  final Color? strokeColor;

  /// 선 두께입니다. 단위는 픽셀입니다.
  final int? strokeWidth;

  /// 선 스타일입니다.
  final StrokeStyle? strokeStyle;

  /// 선 불투명도입니다. 0 ~ 1 사이의 값입니다.
  final double? strokeOpacity;

  /// 채우기 색상입니다. 면이 있는 도형에만 적용됩니다.
  final Color? fillColor;

  /// 채우기 불투명도입니다. 0 ~ 1 사이의 값입니다.
  final double? fillOpacity;

  /// 도형 스타일을 생성합니다.
  const DrawingStyle({
    this.strokeColor,
    this.strokeWidth,
    this.strokeStyle,
    this.strokeOpacity,
    this.fillColor,
    this.fillOpacity,
  });

  /// 카카오 SDK 가 사용하는 옵션 Map 으로 변환합니다.
  ///
  /// 지정하지 않은 값은 키 자체를 넣지 않아 SDK 기본값이 적용되게 합니다.
  Map<String, dynamic> toJson() => <String, dynamic>{
        if (strokeColor != null) 'strokeColor': strokeColor!.toHexColor(),
        if (strokeWidth != null) 'strokeWeight': strokeWidth,
        if (strokeStyle != null) 'strokeStyle': strokeStyle!.name,
        if (strokeOpacity != null) 'strokeOpacity': strokeOpacity,
        if (fillColor != null) 'fillColor': fillColor!.toHexColor(),
        if (fillOpacity != null) 'fillOpacity': fillOpacity,
      };

  /// 카카오 SDK 가 돌려준 옵션 Map 으로부터 [DrawingStyle]을 만듭니다.
  factory DrawingStyle.fromJson(Map<String, dynamic> json) => DrawingStyle(
        strokeColor: _parseColor(json['strokeColor']),
        strokeWidth: (json['strokeWeight'] as num?)?.toInt(),
        strokeStyle: json['strokeStyle'] is String
            ? StrokeStyle.values
                .where((e) => e.name == json['strokeStyle'])
                .firstOrNull
            : null,
        strokeOpacity: (json['strokeOpacity'] as num?)?.toDouble(),
        fillColor: _parseColor(json['fillColor']),
        fillOpacity: (json['fillOpacity'] as num?)?.toDouble(),
      );

  static Color? _parseColor(Object? value) {
    if (value is! String || value.isEmpty) return null;
    final hex = value.startsWith('#') ? value.substring(1) : value;
    final parsed = int.tryParse(hex, radix: 16);
    if (parsed == null) return null;
    // #RRGGBB 는 불투명으로 취급합니다.
    return Color(hex.length <= 6 ? 0xFF000000 | parsed : parsed);
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

/// Drawing Library 의 동작 옵션입니다.
///
/// 예시:
/// ```dart
/// await controller.createDrawingManager(
///   options: const DrawingOptions(
///     drawingMode: [
///       DrawingOverlayType.marker,
///       DrawingOverlayType.polyline,
///       DrawingOverlayType.polygon,
///     ],
///     polylineStyle: DrawingStyle(strokeColor: Colors.blue, strokeWidth: 4),
///   ),
/// );
/// ```
class DrawingOptions {
  /// 그릴 수 있는 도형의 종류입니다.
  ///
  /// 비어 있으면 모든 종류를 사용할 수 있습니다.
  final List<DrawingOverlayType> drawingMode;

  /// 그리는 동안 안내 툴팁을 표시할 상황입니다.
  ///
  /// 사용 가능한 값은 `draw`, `drag`, `edit` 입니다.
  final List<String>? guideTooltip;

  /// 마커 도형의 스타일입니다.
  final DrawingStyle? markerStyle;

  /// 선 도형의 스타일입니다.
  final DrawingStyle? polylineStyle;

  /// 사각형 도형의 스타일입니다.
  final DrawingStyle? rectangleStyle;

  /// 원 도형의 스타일입니다.
  final DrawingStyle? circleStyle;

  /// 타원 도형의 스타일입니다.
  final DrawingStyle? ellipseStyle;

  /// 다각형 도형의 스타일입니다.
  final DrawingStyle? polygonStyle;

  /// 화살표 선 도형의 스타일입니다.
  final DrawingStyle? arrowStyle;

  /// Drawing 옵션을 생성합니다.
  const DrawingOptions({
    this.drawingMode = const [],
    this.guideTooltip,
    this.markerStyle,
    this.polylineStyle,
    this.rectangleStyle,
    this.circleStyle,
    this.ellipseStyle,
    this.polygonStyle,
    this.arrowStyle,
  });

  /// JS 로 전달할 Map 으로 변환합니다.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'drawingMode': drawingMode.map((e) => e.value).toList(growable: false),
        if (guideTooltip != null) 'guideTooltip': guideTooltip,
        if (markerStyle != null) 'markerOptions': markerStyle!.toJson(),
        if (polylineStyle != null) 'polylineOptions': polylineStyle!.toJson(),
        if (rectangleStyle != null)
          'rectangleOptions': rectangleStyle!.toJson(),
        if (circleStyle != null) 'circleOptions': circleStyle!.toJson(),
        if (ellipseStyle != null) 'ellipseOptions': ellipseStyle!.toJson(),
        if (polygonStyle != null) 'polygonOptions': polygonStyle!.toJson(),
        if (arrowStyle != null) 'arrowOptions': arrowStyle!.toJson(),
      };
}
