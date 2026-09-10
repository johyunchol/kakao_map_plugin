import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// Flutter 컨트롤 올리기 (플러그인 추가 기능)
///
/// SDK 의 웹 스타일 줌/지도타입 컨트롤 대신 `KakaoMapControls` 를 지도 위에 올리고,
/// `KakaoMapTheme` 으로 타일 로딩 전 배경색을 앱 배경에 맞추며, 저작권 표시를
/// 왼쪽 아래로 옮겨 오른쪽 아래 버튼과 겹치지 않게 합니다.
class Map26FlutterControlsScreen extends StatefulWidget {
  const Map26FlutterControlsScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Map26FlutterControlsScreen> createState() =>
      _Map26FlutterControlsScreenState();
}

class _Map26FlutterControlsScreenState
    extends State<Map26FlutterControlsScreen> {
  KakaoMapController? mapController;
  MapType mapType = MapType.normal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? selectedTitle)),
      body: Stack(
        children: [
          KakaoMap(
            center: LatLng(37.566826, 126.9786567),
            currentLevel: 5,
            theme: const KakaoMapTheme(
              backgroundColor: Color(0xFFEFF3F6),
              infoWindowStyle: InfoWindowStyle.material(),
            ),
            copyrightPosition: CopyrightPosition.bottomLeft,
            onMapCreated: (controller) =>
                setState(() => mapController = controller),
            onMapTypeChanged: (type) => setState(() => mapType = type),
          ),
          if (mapController != null)
            KakaoMapControls(
              controller: mapController!,
              showMapType: true,
              alignment: Alignment.topRight,
              padding: const EdgeInsets.all(12),
            ),
          Positioned(
            right: 12,
            bottom: 12,
            child: KakaoMapPointerInterceptor(
              child: Card(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text('지도 타입: ${mapType.name}'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
