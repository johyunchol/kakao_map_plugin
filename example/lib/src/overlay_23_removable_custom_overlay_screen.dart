import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 닫기가 가능한 커스텀 오버레이
/// https://apis.map.kakao.com/web/sample/removableCustomOverlay
class Overlay23RemovableCustomOverlayScreen extends StatefulWidget {
  const Overlay23RemovableCustomOverlayScreen({Key? key, this.title})
      : super(key: key);

  final String? title;

  @override
  State<Overlay23RemovableCustomOverlayScreen> createState() =>
      _Overlay23RemovableCustomOverlayScreenState();
}

class _Overlay23RemovableCustomOverlayScreenState
    extends State<Overlay23RemovableCustomOverlayScreen> {
  late KakaoMapController mapController;

  final LatLng center = LatLng(33.450701, 126.570667);

  List<CustomOverlay> customOverlays = [];
  String message = '지도를 탭하면 닫기 버튼이 달린 오버레이가 생깁니다.';

  int _seq = 0;

  @override
  void initState() {
    super.initState();
    customOverlays = [_buildOverlay(center)];
  }

  CustomOverlay _buildOverlay(LatLng latLng) {
    _seq++;
    return CustomOverlay(
      customOverlayId: 'overlay$_seq',
      latLng: latLng,
      content: '<div style="padding:10px 14px;background:#fff;'
          'border:2px solid #0f4c81;border-radius:8px;font-size:13px;'
          'white-space:nowrap;box-shadow:0 2px 6px rgba(0,0,0,0.25);">'
          '오른쪽 위 × 를 눌러 닫기</div>',
      xAnchor: 0.5,
      yAnchor: 1.2,
      // 닫기 버튼을 표시합니다.
      removable: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? selectedTitle)),
      body: Stack(
        children: [
          KakaoMap(
            onMapCreated: (controller) => mapController = controller,
            center: center,
            customOverlays: customOverlays,
            onMapTap: (latLng) {
              setState(() {
                customOverlays = [...customOverlays, _buildOverlay(latLng)];
                message = '오버레이 ${customOverlays.length}개';
              });
            },
            // 닫기 버튼으로 제거되면 Flutter 쪽 목록에서도 지웁니다.
            onCustomOverlayRemove: (overlayId) {
              setState(() {
                customOverlays = customOverlays
                    .where((o) => o.customOverlayId != overlayId)
                    .toList();
                message = '$overlayId 닫힘 (남은 ${customOverlays.length}개)';
              });
            },
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: KakaoMapPointerInterceptor(
                child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(message, style: const TextStyle(fontSize: 13)),
              ),
            )),
          ),
        ],
      ),
    );
  }
}
