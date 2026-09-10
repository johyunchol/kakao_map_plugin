import '../basic/constants/drawing_overlay_type.dart';
import '../basic/drawing_options.dart';
import '../model/lat_lng.dart';
import '../model/lat_lng_bounds.dart';

/// Drawing Library 로 그린 도형 하나를 나타냅니다.
///
/// 실제 타입에 따라 [DrawingMarkerShape], [DrawingPathShape],
/// [DrawingRectangleShape], [DrawingCircleShape], [DrawingEllipseShape]
/// 중 하나로 만들어집니다.
abstract class DrawingShape {
  /// 도형의 종류입니다.
  final DrawingOverlayType type;

  /// 도형의 스타일입니다. 마커에는 없습니다.
  final DrawingStyle? style;

  const DrawingShape(this.type, this.style);

  /// 카카오 SDK 는 x 가 경도, y 가 위도입니다.
  static LatLng _latLng(Map<String, dynamic> json) => LatLng(
        (json['y'] as num).toDouble(),
        (json['x'] as num).toDouble(),
      );

  static List<LatLng> _latLngList(Object? value) => (value as List? ?? const [])
      .map((e) => _latLng(Map<String, dynamic>.from(e as Map)))
      .toList(growable: false);

  static DrawingStyle? _style(Object? value) => value is Map
      ? DrawingStyle.fromJson(Map<String, dynamic>.from(value))
      : null;
}

/// 그려진 마커입니다.
class DrawingMarkerShape extends DrawingShape {
  /// 마커의 좌표입니다.
  final LatLng position;

  /// 마커의 z-index 입니다.
  final int zIndex;

  /// 마커에 붙은 내용입니다.
  final String content;

  const DrawingMarkerShape({
    required this.position,
    this.zIndex = 0,
    this.content = '',
  }) : super(DrawingOverlayType.marker, null);

  /// JSON 으로부터 생성합니다.
  factory DrawingMarkerShape.fromJson(Map<String, dynamic> json) =>
      DrawingMarkerShape(
        position: DrawingShape._latLng(json),
        zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
        content: json['content']?.toString() ?? '',
      );
}

/// 점들로 이루어진 도형입니다. 선, 다각형, 화살표 선이 여기에 해당합니다.
class DrawingPathShape extends DrawingShape {
  /// 도형을 이루는 좌표 목록입니다.
  final List<LatLng> points;

  const DrawingPathShape({
    required DrawingOverlayType type,
    required this.points,
    DrawingStyle? style,
  }) : super(type, style);

  /// JSON 으로부터 생성합니다.
  factory DrawingPathShape.fromJson(
    DrawingOverlayType type,
    Map<String, dynamic> json,
  ) =>
      DrawingPathShape(
        type: type,
        points: DrawingShape._latLngList(json['points']),
        style: DrawingShape._style(json['options']),
      );
}

/// 그려진 사각형입니다.
class DrawingRectangleShape extends DrawingShape {
  /// 사각형의 영역입니다.
  final LatLngBounds bounds;

  const DrawingRectangleShape({required this.bounds, DrawingStyle? style})
      : super(DrawingOverlayType.rectangle, style);

  /// JSON 으로부터 생성합니다.
  factory DrawingRectangleShape.fromJson(Map<String, dynamic> json) {
    final sPoint =
        DrawingShape._latLng(Map<String, dynamic>.from(json['sPoint'] as Map));
    final ePoint =
        DrawingShape._latLng(Map<String, dynamic>.from(json['ePoint'] as Map));
    // sPoint / ePoint 는 그린 순서에 따라 어느 모서리든 될 수 있으므로 정규화합니다.
    final sw = LatLng(
      sPoint.latitude < ePoint.latitude ? sPoint.latitude : ePoint.latitude,
      sPoint.longitude < ePoint.longitude ? sPoint.longitude : ePoint.longitude,
    );
    final ne = LatLng(
      sPoint.latitude > ePoint.latitude ? sPoint.latitude : ePoint.latitude,
      sPoint.longitude > ePoint.longitude ? sPoint.longitude : ePoint.longitude,
    );
    return DrawingRectangleShape(
      bounds: LatLngBounds(sw, ne),
      style: DrawingShape._style(json['options']),
    );
  }
}

/// 그려진 원입니다.
class DrawingCircleShape extends DrawingShape {
  /// 원의 중심 좌표입니다.
  final LatLng center;

  /// 원의 반지름입니다. 단위는 미터입니다.
  final double radius;

  const DrawingCircleShape({
    required this.center,
    required this.radius,
    DrawingStyle? style,
  }) : super(DrawingOverlayType.circle, style);

