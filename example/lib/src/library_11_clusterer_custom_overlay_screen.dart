import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 클러스터러에 커스텀 오버레이 사용하기
/// 마커 클러스터러에 커스텀 오버레이 콘텐츠를 함께 사용하는 예제입니다.
/// 줌 레벨에 따라 클러스터링된 마커는 클러스터로 표시되고,
/// 개별 마커는 커스텀 오버레이로 표시됩니다.
class Library11ClustererCustomOverlayScreen extends StatefulWidget {
  const Library11ClustererCustomOverlayScreen({Key? key, this.title})
      : super(key: key);

  final String? title;

  @override
  State<Library11ClustererCustomOverlayScreen> createState() =>
      _Library11ClustererCustomOverlayScreenState();
}

class _Library11ClustererCustomOverlayScreenState
    extends State<Library11ClustererCustomOverlayScreen> {
  late KakaoMapController mapController;

  Clusterer? clusterer;

  // 샘플 장소 데이터
  final List<Map<String, dynamic>> places = [
    {'name': '서울역', 'lat': 37.5546788, 'lng': 126.9706069},
    {'name': '광화문', 'lat': 37.5759853, 'lng': 126.9768465},
    {'name': '종로', 'lat': 37.5704164, 'lng': 126.9921553},
    {'name': '명동', 'lat': 37.5636463, 'lng': 126.9827767},
    {'name': '강남역', 'lat': 37.4979517, 'lng': 127.0276188},
    {'name': '삼성역', 'lat': 37.5088856, 'lng': 127.0630891},
    {'name': '잠실역', 'lat': 37.5132597, 'lng': 127.1001356},
    {'name': '건대입구', 'lat': 37.5403019, 'lng': 127.0693079},
    {'name': '홍대입구', 'lat': 37.5571256, 'lng': 126.9246018},
    {'name': '신촌', 'lat': 37.5553442, 'lng': 126.9366360},
    {'name': '이대', 'lat': 37.5568906, 'lng': 126.9458984},
    {'name': '합정', 'lat': 37.5495678, 'lng': 126.9139085},
    {'name': '영등포', 'lat': 37.5158696, 'lng': 126.9075556},
    {'name': '여의도', 'lat': 37.5218509, 'lng': 126.9249117},
    {'name': '용산', 'lat': 37.5299396, 'lng': 126.9648619},
    {'name': '왕십리', 'lat': 37.5611853, 'lng': 127.0379991},
    {'name': '성수', 'lat': 37.5445556, 'lng': 127.0559226},
    {'name': '뚝섬', 'lat': 37.5474756, 'lng': 127.0472078},
    {'name': '압구정', 'lat': 37.5267678, 'lng': 127.0284012},
    {'name': '청담', 'lat': 37.5198278, 'lng': 127.0535736},
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
            child: KakaoMap(
              center: LatLng(37.5505, 127.0),
              currentLevel: 8,
              onMapCreated: (controller) {
                mapController = controller;
                _initClusterer();
              },
              clusterer: clusterer,
              onMarkerClustererTap: (latLng, zoomLevel, markers) {
                debugPrint(
                    '***** [클러스터 클릭] 위치: $latLng, 줌레벨: $zoomLevel, 마커 수: ${markers.length}');
                // 클러스터 클릭 시 포함된 마커 이름 출력
                for (var marker in markers) {
                  debugPrint('  - 마커 ID: ${marker.markerId}');
                }
              },
              onCustomOverlayTap: (id, latLng) {
                debugPrint('***** [커스텀 오버레이 클릭] ID: $id, 위치: $latLng');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$id 클릭됨'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '클러스터러 + 커스텀 오버레이 테스트',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  '- 줌 아웃: 마커들이 클러스터로 그룹화됩니다\n'
                  '- 줌 인: 개별 마커가 커스텀 오버레이로 표시됩니다\n'
                  '- 커스텀 오버레이를 클릭하면 이름이 표시됩니다',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        mapController.setLevel(5);
                      },
                      child: const Text('줌 인 (레벨 5)'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        mapController.setLevel(10);
                      },
                      child: const Text('줌 아웃 (레벨 10)'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _initClusterer() {
    Set<Marker> markers = {};

    for (int i = 0; i < places.length; i++) {
      final place = places[i];
      markers.add(Marker(
        markerId: place['name'],
        latLng: LatLng(place['lat'], place['lng']),
        // 커스텀 오버레이 콘텐츠 설정
        customOverlayContent: '''
          <div style="
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 8px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
            box-shadow: 0 2px 6px rgba(0,0,0,0.3);
            white-space: nowrap;
            cursor: pointer;
          ">
            ${place['name']}
          </div>
        ''',
        customOverlayYAnchor: 1.5,
      ));
    }

    clusterer = Clusterer(
      markers: markers.toList(),
      gridSize: 60,
      minLevel: 7,
      averageCenter: true,
      minClusterSize: 2,
      styles: [
        ClustererStyle(
          width: 50,
          height: 50,
          background: Colors.blue.withOpacity(0.8),
          borderRadius: 25,
          color: Colors.white,
          textAlign: 'center',
          lineHeight: 50,
        ),
        ClustererStyle(
          width: 60,
          height: 60,
          background: Colors.orange.withOpacity(0.8),
          borderRadius: 30,
          color: Colors.white,
          textAlign: 'center',
          lineHeight: 60,
        ),
        ClustererStyle(
          width: 70,
          height: 70,
          background: Colors.red.withOpacity(0.8),
          borderRadius: 35,
          color: Colors.white,
          textAlign: 'center',
          lineHeight: 70,
        ),
      ],
      calculator: [5, 10, 15],
    );

    setState(() {});
  }
}
