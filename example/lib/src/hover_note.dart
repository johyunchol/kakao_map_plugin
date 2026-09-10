import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

/// hover(마우스 오버) 기능을 쓰는 예제 화면 상단에 붙이는 안내 배너입니다.
///
/// 지도 컨트롤러로 `supportsHover()` 를 물어봐 마우스 포인터가 없는 환경(터치 기기)이면
/// "탭으로 대체된다"는 안내를, 있으면 마우스를 올려 보라는 안내를 보여 줍니다.
class HoverNote extends StatefulWidget {
  /// 지도가 준비된 뒤 전달되는 컨트롤러입니다. null 이면 확인 중으로 표시합니다.
  final KakaoMapController? controller;

  /// 마우스 환경에서 보여 줄 문구입니다.
  final String hoverText;

  /// 터치 환경에서 보여 줄 문구입니다.
  final String touchText;

  const HoverNote({
    super.key,
    required this.controller,
    required this.hoverText,
    required this.touchText,
  });

  @override
  State<HoverNote> createState() => _HoverNoteState();
}

class _HoverNoteState extends State<HoverNote> {
  bool? supportsHover;

  @override
  void didUpdateWidget(covariant HoverNote oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null && oldWidget.controller == null) _check();
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) _check();
  }

  Future<void> _check() async {
    try {
      final value = await widget.controller!.supportsHover();
      if (mounted) setState(() => supportsHover = value);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final hover = supportsHover;
    final color = hover == true ? Colors.green : Colors.orange;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: color.withValues(alpha: 0.12),
      child: Row(
        children: [
          Icon(hover == true ? Icons.mouse : Icons.touch_app,
              size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hover == null
                  ? '입력 환경 확인 중…'
                  : hover
                      ? widget.hoverText
                      : '${widget.touchText}  (마우스 hover 이벤트는 포인터가 있는 환경 전용)',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
