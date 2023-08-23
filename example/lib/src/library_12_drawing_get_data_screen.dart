import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// Drawing Library에서 데이터 얻기
/// https://apis.map.kakao.com/web/sample/drawingGetData/
class Library12DrawingGetDataScreen extends StatefulWidget {
  const Library12DrawingGetDataScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Library12DrawingGetDataScreen> createState() =>
      _Library12DrawingGetDataScreenState();
}

class _Library12DrawingGetDataScreenState
    extends State<Library12DrawingGetDataScreen> {
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
