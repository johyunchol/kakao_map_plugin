import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 지도 정보 얻어오기
/// https://apis.map.kakao.com/web/sample/mapInfo/
class Map4InfoScreen extends StatefulWidget {
  const Map4InfoScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Map4InfoScreen> createState() => _Map4InfoScreenState();
}

class _Map4InfoScreenState extends State<Map4InfoScreen> {
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

              final center = await mapController.getCenter();
              final level = await mapController.getLevel();
              final mapTypeId = await mapController.getMapTypeId();
              final bounds = await mapController.getBounds();
              final swLatLng = bounds.getSouthWest();
              final neLatLng = bounds.getNorthEast();

              message +=
                  '지도 중심좌표는 위도 ${center.latitude}, 경도 ${center.longitude}\n';
              message += '지도 레벨은 $level\n';
              message += '지도 타입은 ${mapTypeId.name}\n';
              message +=
                  '지도의 남서쪽 좌표는 ${swLatLng.latitude}, ${swLatLng.longitude} 이고\n';
              message +=
                  '북동쪽 좌표는 ${neLatLng.latitude}, ${neLatLng.longitude} 입니다\n';

              setState(() {});
            }),
            mapTypeControl: true,
            mapTypeControlPosition: ControlPosition.topRight,
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: SafeArea(
              child: Container(
                width: double.infinity,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(message),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
