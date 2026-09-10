import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// Drawing Library 사용하기
/// https://apis.map.kakao.com/web/sample/basicDrawingLibrary/
class Library11DrawingLibraryScreen extends StatefulWidget {
  const Library11DrawingLibraryScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Library11DrawingLibraryScreen> createState() =>
      _Library11DrawingLibraryScreenState();
}

class _Library11DrawingLibraryScreenState
    extends State<Library11DrawingLibraryScreen> {
  KakaoMapController? mapController;
  DrawingOverlayType selected = DrawingOverlayType.marker;
  String message = '아래에서 도형을 고르고 지도를 조작해 보세요.';

  static const List<DrawingOverlayType> _modes = [
    DrawingOverlayType.marker,
    DrawingOverlayType.polyline,
    DrawingOverlayType.rectangle,
    DrawingOverlayType.circle,
    DrawingOverlayType.polygon,
    DrawingOverlayType.arrow,
  ];

  static const Map<DrawingOverlayType, String> _labels = {
    DrawingOverlayType.marker: '마커',
    DrawingOverlayType.polyline: '선',
    DrawingOverlayType.rectangle: '사각형',
    DrawingOverlayType.circle: '원',
    DrawingOverlayType.polygon: '다각형',
    DrawingOverlayType.arrow: '화살표',
  };

  Future<void> _setup(KakaoMapController controller) async {
    mapController = controller;
    // Drawing 을 쓰려면 먼저 관리자를 만들어야 합니다.
    await controller.createDrawingManager(
      options: const DrawingOptions(
        drawingMode: _modes,
        guideTooltip: ['draw', 'drag', 'edit'],
        polylineStyle: DrawingStyle(strokeColor: Colors.blue, strokeWidth: 4),
        polygonStyle: DrawingStyle(
          strokeColor: Colors.green,
          strokeWidth: 3,
          fillColor: Colors.green,
          fillOpacity: 0.3,
        ),
      ),
    );
    await controller.selectDrawingMode(selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? selectedTitle)),
      body: Column(
        children: [
          Expanded(
            child: KakaoMap(
              onMapCreated: _setup,
              center: LatLng(33.450701, 126.570667),
              onDrawingEnd: (type) {
                setState(() =>
                    message = '${_labels[type] ?? type?.name ?? '도형'} 을(를) 그렸습니다.');
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 6,
                  children: _modes
                      .map((m) => ChoiceChip(
                            label: Text(_labels[m]!),
                            selected: selected == m,
                            onSelected: (_) async {
                              setState(() => selected = m);
                              await mapController?.selectDrawingMode(m);
                            },
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                Text(message, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
