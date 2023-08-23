import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 키워드로 장소검색하기
/// https://apis.map.kakao.com/web/sample/keywordBasic/
class Library1KeywordScreen extends StatefulWidget {
  const Library1KeywordScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Library1KeywordScreen> createState() => _Library1KeywordScreenState();
}

class _Library1KeywordScreenState extends State<Library1KeywordScreen> {
  late KakaoMapController mapController;

  bool draggable = true;
  bool zoomable = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: KakaoMap(
        onMapCreated: ((controller) async {
          mapController = controller;

          await controller.keywordSearch();
        }),
      ),
    );
  }
}
