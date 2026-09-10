import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 커스텀오버레이를 드래그 하기
/// https://apis.map.kakao.com/web/sample/dragCustomOverlay
class Overlay25DragCustomOverlayScreen extends StatefulWidget {
  const Overlay25DragCustomOverlayScreen({Key? key, this.title})
      : super(key: key);

  final String? title;

  @override
  State<Overlay25DragCustomOverlayScreen> createState() =>
      _Overlay25DragCustomOverlayScreenState();
}

class _Overlay25DragCustomOverlayScreenState
    extends State<Overlay25DragCustomOverlayScreen> {
  late KakaoMapController mapController;

  final LatLng center = LatLng(33.450701, 126.570667);

  LatLng? droppedAt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? selectedTitle)),
      body: Stack(
        children: [
          KakaoMap(
            onMapCreated: (controller) => mapController = controller,
            center: center,
            customOverlays: [
              CustomOverlay(
                customOverlayId: 'draggable',
                latLng: center,
                content: '<div style="padding:10px 14px;background:#ffd400;'
                    'border:2px solid #333;border-radius:8px;font-size:13px;'
                    'font-weight:bold;white-space:nowrap;'
                    'box-shadow:0 2px 6px rgba(0,0,0,0.3);">'
                    '끌어서 옮겨 보세요</div>',
                xAnchor: 0.5,
                yAnchor: 1.0,
                // 드래그로 위치를 옮길 수 있게 합니다.
                // 드래그 중에는 지도 이동이 잠깁니다.
                draggable: true,
              ),
            ],
            onCustomOverlayDragEnd: (overlayId, latLng) {
              setState(() => droppedAt = latLng);
            },
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  droppedAt == null
                      ? '노란 상자를 끌어 옮겨 보세요.'
                      : '놓은 위치: ${droppedAt!.latitude.toStringAsFixed(6)}, '
                          '${droppedAt!.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
