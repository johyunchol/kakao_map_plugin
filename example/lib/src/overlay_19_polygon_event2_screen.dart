import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';
import 'package:kakao_map_plugin_example/src/hover_note.dart';

/// 다각형에 이벤트 등록하기2
/// https://apis.map.kakao.com/web/sample/addPolygonMouseEvent2
class Overlay19PolygonEvent2Screen extends StatefulWidget {
  const Overlay19PolygonEvent2Screen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Overlay19PolygonEvent2Screen> createState() =>
      _Overlay19PolygonEvent2ScreenState();
}

class _Overlay19PolygonEvent2ScreenState
    extends State<Overlay19PolygonEvent2Screen> {
  KakaoMapController? mapController;

  /// 구역별 안내 문구
  static const Map<String, String> areaNames = {
    'zone1': '1구역 — 관광지',
    'zone2': '2구역 — 상업지구',
    'zone3': '3구역 — 주거지',
  };

  /// 탭한 구역 위치에 띄울 커스텀 오버레이
  List<CustomOverlay> customOverlays = [];

  List<Polygon> _polygons() {
    final specs = <String, List<LatLng>>{
      'zone1': [
        LatLng(33.455, 126.565),
        LatLng(33.455, 126.575),
        LatLng(33.449, 126.575),
        LatLng(33.449, 126.565),
      ],
      'zone2': [
        LatLng(33.462, 126.565),
        LatLng(33.462, 126.575),
        LatLng(33.457, 126.575),
        LatLng(33.457, 126.565),
      ],
      'zone3': [
        LatLng(33.447, 126.578),
        LatLng(33.447, 126.588),
        LatLng(33.441, 126.588),
        LatLng(33.441, 126.578),
      ],
    };
    final colors = {
      'zone1': Colors.orange,
      'zone2': Colors.purple,
      'zone3': Colors.teal,
    };

    return specs.entries
        .map((e) => Polygon(
              polygonId: e.key,
              points: e.value,
              strokeWidth: 2,
              strokeColor: colors[e.key],
              strokeOpacity: 0.9,
              fillColor: colors[e.key],
              fillOpacity: 0.3,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? selectedTitle)),
      body: Column(children: [
        HoverNote(
          controller: mapController,
          hoverText: '다각형 위에서 마우스를 움직이면 이름 툴팁이 따라옵니다.',
          touchText: '다각형을 탭하면 이름이 표시됩니다.',
        ),
        Expanded(
            child: KakaoMap(
          onMapCreated: (controller) =>
              setState(() => mapController = controller),
          center: LatLng(33.4525, 126.5755),
          currentLevel: 6,
          polygons: _polygons(),
          customOverlays: customOverlays,
          // 다각형을 탭하면 그 위치에 안내 오버레이를 띄웁니다.
          onPolygonTap: (polygonId, latLng, zoomLevel) {
            setState(() {
              customOverlays = [
                CustomOverlay(
                  customOverlayId: 'info',
                  latLng: latLng,
                  content: '<div style="padding:8px 12px;background:#fff;'
                      'border:2px solid #333;border-radius:6px;font-size:13px;'
                      'white-space:nowrap;">'
                      '${areaNames[polygonId] ?? polygonId}</div>',
                  xAnchor: 0.5,
                  yAnchor: 1.2,
                  // 닫기 버튼을 붙여 사용자가 직접 닫을 수 있게 합니다.
                  removable: true,
                ),
              ];
            });
          },
          // 마우스 환경: 포인터를 따라다니는 툴팁 (공식 샘플의 mousemove)
          onPolygonMouseMove: (polygonId, latLng, zoomLevel) {
            setState(() {
              customOverlays = [
                CustomOverlay(
                  customOverlayId: 'tooltip',
                  latLng: latLng,
                  content:
                      '<div style="padding:4px 8px;background:#333;color:#fff;'
                      'border-radius:4px;font-size:12px;white-space:nowrap;">'
                      '${areaNames[polygonId] ?? polygonId}</div>',
                  xAnchor: -0.1,
                  yAnchor: 1.4,
                ),
              ];
            });
          },
          onPolygonMouseOut: (polygonId, latLng, zoomLevel) {
            setState(() => customOverlays = []);
          },
          onCustomOverlayRemove: (overlayId) {
            setState(() => customOverlays = []);
          },
        )),
      ]),
    );
  }
}
