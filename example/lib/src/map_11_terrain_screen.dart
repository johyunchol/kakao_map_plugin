import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 지도에 지형도 표시하기
/// https://apis.map.kakao.com/web/sample/addTerrainOverlay/
class Map11TerrainScreen extends StatefulWidget {
  const Map11TerrainScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Map11TerrainScreen> createState() => _Map11TerrainScreenState();
}

class _Map11TerrainScreenState extends State<Map11TerrainScreen> {
  late KakaoMapController mapController;

  bool isTerrain = false;

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
          ),
          Row(
            children: [
              MaterialButton(
                onPressed: () {
                  isTerrain = !isTerrain;

                  isTerrain
                      ? mapController.addOverlayMapTypeId(MapType.terrain)
                      : mapController.removeOverlayMapTypeId(MapType.terrain);

                  setState(() {});
                },
                color: isTerrain ? Colors.blue : Colors.grey,
                child: const Text('지형도 표시하기'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
