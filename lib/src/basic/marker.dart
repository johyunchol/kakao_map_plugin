import '../model/lat_lng.dart';
import 'marker_icon.dart';

/// 지도에 표시할 마커를 나타내는 클래스입니다.
///
/// 마커는 지도 위의 특정 위치를 표시하는 데 사용됩니다.
/// 커스텀 이미지, 정보 창, 드래그 기능 등을 지원합니다.
///
/// 예시:
/// ```dart
/// final marker = Marker(
///   markerId: 'marker_1',
///   latLng: LatLng(37.5665, 126.9780),
///   icon: await MarkerIcon.fromAsset('assets/marker.png'),
///   width: 48,
///   height: 60,
///   infoWindowContent: '서울시청',
///   draggable: true,
/// );
/// ```
class Marker {
  /// 마커의 고유 식별자입니다.
  ///
  /// 각 마커는 고유한 ID를 가져야 하며, 이를 통해 마커를 업데이트하거나 제거할 수 있습니다.
  final String markerId;

  /// 마커가 표시될 위도와 경도 좌표입니다.
  ///
  /// 마커의 위치를 동적으로 변경할 수 있습니다.
  LatLng latLng;

  /// 마커 이미지의 너비(픽셀)입니다.
  ///
  /// 기본값은 24픽셀입니다.
  int width = 24;

  /// 마커 이미지의 높이(픽셀)입니다.
  ///
  /// 기본값은 30픽셀입니다.
  int height = 30;

  /// 마커의 수평 오프셋(픽셀)입니다.
  ///
  /// 양수 값은 마커를 오른쪽으로, 음수 값은 왼쪽으로 이동시킵니다.
  /// null인 경우 오프셋이 적용되지 않습니다.
  int? offsetX;

  /// 마커의 수직 오프셋(픽셀)입니다.
  ///
  /// 양수 값은 마커를 아래로, 음수 값은 위로 이동시킵니다.
  /// null인 경우 오프셋이 적용되지 않습니다.
  int? offsetY;

  /// 마커에 사용할 커스텀 이미지입니다.
  ///
  /// [MarkerIcon.fromAsset] 또는 [MarkerIcon.fromNetwork]를 사용하여 생성합니다.
  /// null인 경우 기본 마커 이미지가 사용됩니다.
  ///
  /// 예시:
  /// ```dart
  /// icon: await MarkerIcon.fromAsset('assets/marker.png'),
  /// // 또는
  /// icon: await MarkerIcon.fromNetwork('https://example.com/marker.png'),
  /// ```
  MarkerIcon? icon;

  /// 마커 이미지 URL입니다 (더 이상 사용되지 않음).
  ///
  /// 대신 [icon] 속성과 [MarkerIcon]을 사용하세요.
  @Deprecated('use MarkerIcon instead')
  String markerImageSrc = '';

  /// 마커 클릭 시 표시될 정보 창의 내용입니다.
  ///
  /// HTML 형식의 문자열을 지원합니다. 빈 문자열인 경우 정보 창이 표시되지 않습니다.
  ///
  /// 예시:
  /// ```dart
  /// infoWindowContent: '<div>서울시청<br>02-123-4567</div>',
  /// ```
  String infoWindowContent = '';

  /// 마커를 드래그할 수 있는지 여부입니다.
  ///
  /// true로 설정하면 사용자가 마커를 드래그하여 위치를 변경할 수 있습니다.
  /// 기본값은 false입니다.
  bool draggable;

  /// 정보 창에 닫기 버튼을 표시할지 여부입니다.
  ///
  /// true로 설정하면 사용자가 정보 창을 닫을 수 있는 버튼이 표시됩니다.
  /// 기본값은 true입니다.
  bool infoWindowRemovable;

  /// 마커가 지도에 추가될 때 정보 창을 바로 표시할지 여부입니다.
  ///
  /// true로 설정하면 마커 추가 시 정보 창이 자동으로 열립니다.
  /// 기본값은 false입니다.
  bool infoWindowFirstShow;

