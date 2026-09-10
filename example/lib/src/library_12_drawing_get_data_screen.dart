import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// Drawing Library 에서 데이터 얻기
/// https://apis.map.kakao.com/web/sample/drawingGetData/
class Library12DrawingGetDataScreen extends StatefulWidget {
  const Library12DrawingGetDataScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Library12DrawingGetDataScreen> createState() =>
      _Library12DrawingGetDataScreenState();
}

class _Library12DrawingGetDataScreenState
    extends State<Library12DrawingGetDataScreen> {
  KakaoMapController? mapController;
  List<String> summary = [];

  Future<void> _setup(KakaoMapController controller) async {
    mapController = controller;
    await controller.createDrawingManager(
      options: const DrawingOptions(
        drawingMode: [
          DrawingOverlayType.marker,
          DrawingOverlayType.polyline,
          DrawingOverlayType.rectangle,
          DrawingOverlayType.circle,
          DrawingOverlayType.polygon,
        ],
      ),
    );
    await controller.selectDrawingMode(DrawingOverlayType.polyline);
  }

  /// 그린 도형 데이터를 읽어 종류별로 요약합니다.
  Future<void> _readData() async {
    final data = await mapController?.getDrawingData();
    if (data == null) return;

    final lines = <String>[];
    for (final m in data.markers) {
      lines.add('마커: ${m.position.latitude.toStringAsFixed(5)}, '
          '${m.position.longitude.toStringAsFixed(5)}');
    }
    for (final l in data.polylines) {
      lines.add('선: 좌표 ${l.points.length}개');
    }
    for (final r in data.rectangles) {
      lines.add('사각형: 남서 ${r.bounds.sw.latitude.toStringAsFixed(5)} / '
          '북동 ${r.bounds.ne.latitude.toStringAsFixed(5)}');
    }
    for (final c in data.circles) {
      lines.add('원: 반지름 ${c.radius.toStringAsFixed(1)}m');
    }
    for (final p in data.polygons) {
      lines.add('다각형: 꼭짓점 ${p.points.length}개');
    }

    setState(() {
      summary = lines.isEmpty ? ['그린 도형이 없습니다.'] : lines;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? selectedTitle)),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: KakaoMap(
              onMapCreated: _setup,
              center: LatLng(33.450701, 126.570667),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              color: Colors.grey.shade100,
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('그린 도형 데이터',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    if (summary.isEmpty)
                      const Text('지도에 도형을 그린 뒤 아래 버튼을 누르세요.',
                          style: TextStyle(fontSize: 13))
                    else
                      ...summary.map((e) =>
                          Text(e, style: const TextStyle(fontSize: 13))),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _readData,
        label: const Text('데이터 얻기'),
        icon: const Icon(Icons.download),
      ),
    );
  }
}
