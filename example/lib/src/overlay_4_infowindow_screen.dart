import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 인포윈도우 생성하기
/// https://apis.map.kakao.com/web/sample/basicInfoWindow/
class Overlay4InfoWindowScreen extends StatefulWidget {
  const Overlay4InfoWindowScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Overlay4InfoWindowScreen> createState() =>
      _Overlay4InfoWindowScreenState();
}

class _Overlay4InfoWindowScreenState extends State<Overlay4InfoWindowScreen> {
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
            markerId: markers.length.toString(),
            latLng: await mapController.getCenter(),
            infoWindowContent: '<div style="padding:15px;">Hello World!</div>',
            infoWindowRemovable: false,
            infoWindowFirstShow: true,
          ));

          setState(() {});
        }),
        markers: markers.toList(),
        center: LatLng(37.3608681, 126.9306506),
      ),
    );
  }
}
