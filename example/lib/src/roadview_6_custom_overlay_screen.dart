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
