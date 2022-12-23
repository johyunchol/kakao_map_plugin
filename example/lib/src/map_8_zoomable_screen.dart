import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 지도 확대 축소 막기
/// https://apis.map.kakao.com/web/sample/enableDisableZoomInOut/
class Map8ZoomableScreen extends StatefulWidget {
  const Map8ZoomableScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Map8ZoomableScreen> createState() => _Map8ZoomableScreenState();
}

class _Map8ZoomableScreenState extends State<Map8ZoomableScreen> {
  late KakaoMapController mapController;

  bool isZoomable = true;

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
                  isZoomable = !isZoomable;
                  mapController.setZoomable(isZoomable);
                  setState(() {});
                },
                color: isZoomable ? Colors.blue : Colors.grey,
                child: const Text('zoomable'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
