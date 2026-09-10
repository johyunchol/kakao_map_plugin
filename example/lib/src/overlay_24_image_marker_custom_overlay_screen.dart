import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 이미지 마커와 커스텀 오버레이
/// https://apis.map.kakao.com/web/sample/markerWithCustomOverlay/
class Overlay24ImageMarkerCustomOverlayScreen extends StatefulWidget {
  const Overlay24ImageMarkerCustomOverlayScreen({Key? key, this.title})
      : super(key: key);

  final String? title;

  @override
  State<Overlay24ImageMarkerCustomOverlayScreen> createState() =>
      _Overlay24ImageMarkerCustomOverlayScreenState();
}

/// 별 모양 이미지 마커로 표시할 가게 위치 정보입니다.
class _ShopSpot {
  _ShopSpot(this.id, this.name, this.latLng);

  final String id;
  final String name;
  final LatLng latLng;
}

class _Overlay24ImageMarkerCustomOverlayScreenState
    extends State<Overlay24ImageMarkerCustomOverlayScreen> {
  late KakaoMapController mapController;

  static const String _starMarkerImageSrc =
      'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/markerStar.png';

  static final List<_ShopSpot> _spots = [
    _ShopSpot('shop_1', '카카오 프렌즈샵', LatLng(37.514575, 127.060738)),
    _ShopSpot('shop_2', '스타벅스 강남점', LatLng(37.515224, 127.062633)),
    _ShopSpot('shop_3', '카페 청춘', LatLng(37.513850, 127.064102)),
  ];

  Set<Marker> markers = {};
  List<CustomOverlay> customOverlays = [];

  String? _tappedShopName;

  @override
  void initState() {
    super.initState();

    markers = _spots
        .map((spot) => Marker(
              markerId: spot.id,
              latLng: spot.latLng,
              width: 24,
              height: 35,
              offsetX: 12,
              offsetY: 35,
              markerImageSrc: _starMarkerImageSrc,
            ))
        .toSet();

    customOverlays = _spots
        .map((spot) => CustomOverlay(
              customOverlayId: 'label_${spot.id}',
              latLng: spot.latLng,
              content: _labelContent(spot.name),
              xAnchor: 0.5,
              // 마커 이미지(높이 35px) 위쪽에 라벨이 뜨도록 yAnchor 를 1보다
              // 크게 주어 컨텐츠 전체를 위로 밀어 올립니다.
              yAnchor: 1.8,
              zIndex: 5,
            ))
        .toList();
  }

  /// 라벨 HTML 을 생성합니다. 인라인 스타일로 배경, 테두리, 둥근 모서리를 지정합니다.
  String _labelContent(String name) {
    return '<div style="'
        'padding: 6px 10px;'
        'background-color: #333333;'
        'color: #ffffff;'
        'border: 1px solid #ffffff;'
        'border-radius: 6px;'
        'font-size: 12px;'
        'font-weight: bold;'
        'white-space: nowrap;'
        'box-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);'
        '">$name</div>';
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

              setState(() {});
            }),
            onCustomOverlayTap: (customOverlayId, latLng) {
              final spot = _spots.firstWhere(
                (s) => 'label_${s.id}' == customOverlayId,
                orElse: () => _ShopSpot('', '알 수 없음', LatLng(0, 0)),
              );

              setState(() {
                _tappedShopName = spot.name;
              });
            },
            markers: markers.toList(),
            customOverlays: customOverlays,
            currentLevel: 4,
            center: _spots.first.latLng,
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: KakaoMapPointerInterceptor(
                child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _tappedShopName == null
                    ? '라벨을 탭하면 가게 이름이 여기에 표시됩니다'
                    : '선택한 가게: $_tappedShopName',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            )),
          ),
        ],
      ),
    );
  }
}
