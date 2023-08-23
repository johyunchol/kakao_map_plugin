import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 로드뷰와 지도 토글하기
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
  late KakaoMapController mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: KakaoRoadMap(),
    );
  }
}
