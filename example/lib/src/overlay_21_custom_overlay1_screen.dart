import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 커스텀 오버레이 생성하기1
/// https://apis.map.kakao.com/web/sample/customOverlay1/
class Overlay21CustomOverlay1Screen extends StatefulWidget {
  const Overlay21CustomOverlay1Screen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Overlay21CustomOverlay1Screen> createState() =>
      _Overlay21CustomOverlay1ScreenState();
}

class _Overlay21CustomOverlay1ScreenState
    extends State<Overlay21CustomOverlay1Screen> {
  late KakaoMapController mapController;

  List<CustomOverlay> customOverlays = [];

  @override
  void initState() {
    final customOverlay = CustomOverlay(
      customOverlayId: UniqueKey().toString(),
      latLng: LatLng(33.450701, 126.570667),
      content:
          '<p style="background-color: white; padding: 8px; border-radius: 8px;">카카오!</p>',
      xAnchor: 1,
      yAnchor: -1,
      zIndex: 5,
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
          debugPrint('***** [callback] $id / $latLng');
        },
        center: LatLng(33.450701, 126.570667),
      ),
    );
  }
}
