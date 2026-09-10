import 'package:flutter/material.dart';

import 'constants/map_type.dart';
import 'kakao_map_controller.dart';
import 'kakao_map_pointer_interceptor.dart';
import '../model/animate.dart';
import '../model/level_options.dart';

/// 지도 위에 올리는 Flutter 컨트롤(확대/축소, 지도 타입 전환)입니다.
///
/// 카카오 SDK 의 `zoomControl` / `mapTypeControl` 은 웹페이지 스타일의 스프라이트
/// 버튼이라 앱과 어울리지 않습니다. 이 위젯은 같은 기능을 Material 위젯으로
/// 제공하며 `Stack` 으로 지도 위에 올려 씁니다. web 에서 iframe 위에서도 눌리도록
/// 내부에서 [KakaoMapPointerInterceptor] 로 감쌉니다.
///
/// 예시:
/// ```dart
/// Stack(
///   children: [
///     KakaoMap(onMapCreated: (c) => setState(() => controller = c)),
///     if (controller != null)
///       KakaoMapControls(
///         controller: controller!,
///         alignment: Alignment.centerRight,
///         showMapType: true,
///       ),
///   ],
/// )
/// ```
class KakaoMapControls extends StatefulWidget {
  /// 제어할 지도 컨트롤러입니다.
  final KakaoMapController controller;

  /// 확대/축소 버튼을 표시할지 여부입니다.
  final bool showZoom;

  /// 지도 타입 전환 버튼을 표시할지 여부입니다.
  final bool showMapType;

  /// 지도 타입 버튼을 누를 때 순환할 타입 목록입니다.
  final List<MapType> mapTypes;

  /// 확대/축소 시 애니메이션 시간입니다. null 이면 즉시 바뀝니다.
  final Duration? zoomAnimation;

  /// 지도 안에서의 위치입니다.
  final AlignmentGeometry alignment;

  /// 지도 가장자리와의 간격입니다.
  final EdgeInsetsGeometry padding;

  /// 버튼 배경색입니다. null 이면 테마의 surface 색을 씁니다.
  final Color? backgroundColor;

  /// 버튼 아이콘 색입니다. null 이면 테마의 onSurface 색을 씁니다.
  final Color? foregroundColor;

  /// 버튼 한 변의 크기입니다.
  final double buttonSize;

  /// 지도 컨트롤을 만듭니다.
  const KakaoMapControls({
    super.key,
    required this.controller,
    this.showZoom = true,
    this.showMapType = false,
    this.mapTypes = const [MapType.normal, MapType.skyView, MapType.hybrid],
    this.zoomAnimation = const Duration(milliseconds: 200),
    this.alignment = Alignment.centerRight,
    this.padding = const EdgeInsets.all(12),
    this.backgroundColor,
    this.foregroundColor,
    this.buttonSize = 40,
  });

  @override
  State<KakaoMapControls> createState() => _KakaoMapControlsState();
}

class _KakaoMapControlsState extends State<KakaoMapControls> {
  bool _busy = false;

  Future<void> _zoom(int delta) async {
    if (_busy) return;
    _busy = true;
    try {
      final level = await widget.controller.getLevel();
      final options = widget.zoomAnimation == null
          ? null
          : LevelOptions(
              animate: Animate(duration: widget.zoomAnimation!.inMilliseconds));
      await widget.controller.setLevel(level + delta, options: options);
    } catch (_) {
      // 지도가 아직 준비되지 않았거나 정리된 경우는 무시합니다.
    } finally {
      _busy = false;
    }
  }

  Future<void> _cycleMapType() async {
    if (_busy || widget.mapTypes.isEmpty) return;
    _busy = true;
    try {
      final current = await widget.controller.getMapTypeId();
      final index = widget.mapTypes.indexOf(current);
      final next = widget.mapTypes[(index + 1) % widget.mapTypes.length];
      await widget.controller.setMapTypeId(next);
    } catch (_) {
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = widget.backgroundColor ?? scheme.surface;
    final fg = widget.foregroundColor ?? scheme.onSurface;

    Widget button(IconData icon, String tooltip, VoidCallback onTap) {
      return Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: widget.buttonSize,
            height: widget.buttonSize,
            child: Icon(icon, size: widget.buttonSize * 0.55, color: fg),
          ),
        ),
      );
    }

    Widget group(List<Widget> children) {
      return Material(
        color: bg,
        elevation: 3,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(widget.buttonSize / 4),
        clipBehavior: Clip.antiAlias,
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      );
    }

    final groups = <Widget>[
      if (widget.showZoom)
        group([
          // 카카오 지도는 레벨이 작을수록 확대이므로 +는 level - 1 입니다.
          button(Icons.add, '확대', () => _zoom(-1)),
          Divider(height: 1, thickness: 1, color: fg.withValues(alpha: 0.12)),
          button(Icons.remove, '축소', () => _zoom(1)),
        ]),
      if (widget.showMapType)
        group([button(Icons.layers_outlined, '지도 타입', _cycleMapType)]),
    ];
    if (groups.isEmpty) return const SizedBox.shrink();

    return Align(
      alignment: widget.alignment,
      child: Padding(
        padding: widget.padding,
        child: KakaoMapPointerInterceptor(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < groups.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                groups[i],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
