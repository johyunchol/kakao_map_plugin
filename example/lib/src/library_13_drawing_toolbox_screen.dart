import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// Toolbox 사용하기
/// https://apis.map.kakao.com/web/sample/drawingToolbox/
class Library13DrawingToolboxScreen extends StatefulWidget {
  const Library13DrawingToolboxScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Library13DrawingToolboxScreen> createState() =>
      _Library13DrawingToolboxScreenState();
}

class _Library13DrawingToolboxScreenState
    extends State<Library13DrawingToolboxScreen> {
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
