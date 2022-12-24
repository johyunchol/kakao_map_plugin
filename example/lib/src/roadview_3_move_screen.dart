import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 동동이를 이용하여 로드뷰와 지도 연동하기
/// https://apis.map.kakao.com/web/sample/moveRoadview/
class RoadView3MoveScreen extends StatefulWidget {
  const RoadView3MoveScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<RoadView3MoveScreen> createState() => _RoadView3MoveScreenState();
}

class _RoadView3MoveScreenState extends State<RoadView3MoveScreen> {
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
