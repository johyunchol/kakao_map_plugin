import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 로드뷰 도로를 이용하여 로드뷰 생성하기
/// https://apis.map.kakao.com/web/sample/basicRoadview2/
class RoadView2DefaultScreen extends StatefulWidget {
  const RoadView2DefaultScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<RoadView2DefaultScreen> createState() => _RoadView2DefaultScreenState();
}

class _RoadView2DefaultScreenState extends State<RoadView2DefaultScreen> {
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
