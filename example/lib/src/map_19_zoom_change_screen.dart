import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 확대, 축소 이벤트 등록하기
/// https://apis.map.kakao.com/web/sample/addMapClickEventWithMarker/
class Map19ZoomChangeScreen extends StatefulWidget {
  const Map19ZoomChangeScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Map19ZoomChangeScreen> createState() => _Map19ZoomChangeScreenState();
}

class _Map19ZoomChangeScreenState extends State<Map19ZoomChangeScreen> {
  late KakaoMapController mapController;

  String message = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: Stack(
        children: [
          KakaoMap(
            onMapCreated: ((controller) async {
              mapController = controller;
            }),
            currentLevel: 8,
            onZoomChangeCallback: ((zoomLevel, zoomType) {
              message = '현재 지도 레벨은 $zoomLevel 입니다';

              setState(() {});
            }),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              color: Colors.white,
              child: Text(message),
            ),
          )
        ],
      ),
    );
  }
}
