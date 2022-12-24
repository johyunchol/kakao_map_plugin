import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 로드뷰에 이미지 올리기
/// https://apis.map.kakao.com/web/sample/roadviewImageOverlay/
class RoadView7ImageScreen extends StatefulWidget {
  const RoadView7ImageScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<RoadView7ImageScreen> createState() => _RoadView7ImageScreenState();
}

class _RoadView7ImageScreenState extends State<RoadView7ImageScreen> {
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
