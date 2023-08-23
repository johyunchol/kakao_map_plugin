import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 중심좌표 변경 이벤트 등록하기
/// https://apis.map.kakao.com/web/sample/addMapCenterChangedEvent/
class Map20CenterChangeScreen extends StatefulWidget {
  const Map20CenterChangeScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Map20CenterChangeScreen> createState() =>
      _Map20CenterChangeScreenState();
}

class _Map20CenterChangeScreenState extends State<Map20CenterChangeScreen> {
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
            onCenterChangeCallback: ((latlng, zoomLevel) {
              message = '지도 레벨은 $zoomLevel 이고\n';
              message +=
                  '중심 좌표는 위도 ${latlng.latitude},\n경도 ${latlng.longitude} 입니다';

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
