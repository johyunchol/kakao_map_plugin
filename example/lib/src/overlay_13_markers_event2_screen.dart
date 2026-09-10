import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 여러개 마커에 이벤트 등록하기2
/// https://apis.map.kakao.com/web/sample/multipleMarkerEvent2/
class Overlay13MarkersEvent2Screen extends StatefulWidget {
  const Overlay13MarkersEvent2Screen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Overlay13MarkersEvent2Screen> createState() =>
      _Overlay13MarkersEvent2ScreenState();
}

class _Overlay13MarkersEvent2ScreenState
    extends State<Overlay13MarkersEvent2Screen> {
  late KakaoMapController mapController;

  static const String _defaultImageSrc =
      'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/markerStar.png';
  static const String _selectedImageSrc =
      'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/red_b.png';

  static final List<LatLng> _positions = [
    LatLng(37.3608681, 126.9306506),
    LatLng(37.3628681, 126.9326506),
    LatLng(37.3588681, 126.9326506),
    LatLng(37.3628681, 126.9286506),
    LatLng(37.3588681, 126.9286506),
  ];

  List<Marker> markers = [];

  String? selectedMarkerId;

  @override
  void initState() {
    super.initState();
  }

  void _handleMarkerTap(String markerId, LatLng latLng, int zoomLevel) {
    setState(() {
      selectedMarkerId = markerId;
      markers = [
        for (final marker in markers)
          Marker(
            markerId: marker.markerId,
            latLng: marker.latLng,
            width: marker.width,
            height: marker.height,
            offsetX: marker.offsetX,
            offsetY: marker.offsetY,
            markerImageSrc: marker.markerId == markerId
                ? _selectedImageSrc
                : _defaultImageSrc,
          ),
      ];
    });
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

              markers = [
                for (var i = 0; i < _positions.length; i++)
                  Marker(
                    markerId: 'marker_$i',
                    latLng: _positions[i],
                    width: 32,
                    height: 32,
                    offsetX: 16,
                    offsetY: 32,
                    markerImageSrc: _defaultImageSrc,
                  ),
              ];

              setState(() {});
            }),
            onMarkerTap: _handleMarkerTap,
            markers: markers,
            center: LatLng(37.3608681, 126.9306506),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  selectedMarkerId == null
                      ? '마커를 탭해 보세요'
                      : '선택된 마커: $selectedMarkerId',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
