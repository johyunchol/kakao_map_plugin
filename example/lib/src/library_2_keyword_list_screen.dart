import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 키워드로 장소검색하고 목록으로 표출하기
/// https://apis.map.kakao.com/web/sample/keywordList/
class Library2KeywordListScreen extends StatefulWidget {
  const Library2KeywordListScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Library2KeywordListScreen> createState() =>
      _Library2KeywordListScreenState();
}

class _Library2KeywordListScreenState extends State<Library2KeywordListScreen> {
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
