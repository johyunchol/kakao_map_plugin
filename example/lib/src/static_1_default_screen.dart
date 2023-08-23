import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 이미지 지도 생성하기
/// https://apis.map.kakao.com/web/sample/staticMap/
class Static1DefaultScreen extends StatefulWidget {
  const Static1DefaultScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Static1DefaultScreen> createState() => _Static1DefaultScreenState();
}

class _Static1DefaultScreenState extends State<Static1DefaultScreen> {
  late KakaoMapController mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: KakaoStaticMap(),
    );
  }
}
