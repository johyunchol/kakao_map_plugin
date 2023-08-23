import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 카테고리별 장소 검색하기
/// https://apis.map.kakao.com/web/sample/categoryFromBounds/
class Library4CategoryBoundsScreen extends StatefulWidget {
  const Library4CategoryBoundsScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Library4CategoryBoundsScreen> createState() =>
      _Library4CategoryBoundsScreenState();
}

class _Library4CategoryBoundsScreenState
    extends State<Library4CategoryBoundsScreen> {
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
