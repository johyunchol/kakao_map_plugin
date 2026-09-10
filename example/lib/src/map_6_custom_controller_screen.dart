import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 지도에 사용자 컨트롤 올리기
/// https://apis.map.kakao.com/web/sample/addMapCustomControl/
class Map6CustomControllerScreen extends StatefulWidget {
  const Map6CustomControllerScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Map6CustomControllerScreen> createState() =>
      _Map6CustomControllerScreenState();
}

class _Map6CustomControllerScreenState
    extends State<Map6CustomControllerScreen> {
  late KakaoMapController mapController;

  bool isDefaultMap = true;
  int currentLevel = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: Stack(
        children: [
          KakaoMap(
            onMapCreated: ((controller) async {
              mapController = controller;

              currentLevel = await mapController.getLevel();
              // 지도 생성이 늦어 화면이 먼저 닫힌 경우를 대비합니다.
              if (!mounted) return;
              setState(() {});
            }),
          ),
          Align(
            alignment: Alignment.topRight,
            child: KakaoMapPointerInterceptor(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MaterialButton(
                      onPressed: () {
                        setState(() {
                          isDefaultMap = true;
                        });

                        mapController.setMapTypeId(MapType.normal);
                      },
                      color: isDefaultMap ? Colors.blue : Colors.grey,
                      child: const Text('지도'),
                    ),
                    MaterialButton(
                      onPressed: () {
                        setState(() {
                          isDefaultMap = false;
                        });

                        mapController.setMapTypeId(MapType.skyView);
                      },
                      color: isDefaultMap ? Colors.grey : Colors.blue,
                      child: const Text('스카이뷰'),
                    ),
                  ],
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        currentLevel--;
                        if (currentLevel <= 1) currentLevel = 1;
                        mapController.setLevel(currentLevel);

                        setState(() {});
                      },
                      child: const Text('+'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        currentLevel++;
                        if (currentLevel >= 14) currentLevel = 14;
                        mapController.setLevel(currentLevel);

                        setState(() {});
                      },
                      child: const Text('-'),
                    ),
                  ],
                )
              ],
            )),
          ),
        ],
      ),
    );
  }
}
