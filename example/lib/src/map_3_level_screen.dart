import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 지도 레벨 바꾸기
/// https://apis.map.kakao.com/web/sample/changeLevel/
class Map3LevelScreen extends StatefulWidget {
  const Map3LevelScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Map3LevelScreen> createState() => _Map3LevelScreenState();
}

class _Map3LevelScreenState extends State<Map3LevelScreen> {
  late KakaoMapController mapController;

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
              setState(() {});
            }),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    MaterialButton(
                      onPressed: () {
                        currentLevel++;
                        if (currentLevel >= 14) currentLevel = 14;
                        mapController.setLevel(currentLevel);

                        setState(() {});
                      },
                      color: Colors.white,
                      child: const Text("지도레벨 -1"),
                    ),
                    const SizedBox(width: 8),
                    MaterialButton(
                      onPressed: () {
                        currentLevel--;
                        if (currentLevel <= 1) currentLevel = 1;
                        mapController.setLevel(currentLevel);

                        setState(() {});
                      },
                      color: Colors.white,
                      child: const Text("지도레벨 +1"),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('현재 지도레벨은 $currentLevel 입니다'),
              )
            ],
          )
        ],
      ),
    );
  }
}
