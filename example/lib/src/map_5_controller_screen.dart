import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 지도에 컨트롤 올리기
/// https://apis.map.kakao.com/web/sample/addMapControl/
class Map5ControllerScreen extends StatefulWidget {
  const Map5ControllerScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Map5ControllerScreen> createState() => _Map5ControllerScreenState();
}

class _Map5ControllerScreenState extends State<Map5ControllerScreen> {
  late KakaoMapController mapController;

  String message = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: KakaoMap(
        onMapCreated: ((controller) async {
          mapController = controller;

          setState(() {});
        }),
        mapTypeControl: true,
        mapTypeControlPosition: ControlPosition.topRight,
        zoomControl: true,
        zoomControlPosition: ControlPosition.right,
      ),
    );
  }
}
