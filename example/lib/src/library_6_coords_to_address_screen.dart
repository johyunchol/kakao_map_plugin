import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 좌표로 주소를 얻어내기
/// https://apis.map.kakao.com/web/sample/coord2addr/
class Library6CoordsToAddressScreen extends StatefulWidget {
  const Library6CoordsToAddressScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Library6CoordsToAddressScreen> createState() =>
      _Library6CoordsToAddressScreenState();
}

class _Library6CoordsToAddressScreenState
    extends State<Library6CoordsToAddressScreen> {
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
