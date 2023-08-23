import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// Drawing Library 사용하기
/// https://apis.map.kakao.com/web/sample/basicDrawingLibrary/
class Library11DrawingLibraryScreen extends StatefulWidget {
  const Library11DrawingLibraryScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Library11DrawingLibraryScreen> createState() =>
      _Library11DrawingLibraryScreenState();
}

class _Library11DrawingLibraryScreenState
    extends State<Library11DrawingLibraryScreen> {
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
