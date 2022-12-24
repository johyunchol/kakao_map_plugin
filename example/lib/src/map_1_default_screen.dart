import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 지도 생성하기
/// https://apis.map.kakao.com/web/sample/basicMap/
class Map1DefaultScreen extends StatefulWidget {
  const Map1DefaultScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Map1DefaultScreen> createState() => _Map1DefaultScreenState();
}

class _Map1DefaultScreenState extends State<Map1DefaultScreen> {
  late KakaoMapController mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: KakaoMap(
        onMapTap: (latLng) {
          print(latLng);
        },
      ),
    );
  }
}
