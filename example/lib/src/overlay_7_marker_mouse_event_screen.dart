import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 마커에 마우스 이벤트 등록하기
/// https://apis.map.kakao.com/web/sample/addMarkerMouseEvent/
class Overlay7MarkerMouseEventScreen extends StatefulWidget {
  const Overlay7MarkerMouseEventScreen({Key? key, this.title})
      : super(key: key);

  final String? title;

  @override
  State<Overlay7MarkerMouseEventScreen> createState() =>
      _Overlay7MarkerMouseEventScreenState();
}

class _Overlay7MarkerMouseEventScreenState
    extends State<Overlay7MarkerMouseEventScreen> {
  late KakaoMapController mapController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: const [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('안드로이드, ios에는\nmouseover, mouseout 이벤트는 동작하지 않습니다.'),
            ),
          ],
        ),
      ),
    );
  }
}
