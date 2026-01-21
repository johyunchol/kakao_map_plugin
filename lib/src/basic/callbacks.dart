part of '../../kakao_map_plugin.dart';

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