  /// JSON 으로부터 생성합니다.
  factory DrawingCircleShape.fromJson(Map<String, dynamic> json) =>
      DrawingCircleShape(
        center:
            DrawingShape._latLng(Map<String, dynamic>.from(json['center'] as Map)),
        radius: (json['radius'] as num).toDouble(),
        style: DrawingShape._style(json['options']),
      );
}

/// 그려진 타원입니다.
class DrawingEllipseShape extends DrawingShape {
  /// 타원의 중심 좌표입니다.
  final LatLng center;

  /// 가로 반지름입니다. 단위는 미터입니다.
  final double rx;

  /// 세로 반지름입니다. 단위는 미터입니다.
  final double ry;

  const DrawingEllipseShape({
    required this.center,
    required this.rx,
    required this.ry,
    DrawingStyle? style,
  }) : super(DrawingOverlayType.ellipse, style);

  /// JSON 으로부터 생성합니다.
  factory DrawingEllipseShape.fromJson(Map<String, dynamic> json) =>
      DrawingEllipseShape(
        center:
            DrawingShape._latLng(Map<String, dynamic>.from(json['center'] as Map)),
        rx: (json['rx'] as num).toDouble(),
        ry: (json['ry'] as num).toDouble(),
        style: DrawingShape._style(json['options']),
      );
}

/// `getDrawingData()` 의 결과입니다.
///
/// 그려진 도형을 종류별로 담고 있습니다.
///
/// 예시:
/// ```dart
/// final data = await controller.getDrawingData();
/// print('그린 도형 ${data.shapes.length}개');
/// for (final line in data.polylines) {
///   print('선 좌표 ${line.points.length}개');
/// }
/// ```
class DrawingData {
  /// 그려진 모든 도형입니다.
  final List<DrawingShape> shapes;

  /// 도형이 하나도 없으면 true 입니다.
  bool get isEmpty => shapes.isEmpty;

  /// 마커만 골라 반환합니다.
  List<DrawingMarkerShape> get markers =>
      shapes.whereType<DrawingMarkerShape>().toList(growable: false);

  /// 선만 골라 반환합니다.
  List<DrawingPathShape> get polylines => _paths(DrawingOverlayType.polyline);

  /// 다각형만 골라 반환합니다.
  List<DrawingPathShape> get polygons => _paths(DrawingOverlayType.polygon);

  /// 화살표 선만 골라 반환합니다.
  List<DrawingPathShape> get arrows => _paths(DrawingOverlayType.arrow);

  /// 사각형만 골라 반환합니다.
  List<DrawingRectangleShape> get rectangles =>
      shapes.whereType<DrawingRectangleShape>().toList(growable: false);

  /// 원만 골라 반환합니다.
  List<DrawingCircleShape> get circles =>
      shapes.whereType<DrawingCircleShape>().toList(growable: false);

  /// 타원만 골라 반환합니다.
  List<DrawingEllipseShape> get ellipses =>
      shapes.whereType<DrawingEllipseShape>().toList(growable: false);

  List<DrawingPathShape> _paths(DrawingOverlayType type) => shapes
      .whereType<DrawingPathShape>()
      .where((e) => e.type == type)
      .toList(growable: false);

  /// 도형 목록으로 [DrawingData]를 만듭니다.
  const DrawingData(this.shapes);

  /// 카카오 SDK 의 `getData()` 결과로부터 생성합니다.
  ///
  /// 결과는 `{"marker": [...], "polyline": [...]}` 처럼 도형 종류를 키로 하는
  /// Map 입니다.
  factory DrawingData.fromJson(Map<String, dynamic> json) {
    final shapes = <DrawingShape>[];

    json.forEach((key, value) {
      final type = DrawingOverlayType.fromValue(key);
      if (type == null || value is! List) return;

      for (final raw in value) {
        if (raw is! Map) continue;
        final item = Map<String, dynamic>.from(raw);
        switch (type) {
          case DrawingOverlayType.marker:
            shapes.add(DrawingMarkerShape.fromJson(item));
          case DrawingOverlayType.rectangle:
            shapes.add(DrawingRectangleShape.fromJson(item));
          case DrawingOverlayType.circle:
            shapes.add(DrawingCircleShape.fromJson(item));
          case DrawingOverlayType.ellipse:
            shapes.add(DrawingEllipseShape.fromJson(item));
          case DrawingOverlayType.polyline:
          case DrawingOverlayType.polygon:
          case DrawingOverlayType.arrow:
            shapes.add(DrawingPathShape.fromJson(type, item));
        }
      }
    });

    return DrawingData(shapes);
  }

  @override
  String toString() => 'DrawingData{shapes: ${shapes.length}}';
}
