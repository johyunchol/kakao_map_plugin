import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 다른 이미지로 마커 생성하기
/// https://apis.map.kakao.com/web/sample/basicMarkerImage/
class Overlay3MarkerImageScreen extends StatefulWidget {
  const Overlay3MarkerImageScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Overlay3MarkerImageScreen> createState() =>
      _Overlay3MarkerImageScreenState();
}

class _Overlay3MarkerImageScreenState extends State<Overlay3MarkerImageScreen> {
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

          var latLng = await mapController.getCenter();

          /// 기존방법 - url 에서 이미지 불러오는 방법
          markers.add(Marker(
            markerId: markers.length.toString(),
            latLng: latLng,
            width: 30,
            height: 44,
            offsetX: 15,
            offsetY: 44,
            markerImageSrc:
                'https://w7.pngwing.com/pngs/96/889/png-transparent-marker-map-interesting-places-the-location-on-the-map-the-location-of-the-thumbnail.png',
          ));

          /// 새로운방법 - asset 에서 이미지 불러오는 방법
          markers.add(Marker(
            markerId: markers.length.toString(),
            latLng: LatLng(latLng.latitude + 0.001, latLng.longitude + 0.001),
            width: 80,
            height: 100,
            offsetX: 15,
            offsetY: 44,
            icon: await MarkerIcon.fromAsset(
              'assets/images/marker2.png',
            ),
          ));

          /// 새로운방법 - url 에서 이미지 불러오는 방법
          markers.add(Marker(
            markerId: markers.length.toString(),
            latLng: LatLng(latLng.latitude + 0.001, latLng.longitude - 0.001),
            width: 30,
            height: 44,
            offsetX: 15,
            offsetY: 44,
            icon: await MarkerIcon.fromNetwork(
              'https://w7.pngwing.com/pngs/96/889/png-transparent-marker-map-interesting-places-the-location-on-the-map-the-location-of-the-thumbnail.png',
            ),
          ));

          setState(() {});
        }),
        markers: markers.toList(),
        center: LatLng(37.3608681, 126.9306506),
      ),
    );
  }
}
