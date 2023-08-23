import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 클릭 이벤트 등록하기
/// https://apis.map.kakao.com/web/sample/addMapClickEvent/
class Map16ClickListenerScreen extends StatefulWidget {
  const Map16ClickListenerScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Map16ClickListenerScreen> createState() =>
      _Map16ClickListenerScreenState();
}

class _Map16ClickListenerScreenState extends State<Map16ClickListenerScreen> {
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
            onMapTap: ((latLng) {
              message = '클릭한 위치의 위도는 ${latLng.latitude}이고, \n';
              message += '경도는 ${latLng.longitude} 입니다';

              setState(() {});
            }),
            currentLevel: 8,
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
