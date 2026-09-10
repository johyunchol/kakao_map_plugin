import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 커스텀 타일셋1 — 타일 주소 함수(urlFunc)로 기본 지도 타일을 바꿉니다.
/// https://apis.map.kakao.com/web/sample/customTileset/
///
/// 공식 샘플은 별도 투영(projectionId: null)과 샘플 이미지를 쓰지만, 여기서는
/// 일반 위경도 지도 위에 canvas 로 그린 격자 타일을 올려 같은 API 를 보여줍니다.
class Map24CustomTilesetScreen extends StatefulWidget {
  const Map24CustomTilesetScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Map24CustomTilesetScreen> createState() =>
      _Map24CustomTilesetScreenState();
}

class _Map24CustomTilesetScreenState extends State<Map24CustomTilesetScreen> {
  KakaoMapController? mapController;
  String selected = 'NORMAL';
  String activeId = '(없음)';

  /// x, y, z 를 canvas 에 그려 data URL 로 돌려주는 타일 주소 함수입니다.
  static const String _gridUrlFunction = r'''
function (x, y, z) {
  var canvas = document.createElement('canvas');
  canvas.width = 256;
  canvas.height = 256;
  var g = canvas.getContext('2d');
  g.fillStyle = (x + y) % 2 === 0 ? '#e3f2fd' : '#fff3e0';
  g.fillRect(0, 0, 256, 256);
  g.strokeStyle = '#90a4ae';
  g.strokeRect(0.5, 0.5, 255, 255);
  g.fillStyle = '#37474f';
  g.font = 'bold 22px sans-serif';
  g.textAlign = 'center';
  g.textBaseline = 'middle';
  g.fillText(x + ', ' + y + ', ' + z, 128, 128);
  return canvas.toDataURL();
}
''';

  Future<void> _setup(KakaoMapController controller) async {
    mapController = controller;

    // 1) 주소 함수로 만드는 타일셋
    await controller.addTileset(const Tileset(
      id: 'GRID',
      urlFunction: _gridUrlFunction,
      copyright: [TilesetCopyright('격자 타일 예제', shortMsg: '격자')],
    ));

    // 2) 주소 템플릿으로 만드는 타일셋 ({x} {y} {z} 치환)
    await controller.addTileset(const Tileset(
      id: 'BLANK',
      urlTemplate: 'https://i1.daumcdn.net/dmaps/apis/white.png?z={z}&y={y}&x={x}',
      copyright: [TilesetCopyright('빈 타일 예제')],
    ));
  }

  Future<void> _select(String id) async {
    final controller = mapController;
    if (controller == null) return;

    if (id == 'NORMAL') {
      await controller.setMapTypeId(MapType.normal);
    } else {
      await controller.setTileset(id);
    }
    final active = await controller.getActiveTilesetId();
    if (!mounted) return;
    setState(() {
      selected = id;
      activeId = active ?? '(없음)';
    });
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
              currentLevel: 4,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'NORMAL', label: Text('일반 지도')),
                    ButtonSegment(value: 'GRID', label: Text('격자 타일')),
                    ButtonSegment(value: 'BLANK', label: Text('빈 타일')),
                  ],
                  selected: {selected},
                  onSelectionChanged: (values) => _select(values.first),
                ),
                const SizedBox(height: 8),
                Text('현재 타일셋: $activeId'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
