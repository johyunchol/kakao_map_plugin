import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 마커의 고도와 반경 조절하기
/// https://apis.map.kakao.com/web/sample/roadviewOverlay2/
class RoadView5Overlay2Screen extends StatefulWidget {
  const RoadView5Overlay2Screen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<RoadView5Overlay2Screen> createState() =>
      _RoadView5Overlay2ScreenState();
}

class _RoadView5Overlay2ScreenState extends State<RoadView5Overlay2Screen> {
  KakaoRoadviewController? roadviewController;

  final LatLng position = LatLng(33.450701, 126.570667);

  /// 지면으로부터의 높이(m)
  double altitude = 3;

  /// 마커가 보이는 최대 거리(m). 이보다 멀어지면 마커가 사라집니다.
  double range = 100;

  List<Marker> _markers() => [
        Marker(
          markerId: 'marker1',
          latLng: position,
          infoWindowContent: '<div style="padding:5px;font-size:12px;">'
              '고도 ${altitude.toStringAsFixed(0)}m / '
              '반경 ${range.toStringAsFixed(0)}m</div>',
          altitude: altitude,
          range: range,
        ),
      ];

  Future<void> _apply() async {
    await roadviewController?.addMarker(markers: _markers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: KakaoRoadMap(
              center: position,
              markers: _markers(),
              onRoadviewCreated: (controller) {
                roadviewController = controller;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('고도(altitude): ${altitude.toStringAsFixed(0)} m'),
                Slider(
                  value: altitude,
                  min: -10,
                  max: 30,
                  divisions: 40,
                  label: altitude.toStringAsFixed(0),
                  onChanged: (v) => setState(() => altitude = v),
                  onChangeEnd: (_) => _apply(),
                ),
                Text('반경(range): ${range.toStringAsFixed(0)} m'),
                Slider(
                  value: range,
                  min: 10,
                  max: 500,
                  divisions: 49,
                  label: range.toStringAsFixed(0),
                  onChanged: (v) => setState(() => range = v),
                  onChangeEnd: (_) => _apply(),
                ),
                const Text(
                  '반경을 줄이면 멀리서는 마커가 보이지 않습니다.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
