import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// draggable 마커 이벤트 적용하기
/// https://apis.map.kakao.com/web/sample/addDraggableMarkerDragEvent/
class Overlay8MarkerDraggableEventScreen extends StatefulWidget {
  const Overlay8MarkerDraggableEventScreen({Key? key, this.title})
      : super(key: key);

  final String? title;

  @override
  State<Overlay8MarkerDraggableEventScreen> createState() =>
      _Overlay8MarkerDraggableEventScreenState();
}

class _Overlay8MarkerDraggableEventScreenState
    extends State<Overlay8MarkerDraggableEventScreen> {
  late KakaoMapController mapController;

  Set<Marker> markers = {};

  final List<String> eventLog = [];

  @override
  void initState() {
    super.initState();
  }

  void _handleMarkerDragChange(
    String markerId,
    LatLng latLng,
    int zoomLevel,
    MarkerDragType dragType,
  ) {
    setState(() {
      final label = dragType == MarkerDragType.start ? '드래그 시작' : '드래그 종료';
      final lat = latLng.latitude.toStringAsFixed(6);
      final lng = latLng.longitude.toStringAsFixed(6);

      eventLog.insert(0, '$label · 위도: $lat, 경도: $lng');
      if (eventLog.length > 5) {
        eventLog.removeRange(5, eventLog.length);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: Stack(
        children: [
          KakaoMap(
            onMapCreated: ((controller) async {
              mapController = controller;

              markers.add(Marker(
                markerId: 'draggableMarker',
                latLng: await mapController.getCenter(),
                width: 30,
                height: 44,
                offsetX: 15,
                offsetY: 44,
                draggable: true,
              ));

              // 지도 생성이 늦어 화면이 먼저 닫힌 경우를 대비합니다.
              if (!mounted) return;
              setState(() {});
            }),
            onMarkerDragChangeCallback: _handleMarkerDragChange,
            markers: markers.toList(),
            center: LatLng(37.3608681, 126.9306506),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: KakaoMapPointerInterceptor(
                child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '마커를 드래그해 보세요 (최근 5건)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (eventLog.isEmpty)
                      const Text('아직 드래그 이벤트가 없습니다')
                    else
                      ...eventLog.map((e) => Text(e)),
                  ],
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }
}
