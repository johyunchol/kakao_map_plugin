import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// geolocation으로 마커 표시하기
/// https://apis.map.kakao.com/web/sample/geolocationMarker
///
/// 카카오 지도 SDK 는 위치 조회 기능을 제공하지 않습니다. 공식 웹 샘플은
/// 브라우저의 `navigator.geolocation` 을 쓰지만, Flutter 앱에서는 위치 권한과
/// 조회를 앱이 직접 처리한 뒤 좌표만 지도에 넘기는 방식이 맞습니다.
///
/// 이 예제는 위치 플러그인 의존성을 추가하지 않기 위해 조회 결과를 흉내 내고,
/// 실제 앱에서 어떻게 연결하면 되는지를 코드 주석으로 안내합니다.
class Overlay9MarkerGeolocatorScreen extends StatefulWidget {
  const Overlay9MarkerGeolocatorScreen({Key? key, this.title})
      : super(key: key);

  final String? title;

  @override
  State<Overlay9MarkerGeolocatorScreen> createState() =>
      _Overlay9MarkerGeolocatorScreenState();
}

class _Overlay9MarkerGeolocatorScreenState
    extends State<Overlay9MarkerGeolocatorScreen> {
  late KakaoMapController mapController;

  /// 위치를 조회했다고 가정할 좌표들입니다.
  /// 실제 앱에서는 geolocator 등으로 얻은 값을 넣으면 됩니다.
  static final List<LatLng> _samplePositions = [
    LatLng(37.5665, 126.9780),
    LatLng(35.1796, 129.0756),
    LatLng(33.4996, 126.5312),
  ];
  static const List<String> _sampleNames = ['서울시청', '부산역', '제주시청'];

  int _index = 0;
  LatLng? current;
  List<Marker> markers = [];
  List<CustomOverlay> customOverlays = [];

  /// 실제 앱에서는 이 자리에서 위치 플러그인을 호출합니다.
  ///
  /// ```dart
  /// // pubspec.yaml 에 geolocator 추가 후
  /// final permission = await Geolocator.requestPermission();
  /// final pos = await Geolocator.getCurrentPosition();
  /// final latLng = LatLng(pos.latitude, pos.longitude);
  /// ```
  Future<LatLng> _readCurrentPosition() async {
    // 조회 지연을 흉내 냅니다.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final position = _samplePositions[_index % _samplePositions.length];
    return position;
  }

  Future<void> _locate() async {
    final latLng = await _readCurrentPosition();
    final name = _sampleNames[_index % _sampleNames.length];
    _index++;

    setState(() {
      current = latLng;
      markers = [
        Marker(markerId: 'current', latLng: latLng, width: 30, height: 44),
      ];
      customOverlays = [
        CustomOverlay(
          customOverlayId: 'label',
          latLng: latLng,
          content: '<div style="padding:6px 10px;background:#fff;'
              'border:2px solid #0f4c81;border-radius:6px;font-size:12px;'
              'white-space:nowrap;">여기 계신가요? ($name)</div>',
          xAnchor: 0.5,
          yAnchor: 2.2,
        ),
      ];
    });

    await mapController.setCenter(latLng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? selectedTitle)),
      body: Stack(
        children: [
          KakaoMap(
            onMapCreated: (controller) => mapController = controller,
            center: LatLng(37.5665, 126.9780),
            markers: markers,
            customOverlays: customOverlays,
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: KakaoMapPointerInterceptor(
                child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  current == null
                      ? '아래 버튼을 누르면 현재 위치를 조회해 마커를 표시합니다.\n'
                          '실제 앱에서는 geolocator 등으로 좌표를 얻어 넘기세요.'
                      : '현재 위치: ${current!.latitude.toStringAsFixed(6)}, '
                          '${current!.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            )),
          ),
        ],
      ),
      floatingActionButton: KakaoMapPointerInterceptor(
          child: FloatingActionButton.extended(
        onPressed: _locate,
        label: const Text('현재 위치'),
        icon: const Icon(Icons.my_location),
      )),
    );
  }
}
