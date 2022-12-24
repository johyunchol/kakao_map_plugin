import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 로드뷰 생성하기
/// https://apis.map.kakao.com/web/sample/basicRoadview/
class RoadView1DefaultScreen extends StatefulWidget {
  const RoadView1DefaultScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<RoadView1DefaultScreen> createState() => _RoadView1DefaultScreenState();
}

class _RoadView1DefaultScreenState extends State<RoadView1DefaultScreen> {
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
