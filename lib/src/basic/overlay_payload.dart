import '../model/lat_lng.dart';
import '../model/lat_lng_bounds.dart';
import 'circle.dart';
import 'clusterer.dart';
import 'clusterer_style.dart';
import 'custom_overlay.dart';
import 'hex_color.dart';
import 'marker.dart';
import 'polygon.dart';
import 'polyline.dart';
import 'rectangle.dart';

/// 오버레이 객체를 JS 배치 payload 로 변환하고, 변경 감지용 해시를 계산하는 내부 헬퍼입니다.
///
/// 라이브러리 외부로 export 되지 않습니다.
///
/// - `xxxPayload()` : JS `addXxxs(payload)` 가 소비하는 Map. `hash` 필드를 포함합니다.
/// - `xxxHash()` : 오버레이 1개의 내용 해시. JS 는 같은 ID + 같은 hash 면 재생성을 건너뜁니다.
/// - `xxxSignature()` : 리스트 전체의 해시. 위젯 rebuild 시 변경 여부 판단에 사용합니다.
class OverlayPayload {
  OverlayPayload._();

  // ---------------------------------------------------------------------------
  // 공통
  // ---------------------------------------------------------------------------

  static Map<String, double> _latLng(LatLng latLng) => {
        'latitude': latLng.latitude,
        'longitude': latLng.longitude,
      };

  static List<Map<String, double>> _latLngs(List<LatLng>? list) =>
      (list ?? const []).map(_latLng).toList(growable: false);

  static int _latLngHash(LatLng? latLng) =>
      latLng == null ? 0 : Object.hash(latLng.latitude, latLng.longitude);

  static int _latLngsHash(List<LatLng>? list) =>
      list == null ? 0 : Object.hashAll(list.map(_latLngHash));

  // ---------------------------------------------------------------------------
  // Marker
  // ---------------------------------------------------------------------------

  /// 마커 1개의 내용 해시입니다.
  static int markerHash(Marker m) => Object.hash(
        m.markerId,
        _latLngHash(m.latLng),
        m.width,
        m.height,
        m.offsetX,
        m.offsetY,
        m.icon?.imageSrc,
        m.icon?.imageType,
        m.markerImageSrc,
        m.infoWindowContent,
        m.draggable,
        m.infoWindowRemovable,
        m.infoWindowFirstShow,
        m.infoWindowStyle,
        m.zIndex,
        m.customOverlayContent,
        m.customOverlayXAnchor,
        m.customOverlayYAnchor,
      );

  /// JS `addMarkers()` 용 payload 입니다.
  static Map<String, dynamic> marker(Marker m) {
    final imageSrc = m.icon?.imageSrc ?? m.markerImageSrc;
    return {
      'markerId': m.markerId,
      'latLng': _latLng(m.latLng),
      'draggable': m.draggable,
      'width': m.width,
      'height': m.height,
      'offsetX': m.offsetX,
      'offsetY': m.offsetY,
      'imageSrc': imageSrc,
      'imageType': m.icon?.imageType?.name,
      'infoWindowContent': m.infoWindowContent,
      'infoWindowRemovable': m.infoWindowRemovable,
      'infoWindowFirstShow': m.infoWindowFirstShow,
      'infoWindowStyle': m.infoWindowStyle?.toJson(),
      'zIndex': m.zIndex,
      'hash': markerHash(m),
    };
  }

  /// 마커 리스트 전체의 시그니처입니다. null 리스트는 null 을 반환합니다.
  static int? markersSignature(List<Marker>? list) =>
      list == null ? null : Object.hashAll(list.map(markerHash));

  // ---------------------------------------------------------------------------
  // Polyline
  // ---------------------------------------------------------------------------

  static int polylineHash(Polyline p) => Object.hash(
        p.polylineId,
        _latLngsHash(p.points),
        p.strokeColor,
        p.strokeOpacity,
        p.strokeWidth,
        p.strokeStyle,
        p.endArrow,
        p.zIndex,
      );

  static Map<String, dynamic> polyline(Polyline p) => {
        'polylineId': p.polylineId,
        'points': _latLngs(p.points),
        'strokeColor': p.strokeColor?.toHexColor(),
        'strokeOpacity': p.strokeOpacity,
        'strokeWidth': p.strokeWidth,
        'strokeStyle': p.strokeStyle?.name,
        'endArrow': p.endArrow ?? false,
        'zIndex': p.zIndex,
        'hash': polylineHash(p),
      };

  static int? polylinesSignature(List<Polyline>? list) =>
      list == null ? null : Object.hashAll(list.map(polylineHash));

  // ---------------------------------------------------------------------------
  // Circle
  // ---------------------------------------------------------------------------

  static int circleHash(Circle c) => Object.hash(
        c.circleId,
        _latLngHash(c.center),
        c.radius,
        c.strokeWidth,
        c.strokeColor,
        c.strokeOpacity,
        c.strokeStyle,
        c.fillColor,
        c.fillOpacity,
        c.zIndex,
      );

