import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 주소로 장소 표시하기
/// https://apis.map.kakao.com/web/sample/addr2coord/
class Library5AddressToCoordsScreen extends StatefulWidget {
  const Library5AddressToCoordsScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Library5AddressToCoordsScreen> createState() =>
      _Library5AddressToCoordsScreenState();
}

class _Library5AddressToCoordsScreenState
    extends State<Library5AddressToCoordsScreen> {
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
