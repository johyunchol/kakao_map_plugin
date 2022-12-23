import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 지도에 로드뷰 도로 표시하기
/// https://apis.map.kakao.com/web/sample/addRoadviewOverlay/
class Map10RoadViewScreen extends StatefulWidget {
  const Map10RoadViewScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Map10RoadViewScreen> createState() => _Map10RoadViewScreenState();
}

class _Map10RoadViewScreenState extends State<Map10RoadViewScreen> {
  late KakaoMapController mapController;

  bool isRoadView = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: Stack(
        children: [
          KakaoMap(onMapCreated: ((controller) async {
            mapController = controller;
          })),
          Row(
            children: [
              MaterialButton(
                onPressed: () {
                  isRoadView = !isRoadView;

                  isRoadView
                      ? mapController.addOverlayMapTypeId(MapType.roadView)
                      : mapController.removeOverlayMapTypeId(MapType.roadView);

                  setState(() {});
                },
                color: isRoadView ? Colors.blue : Colors.grey,
                child: const Text('로드뷰 표시하기'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
