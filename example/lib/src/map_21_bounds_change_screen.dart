import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 영역 변경 이벤트 등록하기
/// https://apis.map.kakao.com/web/sample/addMapBoundsChangedEvent/
class Map21BoundsChangeScreen extends StatefulWidget {
  const Map21BoundsChangeScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Map21BoundsChangeScreen> createState() =>
      _Map21BoundsChangeScreenState();
}

class _Map21BoundsChangeScreenState extends State<Map21BoundsChangeScreen> {
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
            onBoundsChangeCallback: ((latLngBounds) {
              final ne = latLngBounds.getNorthEast();
              final sw = latLngBounds.getSouthWest();

              message =
                  '영역좌표는 남서쪽 위도, 경도는\n${sw.latitude}, ${sw.longitude}이고\n';
              message += '북동쪽 위도, 경도는\n${ne.latitude}, ${ne.longitude}입니다';

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
