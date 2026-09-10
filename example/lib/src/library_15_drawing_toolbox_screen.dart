import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// Toolbox 사용하기
/// https://apis.map.kakao.com/web/sample/drawingToolbox/
class Library15DrawingToolboxScreen extends StatefulWidget {
  const Library15DrawingToolboxScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Library15DrawingToolboxScreen> createState() =>
      _Library15DrawingToolboxScreenState();
}

class _Library15DrawingToolboxScreenState
    extends State<Library15DrawingToolboxScreen> {
  KakaoMapController? mapController;
  bool toolboxVisible = false;

  Future<void> _setup(KakaoMapController controller) async {
    mapController = controller;
    await controller.createDrawingManager(
      options: const DrawingOptions(
        drawingMode: [
          DrawingOverlayType.marker,
          DrawingOverlayType.polyline,
          DrawingOverlayType.rectangle,
          DrawingOverlayType.circle,
          DrawingOverlayType.ellipse,
          DrawingOverlayType.polygon,
          DrawingOverlayType.arrow,
        ],
        guideTooltip: ['draw', 'drag', 'edit'],
      ),
    );
    // Toolbox 는 지도 위에 카카오 SDK 가 직접 그리는 UI 입니다.
    await controller.showDrawingToolbox();
    if (mounted) setState(() => toolboxVisible = true);
  }

  Future<void> _toggleToolbox() async {
    if (toolboxVisible) {
      await mapController?.removeDrawingToolbox();
    } else {
      await mapController?.showDrawingToolbox();
    }
    setState(() => toolboxVisible = !toolboxVisible);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? selectedTitle)),
      body: Stack(
        children: [
          KakaoMap(
            onMapCreated: _setup,
            center: LatLng(33.450701, 126.570667),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: KakaoMapPointerInterceptor(
                child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  toolboxVisible
                      ? '지도 위 도구 상자에서 도형을 고르세요.'
                      : '도구 상자가 숨겨져 있습니다.',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            )),
          ),
        ],
      ),
      floatingActionButton: KakaoMapPointerInterceptor(
          child: FloatingActionButton.extended(
        onPressed: _toggleToolbox,
        label: Text(toolboxVisible ? '도구 상자 숨기기' : '도구 상자 보이기'),
        icon: Icon(toolboxVisible ? Icons.visibility_off : Icons.visibility),
      )),
    );
  }
}
