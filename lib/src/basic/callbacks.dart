import '../model/lat_lng.dart';
import '../model/lat_lng_bounds.dart';
import '../model/viewpoint.dart';
import '../road/kakao_roadview_controller.dart';
import 'constants/drag_type.dart';
import 'constants/drawing_overlay_type.dart';
import 'constants/marker_drag_type.dart';
import 'constants/zoom_type.dart';
import 'kakao_map_controller.dart';
import 'marker.dart';

/// 지도 생성 완료 콜백입니다.
///
/// 지도가 완전히 로드되고 사용 준비가 완료되면 호출됩니다.
/// [controller]를 통해 지도를 제어할 수 있습니다.
typedef MapCreateCallback = void Function(KakaoMapController controller);

/// 지도 탭(클릭) 콜백입니다.
///
/// 사용자가 지도를 탭했을 때 호출됩니다.
/// [latLng] 탭한 위치의 좌표를 반환합니다.
typedef OnMapTap = void Function(LatLng latLng);

/// 지도 더블 탭(더블클릭) 콜백입니다.
///
/// 사용자가 지도를 더블 탭했을 때 호출됩니다.
/// [latLng] 더블 탭한 위치의 좌표를 반환합니다.
typedef OnMapDoubleTap = void Function(LatLng latLng);

/// 커스텀 오버레이 탭(클릭) 콜백입니다.
///
/// 사용자가 커스텀 오버레이를 탭했을 때 호출됩니다.
/// [customOverlayId] 탭한 커스텀 오버레이의 ID
/// [latLng] 커스텀 오버레이의 위치 좌표
typedef OnCustomOverlayTap = void Function(
    String customOverlayId, LatLng latLng);

/// 마커 탭(클릭) 콜백입니다.
///
/// 사용자가 마커를 탭했을 때 호출됩니다.
/// [markerId] 탭한 마커의 ID
/// [latLng] 마커의 위치 좌표
/// [zoomLevel] 현재 지도의 확대/축소 레벨
typedef OnMarkerTap = void Function(
    String markerId, LatLng latLng, int zoomLevel);

/// 마커 클러스터러 탭(클릭) 콜백입니다.
///
/// 사용자가 마커 클러스터를 탭했을 때 호출됩니다.
/// [latLng] 클러스터의 중심 좌표
/// [zoomLevel] 현재 지도의 확대/축소 레벨
/// [clusterMarkers] 클러스터에 포함된 마커 목록
typedef OnMarkerClustererTap = void Function(
    LatLng latLng, int zoomLevel, List<Marker> clusterMarkers);

/// 마커 드래그 상태 변경 콜백입니다.
///
/// 마커가 드래그되는 동안 호출됩니다.
/// [markerId] 드래그 중인 마커의 ID
/// [latLng] 마커의 현재 위치 좌표
/// [zoomLevel] 현재 지도의 확대/축소 레벨
/// [markerDragType] 드래그 상태 (시작, 종료)
typedef OnMarkerDragChangeCallback = void Function(String markerId,
    LatLng latLng, int zoomLevel, MarkerDragType markerDragType);

/// 지도 이동 완료 콜백입니다.
///
/// 지도의 이동(드래그, 줌 등)이 완료되고 정지했을 때 호출됩니다.
/// [latLng] 지도 중심의 최종 좌표
/// [zoomLevel] 지도의 최종 확대/축소 레벨
typedef OnCameraIdle = void Function(LatLng latLng, int zoomLevel);

/// 지도 드래그 상태 변경 콜백입니다.
///
/// 지도가 드래그되는 동안 호출됩니다.
/// [latLng] 지도 중심의 현재 좌표
/// [zoomLevel] 현재 지도의 확대/축소 레벨
/// [dragType] 드래그 상태 (시작, 이동 중, 종료)
typedef OnDragChangeCallback = void Function(
    LatLng latLng, int zoomLevel, DragType dragType);

/// 지도 확대/축소 레벨 변경 콜백입니다.
///
/// 지도의 확대/축소 레벨이 변경될 때 호출됩니다.
/// [zoomLevel] 변경된 확대/축소 레벨
/// [zoomType] 확대/축소 상태 (시작, 종료)
typedef OnZoomChangeCallback = void Function(int zoomLevel, ZoomType zoomType);

/// 지도 중심 좌표 변경 콜백입니다.
///
/// 지도의 중심 좌표가 변경될 때 호출됩니다.
/// [latlng] 변경된 중심 좌표
/// [zoomLevel] 현재 지도의 확대/축소 레벨
typedef OnCenterChangeCallback = void Function(LatLng latlng, int zoomLevel);

