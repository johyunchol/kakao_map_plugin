import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 마커 생성하기
/// https://apis.map.kakao.com/web/sample/basicMarker/
class Overlay1MarkerScreen extends StatefulWidget {
  const Overlay1MarkerScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Overlay1MarkerScreen> createState() => _Overlay1MarkerScreenState();
}

class _Overlay1MarkerScreenState extends State<Overlay1MarkerScreen> {
  late KakaoMapController mapController;

  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: KakaoMap(
        onMapCreated: ((controller) async {
          mapController = controller;

          markers.add(Marker(
            markerId: UniqueKey().toString(),
            latLng: await mapController.getCenter(),
          ));

          setState(() {});
        }),
        markers: markers.toList(),
        center: LatLng(37.3608681, 126.9306506),
      ),
    );
  }
}
