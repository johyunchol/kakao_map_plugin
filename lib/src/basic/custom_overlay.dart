import '../model/lat_lng.dart';

/// 지도에 커스텀 HTML 컨텐츠를 표시하는 오버레이 클래스입니다.
///
/// 커스텀 오버레이는 마커보다 자유로운 형태의 컨텐츠를 지도 위에 표시할 수 있습니다.
/// HTML과 CSS를 사용하여 완전히 커스터마이징된 UI를 만들 수 있습니다.
///
/// 예시:
/// ```dart
/// final customOverlay = CustomOverlay(
///   customOverlayId: 'overlay_1',
///   latLng: LatLng(37.5665, 126.9780),
///   content: '''
///     <div style="padding:10px; background:white; border-radius:5px;">
///       <h3>서울시청</h3>
///       <p>서울특별시청입니다</p>
///     </div>
///   ''',
///   xAnchor: 0.5,
///   yAnchor: 1.0,
/// );
/// ```
class CustomOverlay {
  /// 커스텀 오버레이의 고유 식별자입니다.
  ///
  /// 각 커스텀 오버레이는 고유한 ID를 가져야 하며, 이를 통해 오버레이를 업데이트하거나 제거할 수 있습니다.
  final String customOverlayId;

  /// 커스텀 오버레이가 표시될 중심 좌표입니다.
  ///
  /// 이 좌표를 기준으로 앵커 포인트([xAnchor], [yAnchor])에 따라 오버레이가 배치됩니다.
  final LatLng latLng;

  /// 커스텀 오버레이에 표시할 HTML 컨텐츠입니다.
  ///
  /// HTML 마크업과 인라인 CSS를 사용하여 자유롭게 디자인할 수 있습니다.
  /// JavaScript는 지원하지 않습니다.
  ///
  /// 예시:
  /// ```dart
  /// content: '''
  ///   <div style="padding:15px; background:#fff; border:2px solid #000;">
  ///     <h3 style="margin:0;">장소 이름</h3>
  ///     <p style="margin:5px 0 0;">상세 설명</p>
  ///   </div>
  /// ''',
  /// ```
  final String content;

  /// 오버레이의 수평 앵커 포인트입니다 (0.0 ~ 1.0).
  ///
  /// 0.0은 컨텐츠의 왼쪽 끝, 0.5는 중앙, 1.0은 오른쪽 끝을 기준점으로 합니다.
  /// 기본값은 0.5(중앙)입니다.
  ///
  /// 예시:
  /// - 0.0: 컨텐츠 왼쪽 끝이 좌표에 맞춰짐
  /// - 0.5: 컨텐츠 중앙이 좌표에 맞춰짐
  /// - 1.0: 컨텐츠 오른쪽 끝이 좌표에 맞춰짐
  final double xAnchor;

  /// 오버레이의 수직 앵커 포인트입니다 (0.0 ~ 1.0).
  ///
  /// 0.0은 컨텐츠의 위쪽 끝, 0.5는 중앙, 1.0은 아래쪽 끝을 기준점으로 합니다.
  /// 기본값은 1.0(아래쪽 끝)으로, 마커처럼 하단이 좌표에 맞춰집니다.
  ///
  /// 예시:
  /// - 0.0: 컨텐츠 위쪽 끝이 좌표에 맞춰짐
  /// - 0.5: 컨텐츠 중앙이 좌표에 맞춰짐
  /// - 1.0: 컨텐츠 아래쪽 끝이 좌표에 맞춰짐
  final double yAnchor;

  /// 오버레이의 z-index 값입니다.
  ///
  /// 값이 클수록 다른 요소 위에 표시됩니다.
  /// 기본값은 3입니다.
  final int zIndex;

  /// 커스텀 오버레이 인스턴스를 생성합니다.
  ///
  /// [customOverlayId], [latLng], [content]는 필수 파라미터입니다.
  ///
  /// 예시:
  /// ```dart
  /// final overlay = CustomOverlay(
  ///   customOverlayId: 'info_1',
  ///   latLng: LatLng(37.5665, 126.9780),
  ///   content: '''
  ///     <div style="background:white; padding:10px; border-radius:8px; box-shadow:0 2px 6px rgba(0,0,0,0.3);">
  ///       <h4 style="margin:0 0 5px;">서울시청</h4>
  ///       <p style="margin:0; color:#666;">중구 태평로1가 31</p>
  ///     </div>
  ///   ''',
  ///   xAnchor: 0.5,
  ///   yAnchor: 1.0,
  ///   zIndex: 10,
  /// );
  /// ```
  CustomOverlay({
    required this.customOverlayId,
    required this.latLng,
    required this.content,
    this.xAnchor = 0.5,
    this.yAnchor = 1,
    this.zIndex = 3,
  });
}
