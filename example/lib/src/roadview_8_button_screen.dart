import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 지도 위 버튼으로 로드뷰 표시하기
/// https://apis.map.kakao.com/web/sample/roadviewWithMapButton/
class RoadView8ButtonScreen extends StatefulWidget {
  const RoadView8ButtonScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<RoadView8ButtonScreen> createState() => _RoadView8ButtonScreenState();
}

class _RoadView8ButtonScreenState extends State<RoadView8ButtonScreen> {
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
