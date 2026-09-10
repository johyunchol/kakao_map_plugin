import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// Drawing undo, redo
/// https://apis.map.kakao.com/web/sample/drawingUndo/
class Library16DrawingUndoRedoScreen extends StatefulWidget {
  const Library16DrawingUndoRedoScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Library16DrawingUndoRedoScreen> createState() =>
      _Library16DrawingUndoRedoScreenState();
}

class _Library16DrawingUndoRedoScreenState
    extends State<Library16DrawingUndoRedoScreen> {
  KakaoMapController? mapController;
  int drawnCount = 0;
  String message = '선을 그린 뒤 되돌리기와 다시실행을 눌러 보세요.';

  Future<void> _setup(KakaoMapController controller) async {
    mapController = controller;
    await controller.createDrawingManager(
      options: const DrawingOptions(
        drawingMode: [
          DrawingOverlayType.polyline,
          DrawingOverlayType.polygon,
          DrawingOverlayType.marker,
        ],
        polylineStyle: DrawingStyle(strokeColor: Colors.red, strokeWidth: 4),
      ),
    );
    await controller.selectDrawingMode(DrawingOverlayType.polyline);
  }

  Future<void> _refreshCount() async {
    final data = await mapController?.getDrawingData();
    if (!mounted || data == null) return;
    setState(() => drawnCount = data.shapes.length);
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
                setState(() => message = '도형을 그렸습니다.');
                _refreshCount();
              },
              onDrawingRemove: () {
                setState(() => message = '도형이 제거되었습니다.');
                _refreshCount();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$message  (현재 도형 $drawnCount개)',
                    style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        await mapController?.undoDrawing();
                        await _refreshCount();
                        if (mounted) setState(() => message = '되돌렸습니다.');
                      },
                      icon: const Icon(Icons.undo),
                      label: const Text('되돌리기'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await mapController?.redoDrawing();
                        await _refreshCount();
                        if (mounted) setState(() => message = '다시 실행했습니다.');
                      },
                      icon: const Icon(Icons.redo),
                      label: const Text('다시실행'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await mapController?.cancelDrawing();
                        if (mounted) setState(() => message = '그리기를 취소했습니다.');
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('취소'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
