import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/main.dart';
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
      // body: kIsWeb ? web() : Container(color: Colors.red),
      body: web(),
    );
  }

  Widget web() {
    print('>>>>>> 여기는 web');
    return KakaoMap(
      onMapCreated: (controller) {
        print('>>>>> 맵 생성!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');

        setState(() {
          mapController = controller;
        });
      },
      onMapTap: (latLng) {
        logger.d('>>>>> 맵 클릭 : ${latLng.toString()}');
      },
      onCenterChangeCallback: (latlng, zoomLevel) {
        logger.d('>>>>> 중심좌표 변경 : ${latlng.toString()}');
      },
      onZoomChangeCallback: (zoomLevel, zoomType) {
        logger.d('>>>>> 줌 레벨 변경 : $zoomLevel / $zoomType');
      },
      onBoundsChangeCallback: (latLngBounds) {
        final ne = latLngBounds.getNorthEast();
        final sw = latLngBounds.getSouthWest();

        var message = '영역좌표는 남서쪽 위도, 경도는\n${sw.latitude}, ${sw.longitude}이고\n';
        message += '북동쪽 위도, 경도는\n${ne.latitude}, ${ne.longitude}입니다';

        logger.d(message);
      },
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}
