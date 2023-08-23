import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 여러개 마커 제어하기
/// https://apis.map.kakao.com/web/sample/multipleMarkerControl/
class Overlay11MarkersControlScreen extends StatefulWidget {
  const Overlay11MarkersControlScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Overlay11MarkersControlScreen> createState() =>
      _Overlay11MarkersControlScreenState();
}

class _Overlay11MarkersControlScreenState
    extends State<Overlay11MarkersControlScreen> {
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
        }),
        markers: markers.toList(),
        center: LatLng(37.3608681, 126.9306506),
        onMapTap: (latLng) {
          markers.add(Marker(
            markerId: markers.length.toString(),
            latLng: latLng,
          ));

          setState(() {});
        },
      ),
    );
  }
}
