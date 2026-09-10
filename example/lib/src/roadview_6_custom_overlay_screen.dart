import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 로드뷰에 커스텀오버레이 올리기
/// https://apis.map.kakao.com/web/sample/roadviewCustomOverlay/
class RoadView6CustomOverlayScreen extends StatefulWidget {
  const RoadView6CustomOverlayScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<RoadView6CustomOverlayScreen> createState() =>
      _RoadView6CustomOverlayScreenState();
}

class _RoadView6CustomOverlayScreenState
    extends State<RoadView6CustomOverlayScreen> {
  KakaoRoadviewController? roadviewController;

  final LatLng position = LatLng(33.450701, 126.570667);

  String? tappedOverlayId;

  /// 말풍선 형태의 커스텀 오버레이입니다.
  /// 로드뷰 위 오버레이도 지도와 동일하게 임의의 HTML 을 사용할 수 있습니다.
  List<CustomOverlay> _overlays() => [
        CustomOverlay(
          customOverlayId: 'bubble',
          latLng: position,
          content: '<div style="'
              'padding:8px 12px;background:#fff;border:2px solid #0f4c81;'
              'border-radius:20px;font-size:13px;font-weight:bold;'
              'color:#0f4c81;white-space:nowrap;'
              'box-shadow:0 2px 6px rgba(0,0,0,0.3);">'
              '탭해 보세요</div>',
          xAnchor: 0.5,
          yAnchor: 1.0,
          altitude: 5,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: Stack(
        children: [
          KakaoRoadMap(
            center: position,
            customOverlays: _overlays(),
            onRoadviewCreated: (controller) {
              roadviewController = controller;
            },
            onCustomOverlayTap: (overlayId, latLng) {
              setState(() => tappedOverlayId = overlayId);
            },
          ),
          if (tappedOverlayId != null)
            Positioned(
              left: 12,
              bottom: 12,
              child: KakaoMapPointerInterceptor(
                  child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('탭한 오버레이: $tappedOverlayId'),
                ),
              )),
            ),
        ],
      ),
      floatingActionButton: KakaoMapPointerInterceptor(
          child: FloatingActionButton.extended(
        onPressed: () async {
          // 모든 오버레이를 제거합니다.
          await roadviewController?.clearCustomOverlay();
          setState(() => tappedOverlayId = null);
        },
        label: const Text('오버레이 제거'),
        icon: const Icon(Icons.delete_outline),
      )),
    );
  }
}
