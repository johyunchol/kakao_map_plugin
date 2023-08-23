import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 마커의 고도와 반경 조절하기
/// https://apis.map.kakao.com/web/sample/roadviewOverlay2/
class RoadView5Overlay2Screen extends StatefulWidget {
  const RoadView5Overlay2Screen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<RoadView5Overlay2Screen> createState() =>
      _RoadView5Overlay2ScreenState();
}

class _RoadView5Overlay2ScreenState extends State<RoadView5Overlay2Screen> {
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
