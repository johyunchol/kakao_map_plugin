import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 지도 이동시키기
/// https://apis.map.kakao.com/web/sample/moveMap/
class Map2MoveScreen extends StatefulWidget {
  const Map2MoveScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Map2MoveScreen> createState() => _Map2MoveScreenState();
}

class _Map2MoveScreenState extends State<Map2MoveScreen> {
  late KakaoMapController mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: Stack(
        children: [
          KakaoMap(
            onMapCreated: ((controller) {
              mapController = controller;
            }),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                MaterialButton(
                  onPressed: () =>
                      mapController.setCenter(LatLng(33.452613, 126.570888)),
                  color: Colors.white,
                  child: const Text("setCenter"),
                ),
                const SizedBox(width: 8),
                MaterialButton(
                  onPressed: () =>
                      mapController.panTo(LatLng(33.450580, 126.574942)),
                  color: Colors.white,
                  child: const Text("panTo"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
