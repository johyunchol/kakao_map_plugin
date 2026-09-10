import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 로드뷰 도로를 이용하여 로드뷰 생성하기
/// https://apis.map.kakao.com/web/sample/basicRoadview2/
class RoadView2DefaultScreen extends StatefulWidget {
  const RoadView2DefaultScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<RoadView2DefaultScreen> createState() => _RoadView2DefaultScreenState();
}

class _RoadView2DefaultScreenState extends State<RoadView2DefaultScreen> {
  KakaoMapRoadviewController? controller;
  String message = '지도에서 파란 선(로드뷰 도로)을 탭해 보세요.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? selectedTitle)),
      body: Column(
        children: [
          Expanded(
            child: KakaoMapRoadviewView(
              center: LatLng(33.450701, 126.570667),
              // 로드뷰가 있는 도로를 지도 위에 표시합니다.
              showRoadviewOverlay: true,
              useMapWalker: true,
              onCreated: (c) => controller = c,
              onPositionChange: (latLng) {
                setState(() => message =
                    '로드뷰 위치: ${latLng.latitude.toStringAsFixed(6)}, '
                    '${latLng.longitude.toStringAsFixed(6)}');
              },
              onRoadviewNotFound: (latLng) {
                setState(() => message = '이 위치에는 로드뷰가 없습니다.');
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(message, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
