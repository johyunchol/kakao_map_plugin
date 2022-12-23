import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 카테고리로 장소 검색하기
/// https://apis.map.kakao.com/web/sample/categoryBasic/
class Library3CategoryScreen extends StatefulWidget {
  const Library3CategoryScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Library3CategoryScreen> createState() => _Library3CategoryScreenState();
}

class _Library3CategoryScreenState extends State<Library3CategoryScreen> {
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
