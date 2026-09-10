import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 로드뷰 생성하기
/// https://apis.map.kakao.com/web/sample/basicRoadview/
class RoadView1DefaultScreen extends StatefulWidget {
  const RoadView1DefaultScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<RoadView1DefaultScreen> createState() => _RoadView1DefaultScreenState();
}

class _RoadView1DefaultScreenState extends State<RoadView1DefaultScreen> {
  KakaoRoadviewController? roadviewController;

  /// 로드뷰가 없는 지역일 때 안내를 띄우기 위한 상태입니다.
  bool notFound = false;

  /// 현재 시점. 화면을 돌리면 갱신됩니다.
  Viewpoint viewpoint = const Viewpoint();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: Stack(
        children: [
          KakaoRoadMap(
            center: LatLng(33.450701, 126.570667),
            onRoadviewCreated: (controller) {
              roadviewController = controller;
            },
            onViewpointChange: (v) {
              setState(() => viewpoint = v);
            },
            onRoadviewNotFound: (latLng) {
              setState(() => notFound = true);
            },
          ),
          if (notFound)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('이 위치에는 로드뷰가 없습니다.'),
                ),
              ),
            ),
          Positioned(
            left: 12,
            bottom: 12,
            child: Card(
              color: Colors.black54,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                child: Text(
                  'pan ${viewpoint.pan.toStringAsFixed(1)}°  '
                  'tilt ${viewpoint.tilt.toStringAsFixed(1)}°  '
                  'zoom ${viewpoint.zoom.toStringAsFixed(1)}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'north',
            onPressed: () async {
              await roadviewController?.setViewpoint(const Viewpoint());
            },
            label: const Text('북쪽 보기'),
            icon: const Icon(Icons.navigation),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.extended(
            heroTag: 'east',
            onPressed: () async {
              await roadviewController?.setViewpoint(
                  viewpoint.copyWith(pan: (viewpoint.pan + 90) % 360));
            },
            label: const Text('90° 회전'),
            icon: const Icon(Icons.rotate_right),
          ),
        ],
      ),
    );
  }
}
