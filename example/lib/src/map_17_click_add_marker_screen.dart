import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 클릭한 위치에 마커 표시하기
/// https://apis.map.kakao.com/web/sample/addMapClickEventWithMarker/
class Map17ClickAddMarkerScreen extends StatefulWidget {
  const Map17ClickAddMarkerScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Map17ClickAddMarkerScreen> createState() =>
      _Map17ClickAddMarkerScreenState();
}

class _Map17ClickAddMarkerScreenState extends State<Map17ClickAddMarkerScreen> {
  late KakaoMapController mapController;

  late Marker marker;
  Set<Marker> markers = {};

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

              marker = Marker(
                markerId: markers.length.toString(),
                latLng: await mapController.getCenter(),
                width: 30,
                height: 44,
                offsetX: 15,
                offsetY: 44,
              );

              markers.add(marker);

              mapController.addMarker(markers: markers.toList());
            }),
            onMapTap: ((latLng) {
              marker.latLng = latLng;

              mapController.panTo(latLng);
              setState(() {});
            }),
            currentLevel: 8,
            markers: markers.toList(),
          ),
        ],
      ),
    );
  }
}