  /// 마커의 z-index 값입니다.
  ///
  /// 값이 클수록 다른 마커 위에 표시됩니다.
  /// 기본값은 0입니다.
  int zIndex = 0;

  /// 클러스터링 사용 시 마커 대신 표시할 커스텀 오버레이 내용입니다.
  ///
  /// [Clusterer]와 함께 사용할 때, 이 내용이 설정되어 있으면 기본 마커 대신
  /// 커스텀 오버레이가 표시됩니다. HTML 형식의 문자열을 지원합니다.
  ///
  /// 예시:
  /// ```dart
  /// customOverlayContent: '<div style="background:red; padding:10px;">Custom</div>',
  /// ```
  String? customOverlayContent;

  /// 커스텀 오버레이의 수평 앵커 포인트입니다 (0.0 ~ 1.0).
  ///
  /// 0.0은 왼쪽 끝, 0.5는 중앙, 1.0은 오른쪽 끝을 의미합니다.
  /// 기본값은 0.5(중앙)입니다.
  double customOverlayXAnchor;

  /// 커스텀 오버레이의 수직 앵커 포인트입니다 (0.0 ~ 1.0).
  ///
  /// 0.0은 위쪽 끝, 0.5는 중앙, 1.0은 아래쪽 끝을 의미합니다.
  /// 기본값은 1.0(아래쪽 끝)입니다.
  double customOverlayYAnchor;

  /// 마커 인스턴스를 생성합니다.
  ///
  /// [markerId]와 [latLng]는 필수 파라미터입니다.
  ///
  /// 예시:
  /// ```dart
  /// final marker = Marker(
  ///   markerId: 'marker_1',
  ///   latLng: LatLng(37.5665, 126.9780),
  ///   width: 48,
  ///   height: 60,
  ///   icon: await MarkerIcon.fromAsset('assets/marker.png'),
  ///   draggable: true,
  ///   zIndex: 10,
  /// );
  /// ```
  Marker({
    required this.markerId,
    required this.latLng,
    this.width = 24,
    this.height = 30,
    this.offsetX,
    this.offsetY,
    this.icon,
    this.markerImageSrc = '',
    this.infoWindowContent = '',
    this.draggable = false,
    this.infoWindowRemovable = true,
    this.infoWindowFirstShow = false,
    this.zIndex = 0,
    this.customOverlayContent,
    this.customOverlayXAnchor = 0.5,
    this.customOverlayYAnchor = 1.0,
  });

  /// 마커 정보를 JSON 형식으로 변환합니다.
  ///
  /// 플랫폼 채널을 통해 네이티브 코드로 마커 정보를 전달할 때 사용됩니다.
  Map<String, dynamic> toJson() {
    return {
      'markerId': markerId,
      'latLng': {
        'latitude': latLng.latitude,
        'longitude': latLng.longitude,
      },
      'width': width,
      'height': height,
      'offsetX': offsetX,
      'offsetY': offsetY,
      'icon': icon != null
          ? {
              'imageSrc': icon!.imageSrc,
              'imageType': icon!.imageType?.name,
            }
          : null,
      'markerImageSrc': markerImageSrc,
      'infoWindowContent': infoWindowContent,
      'draggable': draggable,
      'infoWindowRemovable': infoWindowRemovable,
      'infoWindowFirstShow': infoWindowFirstShow,
      'zIndex': zIndex,
      'customOverlayContent': customOverlayContent,
      'customOverlayXAnchor': customOverlayXAnchor,
      'customOverlayYAnchor': customOverlayYAnchor,
    };
  }

  /// 마커 정보를 문자열로 반환합니다.
  ///
  /// 디버깅 목적으로 사용됩니다.
  @override
  String toString() {
    return 'Marker{markerId: $markerId, latLng: $latLng, width: $width, height: $height, offsetX: $offsetX, offsetY: $offsetY, icon: $icon, markerImageSrc: $markerImageSrc, infoWindowContent: $infoWindowContent, draggable: $draggable, infoWindowRemovable: $infoWindowRemovable, infoWindowFirstShow: $infoWindowFirstShow, zIndex: $zIndex}';
  }
}
