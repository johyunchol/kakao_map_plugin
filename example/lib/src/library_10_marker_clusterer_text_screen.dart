import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 클러스터 마커에 텍스트 표시하기
/// https://apis.map.kakao.com/web/sample/chickenClusterer/
class Library10MarkerClustererTextScreen extends StatefulWidget {
  const Library10MarkerClustererTextScreen({Key? key, this.title})
      : super(key: key);

  final String? title;

  @override
  State<Library10MarkerClustererTextScreen> createState() =>
      _Library10MarkerClustererTextScreenState();
}

class _Library10MarkerClustererTextScreenState
    extends State<Library10MarkerClustererTextScreen> {
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