  static Map<String, dynamic> circle(Circle c) => {
        'circleId': c.circleId,
        'center': _latLng(c.center),
        'radius': c.radius,
        'strokeWidth': c.strokeWidth,
        'strokeColor': c.strokeColor?.toHexColor(),
        'strokeOpacity': c.strokeOpacity,
        'strokeStyle': c.strokeStyle?.name,
        'fillColor': c.fillColor?.toHexColor(),
        'fillOpacity': c.fillOpacity,
        'zIndex': c.zIndex,
        'hash': circleHash(c),
      };

  static int? circlesSignature(List<Circle>? list) =>
      list == null ? null : Object.hashAll(list.map(circleHash));

  // ---------------------------------------------------------------------------
  // Rectangle
  // ---------------------------------------------------------------------------

  static int _boundsHash(LatLngBounds b) =>
      Object.hash(_latLngHash(b.sw), _latLngHash(b.ne));

  static int rectangleHash(Rectangle r) => Object.hash(
        r.rectangleId,
        _boundsHash(r.rectangleBounds),
        r.strokeWidth,
        r.strokeColor,
        r.strokeOpacity,
        r.strokeStyle,
        r.fillColor,
        r.fillOpacity,
        r.zIndex,
      );

  static Map<String, dynamic> rectangle(Rectangle r) => {
        'rectangleId': r.rectangleId,
        'bounds': {
          'sw': _latLng(r.rectangleBounds.sw),
          'ne': _latLng(r.rectangleBounds.ne),
        },
        'strokeWidth': r.strokeWidth,
        'strokeColor': r.strokeColor?.toHexColor(),
        'strokeOpacity': r.strokeOpacity,
        'strokeStyle': r.strokeStyle?.name,
        'fillColor': r.fillColor?.toHexColor(),
        'fillOpacity': r.fillOpacity,
        'zIndex': r.zIndex,
        'hash': rectangleHash(r),
      };

  static int? rectanglesSignature(List<Rectangle>? list) =>
      list == null ? null : Object.hashAll(list.map(rectangleHash));

  // ---------------------------------------------------------------------------
  // Polygon
  // ---------------------------------------------------------------------------

  static int polygonHash(Polygon p) => Object.hash(
        p.polygonId,
        _latLngsHash(p.points),
        Object.hashAll((p.holes ?? const []).map(_latLngsHash)),
        p.strokeWidth,
        p.strokeColor,
        p.strokeOpacity,
        p.strokeStyle,
        p.fillColor,
        p.fillOpacity,
        p.zIndex,
      );

  static Map<String, dynamic> polygon(Polygon p) => {
        'polygonId': p.polygonId,
        'points': _latLngs(p.points),
        'holes': (p.holes ?? const []).map(_latLngs).toList(growable: false),
        'strokeWidth': p.strokeWidth,
        'strokeColor': p.strokeColor?.toHexColor(),
        'strokeOpacity': p.strokeOpacity,
        'strokeStyle': p.strokeStyle?.name,
        'fillColor': p.fillColor?.toHexColor(),
        'fillOpacity': p.fillOpacity,
        'zIndex': p.zIndex,
        'hash': polygonHash(p),
      };

  static int? polygonsSignature(List<Polygon>? list) =>
      list == null ? null : Object.hashAll(list.map(polygonHash));

  // ---------------------------------------------------------------------------
  // CustomOverlay
  // ---------------------------------------------------------------------------

  static int customOverlayHash(CustomOverlay o) => Object.hash(
        o.customOverlayId,
        _latLngHash(o.latLng),
        o.content,
        o.xAnchor,
        o.yAnchor,
        o.zIndex,
        o.removable,
        o.draggable,
      );

  static Map<String, dynamic> customOverlay(CustomOverlay o) => {
        'customOverlayId': o.customOverlayId,
        'latLng': _latLng(o.latLng),
        'content': o.content,
        'xAnchor': o.xAnchor,
        'yAnchor': o.yAnchor,
        'zIndex': o.zIndex,
        'removable': o.removable,
        'draggable': o.draggable,
        'hash': customOverlayHash(o),
      };

  static int? customOverlaysSignature(List<CustomOverlay>? list) =>
      list == null ? null : Object.hashAll(list.map(customOverlayHash));

  // ---------------------------------------------------------------------------
  // Clusterer
  // ---------------------------------------------------------------------------

  static int _styleHash(ClustererStyle s) => Object.hash(
        s.width,
        s.height,
        s.background,
        s.borderRadius,
        s.color,
        s.textAlign,
        s.lineHeight,
      );

  /// 클러스터러 전체(옵션 + 마커)의 시그니처입니다. null 이면 null 을 반환합니다.
  static int? clustererSignature(Clusterer? c) => c == null
      ? null
      : Object.hash(
          Object.hashAll(c.markers.map(markerHash)),
          c.gridSize,
          c.averageCenter,
          c.disableClickZoom,
          c.minLevel,
          c.minClusterSize,
          Object.hashAll(c.texts ?? const []),
          Object.hashAll(c.calculator ?? const []),
          Object.hashAll((c.styles ?? const []).map(_styleHash)),
        );
}
