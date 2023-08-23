import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// WTM 좌표를 WGS84 좌표로 변환하기
/// https://apis.map.kakao.com/web/sample/transCoord/
class Library7transCoordsScreen extends StatefulWidget {
  const Library7transCoordsScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Library7transCoordsScreen> createState() =>
      _Library7transCoordsScreenState();
}

class _Library7transCoordsScreenState extends State<Library7transCoordsScreen> {
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
