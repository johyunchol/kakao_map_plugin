import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 로드뷰에 마커와 인포윈도우 올리기
/// https://apis.map.kakao.com/web/sample/roadviewOverlay1/
class RoadView4Overlay1Screen extends StatefulWidget {
  const RoadView4Overlay1Screen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<RoadView4Overlay1Screen> createState() =>
      _RoadView4Overlay1ScreenState();
}

class _RoadView4Overlay1ScreenState extends State<RoadView4Overlay1Screen> {
  KakaoRoadviewController? roadviewController;

  final LatLng position = LatLng(33.450701, 126.570667);

  String? tappedMarkerId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: Stack(
        children: [
          KakaoRoadMap(
            center: position,
            markers: [
              Marker(
                markerId: 'marker1',
                latLng: position,
                infoWindowContent:
                    '<div style="padding:5px;font-size:12px;">여기가 중심입니다</div>',
                // 로드뷰 전용: 지면으로부터의 높이와 보이는 최대 거리
                altitude: 3,
                range: 100,
              ),
            ],
            onRoadviewCreated: (controller) {
              roadviewController = controller;
            },
            onMarkerTap: (markerId, latLng) {
              setState(() => tappedMarkerId = markerId);
            },
          ),
          if (tappedMarkerId != null)
            Positioned(
              left: 12,
              bottom: 12,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('탭한 마커: $tappedMarkerId'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
