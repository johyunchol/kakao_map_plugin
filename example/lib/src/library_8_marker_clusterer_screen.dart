import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 마커 클러스터러 사용하기
/// https://apis.map.kakao.com/web/sample/basicClusterer/
class Library8MarkerClustererScreen extends StatefulWidget {
  const Library8MarkerClustererScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Library8MarkerClustererScreen> createState() =>
      _Library8MarkerClustererScreenState();
}

class _Library8MarkerClustererScreenState
    extends State<Library8MarkerClustererScreen> {
  late KakaoMapController mapController;

  bool draggable = true;
  bool zoomable = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: KakaoMap(),
    );
  }
}
