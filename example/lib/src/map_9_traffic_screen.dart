import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 지도에 교통정보 표시하기
/// https://apis.map.kakao.com/web/sample/addTrafficOverlay/
class Map9TrafficScreen extends StatefulWidget {
  const Map9TrafficScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Map9TrafficScreen> createState() => _Map9TrafficScreenState();
}

class _Map9TrafficScreenState extends State<Map9TrafficScreen> {
  late KakaoMapController mapController;

  bool isTrafficLine = false;

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
                  isTrafficLine = !isTrafficLine;

                  isTrafficLine
                      ? mapController.addOverlayMapTypeId(MapType.traffic)
                      : mapController.removeOverlayMapTypeId(MapType.traffic);

                  setState(() {});
                },
                color: isTrafficLine ? Colors.blue : Colors.grey,
                child: const Text('교통정보 표시하기'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
