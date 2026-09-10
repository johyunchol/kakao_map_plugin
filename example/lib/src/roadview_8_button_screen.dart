import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 버튼으로 로드뷰 보기
/// https://apis.map.kakao.com/web/sample/roadviewWithMapButton/
class RoadView8ButtonScreen extends StatefulWidget {
  const RoadView8ButtonScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<RoadView8ButtonScreen> createState() => _RoadView8ButtonScreenState();
}

class _RoadView8ButtonScreenState extends State<RoadView8ButtonScreen> {
  KakaoMapRoadviewController? controller;
  RoadviewViewMode mode = RoadviewViewMode.map;

  Future<void> _setMode(RoadviewViewMode next) async {
    await controller?.setViewMode(next);
    setState(() => mode = next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? selectedTitle)),
      body: Column(
        children: [
          Expanded(
            child: KakaoMapRoadviewView(
              center: LatLng(33.450701, 126.570667),
              initialViewMode: RoadviewViewMode.map,
              showRoadviewOverlay: true,
              onCreated: (c) => controller = c,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: SegmentedButton<RoadviewViewMode>(
              segments: const [
                ButtonSegment(value: RoadviewViewMode.map, label: Text('지도')),
                ButtonSegment(value: RoadviewViewMode.split, label: Text('분할')),
                ButtonSegment(
                    value: RoadviewViewMode.roadview, label: Text('로드뷰')),
              ],
              selected: {mode},
              onSelectionChanged: (selected) => _setMode(selected.first),
            ),
          ),
        ],
      ),
    );
  }
}
