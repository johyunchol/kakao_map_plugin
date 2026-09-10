import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 커스텀 타일셋2 — 타일 Element 함수(getTile)로 만든 타일을 지도 위에 겹칩니다.
/// https://apis.map.kakao.com/web/sample/getTile/
class Map25GetTileScreen extends StatefulWidget {
  const Map25GetTileScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Map25GetTileScreen> createState() => _Map25GetTileScreenState();
}

class _Map25GetTileScreenState extends State<Map25GetTileScreen> {
  KakaoMapController? mapController;
  bool overlayOn = false;

  /// 타일 좌표를 글자로 보여주는 div 를 돌려주는 함수입니다.
  static const String _tileNumberFunction = r'''
function (x, y, z) {
  var div = document.createElement('div');
  div.innerHTML = x + ', ' + y + ', ' + z;
  div.style.fontSize = '36px';
  div.style.fontWeight = 'bold';
  div.style.lineHeight = '256px';
  div.style.textAlign = 'center';
  div.style.color = '#4D4D4D';
  div.style.border = '1px dashed #ff5050';
  return div;
}
''';

  Future<void> _setup(KakaoMapController controller) async {
    mapController = controller;
    await controller.addTileset(const Tileset(
      id: 'TILE_NUMBER',
      tileFunction: _tileNumberFunction,
    ));
    await _toggle(true);
  }

  Future<void> _toggle(bool on) async {
    final controller = mapController;
    if (controller == null) return;
    if (on) {
      await controller.addOverlayTileset('TILE_NUMBER');
    } else {
      await controller.removeOverlayTileset('TILE_NUMBER');
    }
    if (!mounted) return;
    setState(() => overlayOn = on);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? selectedTitle)),
      body: Column(
        children: [
          Expanded(
            child: KakaoMap(
              onMapCreated: _setup,
              center: LatLng(37.566826, 126.9786567),
              currentLevel: 3,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SwitchListTile(
              title: const Text('타일 번호 오버레이'),
              subtitle: const Text('x, y, z 를 표시하는 DOM 타일을 지도 위에 겹칩니다.'),
              value: overlayOn,
              onChanged: _toggle,
            ),
          ),
        ],
      ),
    );
  }
}
