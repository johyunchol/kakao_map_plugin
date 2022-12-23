import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 타일로드 이벤트 등록하기
/// https://apis.map.kakao.com/web/sample/addTilesloadedEvent/
class Map22TilesLoadedScreen extends StatefulWidget {
  const Map22TilesLoadedScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Map22TilesLoadedScreen> createState() => _Map22TilesLoadedScreenState();
}

class _Map22TilesLoadedScreenState extends State<Map22TilesLoadedScreen> {
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
            onTilesLoadedCallback: ((latLng, zoomLevel) {
              message = 'tiles loaded!!';

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
