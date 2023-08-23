import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 로드뷰에 마커와 인포윈도우 올리기
/// https://apis.map.kakao.com/web/sample/roadviewOverlay1/
class RoadView4Overlay1Screen extends StatefulWidget {
  const RoadView4Overlay1Screen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<RoadView4Overlay1Screen> createState() =>
      _RoadView4Overlay1ScreenState();
}

class _RoadView4Overlay1ScreenState extends State<RoadView4Overlay1Screen> {
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
