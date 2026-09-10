import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// Flutter 위젯 오버레이 (플러그인 추가 기능)
///
/// `KakaoMapWidgetOverlay` 로 진짜 Flutter 위젯을 지도 좌표에 붙입니다. HTML 이 아니라
/// 앱 테마·폰트·제스처를 그대로 쓰는 카드/배지를 지도 위에 올리고, 지도를 움직이면
/// 함께 따라옵니다. 탭하면 바텀시트를 여는 "앱다운" 패턴을 보여 줍니다.
class Overlay30WidgetOverlayScreen extends StatefulWidget {
  const Overlay30WidgetOverlayScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Overlay30WidgetOverlayScreen> createState() =>
      _Overlay30WidgetOverlayScreenState();
}

class _Place {
  final String id;
  final String name;
  final String price;
  final LatLng position;
  final IconData icon;
  const _Place(this.id, this.name, this.price, this.position, this.icon);
}

class _Overlay30WidgetOverlayScreenState
    extends State<Overlay30WidgetOverlayScreen> {
  String? selectedId;

  static final _places = [
    _Place(
        'a', '카페 라떼하우스', '4,500원', LatLng(37.5665, 126.9780), Icons.local_cafe),
    _Place('b', '분식당', '6,000원', LatLng(37.5690, 126.9820), Icons.ramen_dining),
    _Place('c', '서점', '영업 중', LatLng(37.5640, 126.9745), Icons.menu_book),
  ];

  void _showSheet(_Place place) {
    setState(() => selectedId = place.id);
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(place.icon, size: 28),
              const SizedBox(width: 10),
              Text(place.name, style: Theme.of(context).textTheme.titleLarge),
            ]),
            const SizedBox(height: 8),
            Text(
                '${place.price} · ${place.position.latitude.toStringAsFixed(4)}, '
                '${place.position.longitude.toStringAsFixed(4)}'),
            const SizedBox(height: 16),
            const Text(
              '이 카드는 HTML 이 아닌 Flutter 위젯(KakaoMapWidgetOverlay)입니다. '
              '지도를 움직이면 좌표를 따라오고, 탭하면 이 바텀시트가 열립니다.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      if (mounted) setState(() => selectedId = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? selectedTitle)),
      body: KakaoMap(
        center: LatLng(37.5665, 126.9785),
        currentLevel: 4,
        widgetOverlays: [
          for (final place in _places)
            KakaoMapWidgetOverlay(
              id: place.id,
              position: place.position,
              anchor: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () => _showSheet(place),
                child: AnimatedScale(
                  scale: selectedId == place.id ? 1.12 : 1,
                  duration: const Duration(milliseconds: 150),
                  child: Material(
                    color: selectedId == place.id
                        ? scheme.primary
                        : scheme.surface,
                    elevation: 4,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(place.icon,
                              size: 18,
                              color: selectedId == place.id
                                  ? scheme.onPrimary
                                  : scheme.primary),
                          const SizedBox(width: 6),
                          Text(
                            '${place.name} · ${place.price}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: selectedId == place.id
                                  ? scheme.onPrimary
                                  : scheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
