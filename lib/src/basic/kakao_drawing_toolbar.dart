import 'package:flutter/material.dart';

import 'constants/drawing_overlay_type.dart';
import 'kakao_map_controller.dart';
import 'kakao_map_pointer_interceptor.dart';

/// Drawing Library 용 Flutter 도구 모음입니다.
///
/// 카카오 SDK 의 `Toolbox`(스프라이트 아이콘 바) 대신 Material 칩으로 도형 종류를
/// 고르고 되돌리기/다시실행/취소를 제공합니다. `createDrawingManager()` 를 먼저
/// 호출한 뒤 지도 위나 아래에 배치하세요. 지도 위에 올릴 때를 대비해 내부에서
/// [KakaoMapPointerInterceptor] 로 감쌉니다.
///
/// 예시:
/// ```dart
/// KakaoDrawingToolbar(
///   controller: mapController,
///   modes: const [DrawingOverlayType.marker, DrawingOverlayType.polyline, DrawingOverlayType.polygon],
///   onModeChanged: (type) => debugPrint('선택: $type'),
/// )
/// ```
class KakaoDrawingToolbar extends StatefulWidget {
  /// 제어할 지도 컨트롤러입니다. `createDrawingManager()` 가 호출된 상태여야 합니다.
  final KakaoMapController controller;

  /// 표시할 도형 종류입니다.
  final List<DrawingOverlayType> modes;

  /// 처음 선택된 도형 종류입니다. null 이면 아무것도 선택하지 않습니다.
  final DrawingOverlayType? initialMode;

  /// 되돌리기/다시실행 버튼을 표시할지 여부입니다.
  final bool showUndoRedo;

  /// 그리기 취소 버튼을 표시할지 여부입니다.
  final bool showCancel;

  /// 도형 종류가 바뀌었을 때 호출됩니다.
  final ValueChanged<DrawingOverlayType>? onModeChanged;

  /// 각 도형 종류의 표시 이름입니다. 지정하지 않은 종류는 기본 한글 이름을 씁니다.
  final Map<DrawingOverlayType, String> labels;

  /// 바깥 여백입니다.
  final EdgeInsetsGeometry padding;

  /// Drawing 도구 모음을 만듭니다.
  const KakaoDrawingToolbar({
    super.key,
    required this.controller,
    this.modes = DrawingOverlayType.values,
    this.initialMode,
    this.showUndoRedo = true,
    this.showCancel = false,
    this.onModeChanged,
    this.labels = const {},
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
  });

  /// 기본 표시 이름입니다.
  static const Map<DrawingOverlayType, String> defaultLabels = {
    DrawingOverlayType.marker: '마커',
    DrawingOverlayType.polyline: '선',
    DrawingOverlayType.rectangle: '사각형',
    DrawingOverlayType.circle: '원',
    DrawingOverlayType.ellipse: '타원',
    DrawingOverlayType.polygon: '다각형',
    DrawingOverlayType.arrow: '화살표',
  };

  @override
  State<KakaoDrawingToolbar> createState() => _KakaoDrawingToolbarState();
}

class _KakaoDrawingToolbarState extends State<KakaoDrawingToolbar> {
  DrawingOverlayType? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialMode;
  }

  Future<void> _select(DrawingOverlayType type) async {
    setState(() => _selected = type);
    await widget.controller.selectDrawingMode(type);
    widget.onModeChanged?.call(type);
  }

  @override
  Widget build(BuildContext context) {
    return KakaoMapPointerInterceptor(
      child: Padding(
        padding: widget.padding,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final type in widget.modes) ...[
                ChoiceChip(
                  label: Text(widget.labels[type] ??
                      KakaoDrawingToolbar.defaultLabels[type] ??
                      type.value),
                  selected: _selected == type,
                  onSelected: (_) => _select(type),
                ),
                const SizedBox(width: 6),
              ],
              if (widget.showUndoRedo) ...[
                const SizedBox(width: 6),
                IconButton(
                  tooltip: '되돌리기',
                  icon: const Icon(Icons.undo),
                  onPressed: widget.controller.undoDrawing,
                ),
                IconButton(
                  tooltip: '다시 실행',
                  icon: const Icon(Icons.redo),
                  onPressed: widget.controller.redoDrawing,
                ),
              ],
              if (widget.showCancel)
                IconButton(
                  tooltip: '그리기 취소',
                  icon: const Icon(Icons.close),
                  onPressed: widget.controller.cancelDrawing,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
