import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 커스텀 오버레이 생성하기2
/// https://apis.map.kakao.com/web/sample/customOverlay2/
class Overlay22CustomOverlay2Screen extends StatefulWidget {
  const Overlay22CustomOverlay2Screen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Overlay22CustomOverlay2Screen> createState() =>
      _Overlay22CustomOverlay2ScreenState();
}

class _Overlay22CustomOverlay2ScreenState
    extends State<Overlay22CustomOverlay2Screen> {
  late KakaoMapController mapController;

  List<CustomOverlay> customOverlays = [];

  @override
  void initState() {
    var content =
        '<div style="background-color: #333333; border-radius: 8px; padding: 8px;"><ul style="color: white; list-style: none;"><li>명량</li><li>해적(바다로간 산적)</li><li>해무</li></ul></div>';

    final customOverlay = CustomOverlay(
      customOverlayId: 'customOverlay',
      latLng: LatLng(37.49887, 127.026581),
      // content: '<p style="background-color: white; padding: 8px; border-radius: 8px;">카카오!</p>',
      content: content,
    );

    customOverlays.add(customOverlay);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: KakaoMap(
        onMapCreated: ((controller) async {
          mapController = controller;

          setState(() {});
        }),
        customOverlays: customOverlays,
        onCustomOverlayTap: (String id, LatLng latLng) {
          debugPrint('***** [callback2] $id / $latLng');
        },
        center: LatLng(37.502, 127.026581),
        currentLevel: 4,
      ),
    );
  }
}
