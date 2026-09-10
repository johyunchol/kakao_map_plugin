import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 로드뷰 토글 버튼
/// https://apis.map.kakao.com/web/sample/roadviewToggle/
class RoadView9ToggleButtonScreen extends StatefulWidget {
  const RoadView9ToggleButtonScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<RoadView9ToggleButtonScreen> createState() =>
      _RoadView9ToggleButtonScreenState();
}

class _RoadView9ToggleButtonScreenState
    extends State<RoadView9ToggleButtonScreen> {
  KakaoMapRoadviewController? controller;
  bool showRoadview = false;

  Future<void> _toggle() async {
    final next = !showRoadview;
    await controller
        ?.setViewMode(next ? RoadviewViewMode.split : RoadviewViewMode.map);
    setState(() => showRoadview = next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? selectedTitle)),
      body: KakaoMapRoadviewView(
        center: LatLng(33.450701, 126.570667),
        initialViewMode: RoadviewViewMode.map,
        showRoadviewOverlay: true,
        useMapWalker: true,
        onCreated: (c) => controller = c,
      ),
      floatingActionButton: KakaoMapPointerInterceptor(
          child: FloatingActionButton.extended(
        onPressed: _toggle,
        label: Text(showRoadview ? '로드뷰 닫기' : '로드뷰 열기'),
        icon: Icon(showRoadview ? Icons.map : Icons.streetview),
      )),
    );
  }
}
