import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 마커 클러스터러에 클릭이벤트 추가하기
/// https://apis.map.kakao.com/web/sample/addClustererClickEvent/
class Library9MarkerClustererClickEventScreen extends StatefulWidget {
  const Library9MarkerClustererClickEventScreen({Key? key, this.title})
      : super(key: key);

  final String? title;

  @override
  State<Library9MarkerClustererClickEventScreen> createState() =>
      _Library9MarkerClustererClickEventScreenState();
}

class _Library9MarkerClustererClickEventScreenState
    extends State<Library9MarkerClustererClickEventScreen> {
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
