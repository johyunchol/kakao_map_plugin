import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 로드뷰에 이미지 올리기
/// https://apis.map.kakao.com/web/sample/roadviewImageOverlay/
class RoadView7ImageScreen extends StatefulWidget {
  const RoadView7ImageScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<RoadView7ImageScreen> createState() => _RoadView7ImageScreenState();
}

class _RoadView7ImageScreenState extends State<RoadView7ImageScreen> {
  KakaoRoadviewController? roadviewController;

  /// 이미지를 올릴 위치입니다.
  final LatLng position = LatLng(33.450701, 126.570667);

  /// 지면으로부터의 높이(m). 슬라이더로 조절합니다.
  double altitude = 3;

  String? tappedOverlayId;

  List<CustomOverlay> _overlays() => [
        CustomOverlay(
          customOverlayId: 'image1',
          latLng: position,
          // 로드뷰 위에 표시할 임의의 HTML 입니다.
          content: '<div style="padding:6px 10px;background:#fff;'
              'border:2px solid #0f4c81;border-radius:8px;'
              'font-size:13px;white-space:nowrap;">'
              '카카오 본사 방향</div>',
          xAnchor: 0.5,
          yAnchor: 1.0,
          altitude: altitude,
        ),
      ];

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
              customOverlays: _overlays(),
              onRoadviewCreated: (controller) {
                roadviewController = controller;
              },
              onCustomOverlayTap: (overlayId, latLng) {
                setState(() => tappedOverlayId = overlayId);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('높이(altitude): ${altitude.toStringAsFixed(1)} m'),
                Slider(
                  value: altitude,
                  min: -5,
                  max: 20,
                  divisions: 25,
                  label: altitude.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() => altitude = value);
                  },
                  onChangeEnd: (value) async {
                    // 높이를 바꾼 오버레이를 다시 올립니다.
                    await roadviewController?.addCustomOverlay(
                        customOverlays: _overlays());
                  },
                ),
                if (tappedOverlayId != null)
                  Text('탭한 오버레이: $tappedOverlayId'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
