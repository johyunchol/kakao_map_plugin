import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 여러개 마커에 이벤트 등록하기1
/// https://apis.map.kakao.com/web/sample/multipleMarkerEvent/
class Overlay12MarkersEvent1Screen extends StatefulWidget {
  const Overlay12MarkersEvent1Screen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Overlay12MarkersEvent1Screen> createState() =>
      _Overlay12MarkersEvent1ScreenState();
}

class _Overlay12MarkersEvent1ScreenState
    extends State<Overlay12MarkersEvent1Screen> {
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
              latLng: LatLng(33.450705, 126.570677),
              infoWindowContent: '<div>카카오</div>'));

          markers.add(Marker(
              markerId: markers.length.toString(),
              latLng: LatLng(33.450936, 126.569477),
              infoWindowContent: '<div>생태연못</div>'));

          markers.add(Marker(
              markerId: markers.length.toString(),
              latLng: LatLng(33.450879, 126.569940),
              infoWindowContent: '<div>텃밭</div>'));

          markers.add(Marker(
              markerId: markers.length.toString(),
              latLng: LatLng(33.451393, 126.570738),
              infoWindowContent: '<div>근린공원</div>'));

          setState(() {});
        }),
        markers: markers.toList(),
        center: LatLng(33.450705, 126.570677),
        onMarkerTap: (markerId, latLng, zoomLevel) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('marker click:\n\n$latLng')));
        },
      ),
    );
  }
}
