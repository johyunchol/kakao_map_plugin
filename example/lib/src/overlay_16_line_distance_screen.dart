import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 선의 거리 계산하기
/// https://apis.map.kakao.com/web/sample/calculatePolylineDistance/
class Overlay16LineDistanceScreen extends StatefulWidget {
  const Overlay16LineDistanceScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Overlay16LineDistanceScreen> createState() =>
      _Overlay16LineDistanceScreenState();
}

class _Overlay16LineDistanceScreenState
    extends State<Overlay16LineDistanceScreen> {
  late KakaoMapController mapController;

  Set<Marker> markers = {};
  List<Polyline> polylines = [];
  List<CustomOverlay> customOverlays = [];

  bool drawingFlag = false;

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
            width: 30,
            height: 44,
            offsetX: 15,
            offsetY: 44,
            markerImageSrc:
                'https://w7.pngwing.com/pngs/96/889/png-transparent-marker-map-interesting-places-the-location-on-the-map-the-location-of-the-thumbnail.png',
          ));

          // 지도 생성이 늦어 화면이 먼저 닫힌 경우를 대비합니다.
          if (!mounted) return;
          setState(() {});
        }),
        onMapTap: (latLng) {
          if (!drawingFlag) {
            // 첫 탭: 새 선을 시작합니다. (완료 버튼을 누를 때까지 탭마다 점이 추가됩니다)
            drawingFlag = true;
            polylines.clear();
            customOverlays.clear();

            polylines.add(
              Polyline(
                polylineId: 'clickLine',
                points: [latLng],
                strokeWidth: 3,
                strokeColor: const Color(0xffdb4040),
                strokeOpacity: 1,
                strokeStyle: StrokeStyle.solid,
              ),
            );

            polylines.add(
              Polyline(
                polylineId: 'moveLine',
                strokeWidth: 3,
                strokeColor: const Color(0xffdb4040),
                strokeOpacity: 0.5,
                strokeStyle: StrokeStyle.solid,
              ),
            );
          } else {
            // 선이 그려지고 있는 상태이면 클릭한 위치까지 선을 잇고,
            // SDK 가 계산한 길이(getLength)를 점과 함께 표시합니다.
            final line =
                polylines.firstWhere((p) => p.polylineId == 'clickLine');
            final path = [...?line.points, latLng];
            polylines.removeWhere((p) => p.polylineId == 'clickLine');
            polylines.insert(
              0,
              Polyline(
                polylineId: 'clickLine',
                points: path,
                strokeWidth: 3,
                strokeColor: const Color(0xffdb4040),
                strokeOpacity: 1,
                strokeStyle: StrokeStyle.solid,
              ),
            );
            _showDistanceDot(latLng);
          }

          setState(() {});
        },
        markers: markers.toList(),
        polylines: polylines,
        customOverlays: customOverlays,
        center: LatLng(37.3608681, 126.9306506),
      ),
      floatingActionButton: drawingFlag
          ? KakaoMapPointerInterceptor(
              child: FloatingActionButton.extended(
                onPressed: () => setState(() => drawingFlag = false),
                icon: const Icon(Icons.check),
                label: const Text('그리기 완료'),
              ),
            )
          : null,
    );
  }

  /// 클릭 지점에 점과 지금까지의 거리(m)를 표시합니다.
  ///
  /// 선은 위젯 속성으로 전달되어 다음 프레임에 지도에 반영되므로, 프레임이 끝난
  /// 뒤 SDK 에 길이를 물어봅니다.
  Future<void> _showDistanceDot(LatLng position) async {
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    try {
      final distance = await mapController.getPolylineLength('clickLine');
      if (!mounted) return;
      setState(() {
        customOverlays.add(CustomOverlay(
          customOverlayId: 'dot_${customOverlays.length}',
          latLng: position,
          content: '<div style="position:relative;">'
              '<div style="width:10px;height:10px;margin:-5px 0 0 -5px;border-radius:50%;'
              'background:#fff;border:2px solid #db4040;"></div>'
              '<div style="position:absolute;left:12px;top:-14px;padding:2px 6px;border-radius:4px;'
              'background:rgba(255,255,255,.95);border:1px solid #db4040;font-size:12px;white-space:nowrap;">'
              '${distance.round()} m</div></div>',
          xAnchor: 0,
          yAnchor: 0,
          zIndex: 3,
        ));
      });
    } catch (e) {
      debugPrint('거리 조회 실패: $e');
    }
  }
}
