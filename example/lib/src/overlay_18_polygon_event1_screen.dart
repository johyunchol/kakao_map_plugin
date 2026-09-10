import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';
import 'package:kakao_map_plugin_example/src/hover_note.dart';

/// 다각형에 이벤트 등록하기1
/// https://apis.map.kakao.com/web/sample/addPolygonMouseEvent1
class Overlay18PolygonEvent1Screen extends StatefulWidget {
  const Overlay18PolygonEvent1Screen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Overlay18PolygonEvent1Screen> createState() =>
      _Overlay18PolygonEvent1ScreenState();
}

class _Overlay18PolygonEvent1ScreenState
    extends State<Overlay18PolygonEvent1Screen> {
  KakaoMapController? mapController;

  /// 탭한 다각형의 ID. 탭하면 색이 바뀝니다.
  String? selectedId;

  /// 탭한 지점의 좌표
  LatLng? tappedAt;

  List<Polygon> _polygons() => [
        Polygon(
          polygonId: 'area1',
          points: [
            LatLng(33.45, 126.57),
            LatLng(33.45, 126.58),
            LatLng(33.44, 126.58),
            LatLng(33.44, 126.57),
          ],
          strokeWidth: 2,
          strokeColor: Colors.blue,
          strokeOpacity: 0.8,
          fillColor: selectedId == 'area1' ? Colors.red : Colors.blue,
          fillOpacity: 0.4,
        ),
        Polygon(
          polygonId: 'area2',
          points: [
            LatLng(33.46, 126.56),
            LatLng(33.46, 126.57),
            LatLng(33.455, 126.57),
            LatLng(33.455, 126.56),
          ],
          strokeWidth: 2,
          strokeColor: Colors.green,
          strokeOpacity: 0.8,
          fillColor: selectedId == 'area2' ? Colors.red : Colors.green,
          fillOpacity: 0.4,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? selectedTitle)),
      body: Column(
        children: [
          HoverNote(
            controller: mapController,
            hoverText: '다각형 위에 마우스를 올리면 색이 바뀝니다.',
            touchText: '다각형을 탭하면 색이 바뀝니다.',
          ),
          Expanded(
              child: Stack(
            children: [
              KakaoMap(
                onMapCreated: (controller) =>
                    setState(() => mapController = controller),
                center: LatLng(33.4525, 126.5715),
                currentLevel: 5,
                polygons: _polygons(),
                // 다각형을 탭하면 ID 와 좌표를 받습니다. (터치 기기)
                onPolygonTap: (polygonId, latLng, zoomLevel) {
                  setState(() {
                    selectedId = polygonId;
                    tappedAt = latLng;
                  });
                },
                // 마우스 환경에서는 공식 샘플처럼 올리면 색이 바뀌고 벗어나면 돌아옵니다.
                onPolygonMouseOver: (polygonId, latLng, zoomLevel) {
                  setState(() {
                    selectedId = polygonId;
                    tappedAt = latLng;
                  });
                },
                onPolygonMouseOut: (polygonId, latLng, zoomLevel) {
                  setState(() => selectedId = null);
                },
              ),
              Positioned(
                left: 12,
                bottom: 12,
                right: 12,
                child: KakaoMapPointerInterceptor(
                    child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      selectedId == null
                          ? '다각형을 탭하면 색이 바뀝니다.'
                          : '선택: $selectedId\n'
                              '탭 위치: ${tappedAt!.latitude.toStringAsFixed(6)}, '
                              '${tappedAt!.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                )),
              ),
            ],
          )),
        ],
      ),
    );
  }
}
