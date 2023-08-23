import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 이미지 지도에 마커 표시하기
/// https://apis.map.kakao.com/web/sample/staticMapWithMarker/
class Static3MarkerTextScreen extends StatefulWidget {
  const Static3MarkerTextScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Static3MarkerTextScreen> createState() =>
      _Static3MarkerTextScreenState();
}

class _Static3MarkerTextScreenState extends State<Static3MarkerTextScreen> {
  late KakaoMapController mapController;

  Set<Marker> markers = {};

  @override
  void initState() {
    markers.add(Marker(
        markerId: 'markerId',
        latLng: LatLng(33.450701, 126.570667),
        infoWindowContent: '안녕하세요'));
    markers.add(Marker(
        markerId: 'markerId',
        latLng: LatLng(33.440701, 126.570667),
        infoWindowContent: '안녕하세요2'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: KakaoStaticMap(
        markers: markers.toList(),
        currentLevel: 6,
      ),
    );
  }
}
