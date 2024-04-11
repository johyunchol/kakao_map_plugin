import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// WTM 좌표를 WGS84 좌표로 변환하기
/// https://apis.map.kakao.com/web/sample/transCoord/
class Library7transCoordsScreen extends StatefulWidget {
  const Library7transCoordsScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Library7transCoordsScreen> createState() =>
      _Library7transCoordsScreenState();
}

class _Library7transCoordsScreenState extends State<Library7transCoordsScreen> {
  late KakaoMapController mapController;

  bool draggable = true;
  bool zoomable = true;

  String resultText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: Stack(
        children: [
          KakaoMap(
            onMapCreated: (controller) async {
              final request = TransCoordRequest(
                x: 160082.538257218,
                y: -4680.975749087054,
                inputCoord: Coords.wtm,
                outputCoord: Coords.wgs84,
              );
              final response = await controller.transCoord(request);
              final result = response.list.first;

              setState(() {
                resultText = 'latitude = ${result.y}, longitude = ${result.x}';
              });
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'WTM to WGS84',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Text(
                      'wtmX = 160082.538257218, wtmY = -4680.975749087054'),
                  Text(resultText),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
