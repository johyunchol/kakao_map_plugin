import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 동동이를 이용하여 로드뷰와 지도 연동하기
/// https://apis.map.kakao.com/web/sample/moveRoadview/
class RoadView3MoveScreen extends StatefulWidget {
  const RoadView3MoveScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<RoadView3MoveScreen> createState() => _RoadView3MoveScreenState();
}

class _RoadView3MoveScreenState extends State<RoadView3MoveScreen> {
  KakaoMapRoadviewController? controller;
  LatLng? roadviewPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? selectedTitle)),
      body: Column(
        children: [
          Expanded(
            child: KakaoMapRoadviewView(
              center: LatLng(33.450701, 126.570667),
              // 지도와 로드뷰를 위아래로 나눠 보여줍니다.
              initialViewMode: RoadviewViewMode.split,
              splitRatio: 50,
              // 동동이가 로드뷰 위치와 바라보는 방향을 지도 위에 표시합니다.
              useMapWalker: true,
              showRoadviewOverlay: true,
              onCreated: (c) => controller = c,
              onPositionChange: (latLng) {
                setState(() => roadviewPosition = latLng);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              roadviewPosition == null
                  ? '지도를 탭하면 그 위치의 로드뷰로 이동합니다.'
                  : '동동이 위치: '
                      '${roadviewPosition!.latitude.toStringAsFixed(6)}, '
                      '${roadviewPosition!.longitude.toStringAsFixed(6)}',
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
