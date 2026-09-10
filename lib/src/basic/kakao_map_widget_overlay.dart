import 'package:flutter/widgets.dart';

import '../model/lat_lng.dart';

/// 지도 좌표에 붙어 지도와 함께 움직이는 Flutter 위젯입니다.
///
/// HTML 로 만드는 `CustomOverlay` 와 달리 진짜 Flutter 위젯이므로 앱의 테마·폰트·
/// 애니메이션·제스처를 그대로 씁니다. 지도(WebView/iframe) 위 Flutter 레이어에
/// 그려지며, 지도가 움직이면 JS 가 픽셀 좌표를 보내 위치를 따라갑니다.
///
/// `KakaoMap(widgetOverlays: [...])` 로 전달합니다. 지도 조작 중에는 한 프레임
/// 정도 늦게 따라올 수 있으므로, 수백 개 이상이거나 정밀하게 붙어야 하는 요소는
/// `CustomOverlay` 를 쓰세요.
///
/// 예시:
/// ```dart
/// KakaoMap(
///   widgetOverlays: [
///     KakaoMapWidgetOverlay(
///       id: 'cafe',
///       position: LatLng(37.5665, 126.9780),
///       anchor: Alignment.bottomCenter,
///       child: Card(child: Padding(padding: EdgeInsets.all(8), child: Text('카페'))),
///     ),
///   ],
/// )
/// ```
class KakaoMapWidgetOverlay {
  /// 오버레이를 구분하는 ID 입니다.
  final String id;

  /// 붙일 지도 좌표입니다.
  final LatLng position;

  /// 표시할 위젯입니다.
  final Widget child;

  /// [child] 의 어느 점을 [position] 에 맞출지 정합니다. 기본은 아래 가운데(핀 끝처럼)입니다.
  final Alignment anchor;

  /// 픽셀 단위 추가 보정입니다. 예: 마커 위에 띄우려면 `Offset(0, -40)`.
  final Offset offset;

  /// 위젯 오버레이를 만듭니다.
  const KakaoMapWidgetOverlay({
    required this.id,
    required this.position,
    required this.child,
    this.anchor = Alignment.bottomCenter,
    this.offset = Offset.zero,
  });

  /// JS 에 보낼 위치 정보입니다.
  Map<String, dynamic> toPositionJson() => <String, dynamic>{
        'id': id,
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
}
