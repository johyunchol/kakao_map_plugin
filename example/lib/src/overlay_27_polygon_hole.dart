import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 구멍난 다각형 만들기
/// https://apis.map.kakao.com/web/sample/donut/
class Overlay27PolygonHoleScreen extends StatefulWidget {
  const Overlay27PolygonHoleScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Overlay27PolygonHoleScreen> createState() =>
      _Overlay27PolygonHoleScreenState();
}

class _Overlay27PolygonHoleScreenState
    extends State<Overlay27PolygonHoleScreen> {
  late KakaoMapController mapController;

  List<Polygon> polygons = [];

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

          polygons.add(
            Polygon(
              polygonId: 'polygon_${polygons.length}',
              points: [
                LatLng(33.45086654081833, 126.56906858718982),
                LatLng(33.45010890948828, 126.56898629127468),
                LatLng(33.44979857909499, 126.57049357211622),
                LatLng(33.450137483918496, 126.57202991943016),
                LatLng(33.450706188506054, 126.57223147947938),
                LatLng(33.45164068091554, 126.5713126693152),
              ],
              holes: [
                [
                  LatLng(33.4506262491095, 126.56997323165163),
                  LatLng(33.45029422800042, 126.57042659659218),
                  LatLng(33.45032339792896, 126.5710395101452),
                  LatLng(33.450622037218295, 126.57136070280123),
                  LatLng(33.450964416902046, 126.57129448564594),
                  LatLng(33.4510527150534, 126.57075627706975)
                ]
              ],
              strokeWidth: 2,
              strokeColor: const Color(0xffb26bb2),
              strokeOpacity: 0.8,
              strokeStyle: StrokeStyle.shortDashDot,
              fillColor: const Color(0xffff99ff),
              fillOpacity: 0.7,
            ),
          );

          setState(() {});
        }),
        polygons: polygons,
        center: LatLng(33.450701, 126.570667),
      ),
    );
  }
}
