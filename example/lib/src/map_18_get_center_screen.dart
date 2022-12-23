import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 이동 이벤트 등록하기
/// https://apis.map.kakao.com/web/sample/addMapDragendEvent/
class Map18GetCenterScreen extends StatefulWidget {
  const Map18GetCenterScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Map18GetCenterScreen> createState() => _Map18GetCenterScreenState();
}

class _Map18GetCenterScreenState extends State<Map18GetCenterScreen> {
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
            onDragChangeCallback: ((latLng, zoomLevel, dragType) async {
              switch (dragType) {
                case DragType.end:
                  final latLng = await mapController.getCenter();

                  message = '변경된 지도 중심좌표는 ${latLng.latitude} 이고,\n';
                  message += '경도는 ${latLng.longitude} 입니다';

                  setState(() {});
                  break;

                default:
                  break;
              }
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