/// 지도 영역 경계 변경 콜백입니다.
///
/// 지도의 보이는 영역 경계가 변경될 때 호출됩니다.
/// [latLngBounds] 변경된 지도 영역의 경계 정보 (남서쪽, 북동쪽 좌표)
typedef OnBoundsChangeCallback = void Function(LatLngBounds latLngBounds);

/// 지도 타일 로드 완료 콜백입니다.
///
/// 지도 타일 이미지가 모두 로드되었을 때 호출됩니다.
/// [latLng] 지도 중심의 좌표
/// [zoomLevel] 현재 지도의 확대/축소 레벨
typedef OnTilesLoadedCallback = void Function(LatLng latLng, int zoomLevel);

/// 도형 그리기 완료 콜백입니다.
///
/// 사용자가 도형 하나를 다 그렸을 때 호출됩니다.
/// [type] 그려진 도형의 종류
typedef OnDrawingEnd = void Function(DrawingOverlayType? type);

/// 도형 제거 콜백입니다.
///
/// 그려진 도형이 제거되었을 때 호출됩니다.
typedef OnDrawingRemove = void Function();

/// 도형 그리기 상태 변경 콜백입니다.
///
/// 되돌리기/다시실행 가능 여부 등 그리기 상태가 바뀌면 호출됩니다.
typedef OnDrawingStateChange = void Function();

/// 커스텀 오버레이 제거 콜백입니다.
///
/// 닫기 버튼을 눌러 오버레이가 제거되었을 때 호출됩니다.
/// [customOverlayId] 제거된 오버레이의 ID
typedef OnCustomOverlayRemove = void Function(String customOverlayId);

/// 커스텀 오버레이 드래그 종료 콜백입니다.
///
/// 오버레이를 끌어 놓았을 때 호출됩니다.
/// [customOverlayId] 옮긴 오버레이의 ID
/// [latLng] 놓은 지점의 좌표
typedef OnCustomOverlayDragEnd = void Function(
  String customOverlayId,
  LatLng latLng,
);

/// 다각형 탭 콜백입니다.
///
/// 지도 위 다각형을 탭했을 때 호출됩니다.
/// [polygonId] 탭한 다각형의 ID
/// [latLng] 탭한 지점의 좌표
/// [zoomLevel] 현재 지도의 확대/축소 레벨
typedef OnPolygonTap = void Function(
  String polygonId,
  LatLng latLng,
  int zoomLevel,
);

// ===========================================================================
// 로드뷰 콜백
// ===========================================================================

/// 로드뷰 생성 완료 콜백입니다.
///
/// 로드뷰가 화면에 표시될 준비를 마치면 호출됩니다.
/// [controller]를 통해 시점 변경, 오버레이 추가 등을 수행할 수 있습니다.
typedef RoadviewCreateCallback = void Function(
    KakaoRoadviewController controller);

/// 로드뷰 초기화 완료 콜백입니다.
///
/// 파노라마 이미지가 로드되어 화면에 표시된 직후 호출됩니다.
typedef OnRoadviewInit = void Function();

/// 로드뷰 파노라마 ID 변경 콜백입니다.
///
/// 사용자가 도로를 따라 이동하는 등으로 다른 파노라마로 넘어가면 호출됩니다.
/// [panoId] 새로 표시된 파노라마의 ID
typedef OnRoadviewPanoIdChange = void Function(String panoId);

/// 로드뷰 시점 변경 콜백입니다.
///
/// 사용자가 화면을 돌리거나 확대/축소하면 호출됩니다.
/// [viewpoint] 변경된 시점(방향과 확대 수준)
typedef OnRoadviewViewpointChange = void Function(Viewpoint viewpoint);

/// 로드뷰 위치 변경 콜백입니다.
///
/// 표시 중인 파노라마의 좌표가 바뀌면 호출됩니다.
/// [latLng] 변경된 좌표
typedef OnRoadviewPositionChange = void Function(LatLng latLng);

/// 로드뷰를 찾지 못했을 때 호출되는 콜백입니다.
///
/// 요청한 좌표 주변에 로드뷰가 없으면(산간, 해상 등) 호출됩니다.
/// 이 경우 로드뷰는 비어 있는 상태로 남으므로 안내 UI 를 표시하는 데 사용합니다.
/// [latLng] 로드뷰를 찾으려 했던 좌표
typedef OnRoadviewNotFound = void Function(LatLng latLng);
