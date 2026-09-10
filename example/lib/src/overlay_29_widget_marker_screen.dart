import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 위젯으로 마커 만들기 (플러그인 추가 기능)
///
/// `MarkerIcon.pin(color:)` 으로 색만 다른 기본 핀을, `MarkerIcon.fromWidget()` 으로
/// Flutter 위젯(가격표, 배지 등)을 그대로 그린 마커를 만듭니다. 이미지 파일이나
/// HTML 없이 앱 디자인 시스템에 맞는 마커를 만들 수 있습니다.
class Overlay29WidgetMarkerScreen extends StatefulWidget {
  const Overlay29WidgetMarkerScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Overlay29WidgetMarkerScreen> createState() =>
      _Overlay29WidgetMarkerScreenState();
}

class _Overlay29WidgetMarkerScreenState
    extends State<Overlay29WidgetMarkerScreen> {
  final List<Marker> markers = [];
  bool building = true;

  @override
  void initState() {
    super.initState();
    _buildMarkers();
  }

  Future<void> _buildMarkers() async {
    // 1) 색만 바꾼 기본 핀 — 동기적으로 바로 만들어집니다.
    final pinPositions = [
      LatLng(37.5665, 126.9780),
      LatLng(37.5680, 126.9820),
      LatLng(37.5640, 126.9750),
    ];
    final pinColors = [Colors.red, Colors.green, Colors.indigo];
    for (var i = 0; i < pinPositions.length; i++) {
      markers.add(Marker(
        markerId: 'pin_$i',
        latLng: pinPositions[i],
        icon: MarkerIcon.pin(color: pinColors[i], size: 40),
        width: 28,
        height: 40,
        offsetX: 14,
        offsetY: 40,
      ));
    }

    // 2) Flutter 위젯을 그린 마커 — 렌더링이 필요하므로 비동기입니다.
    final pricePositions = [
      LatLng(37.5700, 126.9790),
      LatLng(37.5650, 126.9840),
    ];
    final priceTexts = ['12,000원', '8,500원'];
    final priceColors = [Colors.deepOrange, Colors.teal];
    for (var i = 0; i < pricePositions.length; i++) {
      final icon = await MarkerIcon.fromWidget(
        _PriceTag(text: priceTexts[i], color: priceColors[i]),
        logicalSize: const Size(96, 44),
      );
      markers.add(Marker(
        markerId: 'price_$i',
        latLng: pricePositions[i],
        icon: icon,
        width: 96,
        height: 44,
        offsetX: 48,
        offsetY: 44,
      ));
    }

    if (!mounted) return;
    setState(() => building = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? selectedTitle)),
      body: Column(
        children: [
          Expanded(
            child: KakaoMap(
              center: LatLng(37.5667, 126.9795),
              currentLevel: 4,
              markers: building ? null : markers,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              '핀 3개는 MarkerIcon.pin(color:), 가격표 2개는 MarkerIcon.fromWidget() 으로 '
              '만든 마커입니다.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

/// 마커로 쓸 가격표 위젯입니다. 아래 꼬리까지 포함해 96x44 로 그립니다.
class _PriceTag extends StatelessWidget {
  final String text;
  final Color color;

  const _PriceTag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        CustomPaint(
          size: const Size(12, 8),
          painter: _TrianglePainter(color),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter old) => old.color != color;
}
