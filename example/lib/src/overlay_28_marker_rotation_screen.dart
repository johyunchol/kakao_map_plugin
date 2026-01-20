import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 마커 회전하기
class Overlay28MarkerRotationScreen extends StatefulWidget {
  const Overlay28MarkerRotationScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Overlay28MarkerRotationScreen> createState() =>
      _Overlay28MarkerRotationScreenState();
}

class _Overlay28MarkerRotationScreenState
    extends State<Overlay28MarkerRotationScreen> {
  late KakaoMapController mapController;
  Set<Marker> markers = {};
  double currentRotation = 45;
  bool useCustomImage = true;
  MarkerIcon? customIcon;
  List<String> debugLogs = [];
  bool isMapReady = false;

  @override
  void initState() {
    super.initState();
    _loadCustomIcon();
  }

  Future<void> _loadCustomIcon() async {
    try {
      customIcon = await MarkerIcon.fromAsset('assets/images/marker.png');
      _addLog('커스텀 아이콘 로드 완료');
      setState(() {});
    } catch (e) {
      _addLog('커스텀 아이콘 로드 실패: $e');
    }
  }

  void _addLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    debugLogs.insert(0, '[$timestamp] $message');
    if (debugLogs.length > 30) {
      debugLogs.removeLast();
    }
    if (mounted) setState(() {});
  }

  void _createSingleMarker() {
    _addLog('단일 마커 생성 - rotation: $currentRotation, customImage: $useCustomImage');

    markers.clear();

    final marker = Marker(
      markerId: 'test_marker',
      latLng: LatLng(37.5665, 126.9780),
      rotation: currentRotation,
      icon: useCustomImage ? customIcon : null,
      width: 64,
      height: 64,
      infoWindowContent: '회전: ${currentRotation.toStringAsFixed(0)}°',
      infoWindowFirstShow: false,
    );
    markers.add(marker);

    _addLog('마커 객체 생성 완료 - icon: ${marker.icon != null}, rotation: ${marker.rotation}');

    // setState로 위젯 업데이트 → didUpdateWidget에서 자동으로 addMarker 호출됨
    setState(() {});
    _addLog('setState 호출 완료 - 위젯이 마커를 자동 추가합니다');
  }

  void _createMultipleMarkers() {
    _addLog('다중 마커 생성 시작');

    markers.clear();

    final center = LatLng(37.5665, 126.9780);
    final rotations = [0.0, 90.0, 180.0, 270.0];
    final offsets = [
      [0.003, 0.0],    // 북
      [0.0, 0.003],    // 동
      [-0.003, 0.0],   // 남
      [0.0, -0.003],   // 서
    ];

    for (int i = 0; i < rotations.length; i++) {
      markers.add(Marker(
        markerId: 'marker_${rotations[i].toInt()}',
        latLng: LatLng(
          center.latitude + offsets[i][0],
          center.longitude + offsets[i][1],
        ),
        rotation: rotations[i],
        icon: useCustomImage ? customIcon : null,
        width: 64,
        height: 64,
        infoWindowContent: '${rotations[i].toInt()}°',
      ));
      _addLog('마커 추가: ${rotations[i]}°');
    }

    _addLog('다중 마커 ${markers.length}개 생성 완료');

    // setState로 위젯 업데이트 → didUpdateWidget에서 자동으로 addMarker 호출됨
    setState(() {});
  }

  void _clearMarkers() {
    markers.clear();
    _addLog('모든 마커 제거');
    // setState로 위젯 업데이트 → didUpdateWidget에서 자동으로 clearMarker 호출됨
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: Column(
        children: [
          // 지도 영역
          Expanded(
            flex: 2,
            child: KakaoMap(
              onMapCreated: ((controller) {
                mapController = controller;
                isMapReady = true;
                _addLog('지도 생성 완료 - 마커 버튼을 눌러 테스트하세요');
                setState(() {});
              }),
              markers: markers.toList(),
              center: LatLng(37.5665, 126.9780),
            ),
          ),
          // 컨트롤 패널
          Container(
            padding: const EdgeInsets.all(12.0),
            color: Colors.grey[100],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 이미지 타입 선택
                Row(
                  children: [
                    const Text('이미지: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ChoiceChip(
                      label: const Text('커스텀', style: TextStyle(fontSize: 11)),
                      selected: useCustomImage,
                      onSelected: (selected) {
                        setState(() => useCustomImage = true);
                        _addLog('커스텀 이미지 모드');
                      },
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 4),
                    ChoiceChip(
                      label: const Text('기본', style: TextStyle(fontSize: 11)),
                      selected: !useCustomImage,
                      onSelected: (selected) {
                        setState(() => useCustomImage = false);
                        _addLog('기본 마커 모드');
                      },
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 회전 슬라이더
                Row(
                  children: [
                    Text('회전: ${currentRotation.toStringAsFixed(0)}°',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Slider(
                        value: currentRotation,
                        min: 0,
                        max: 360,
                        divisions: 36,
                        onChanged: (value) {
                          setState(() => currentRotation = value);
                        },
                      ),
                    ),
                  ],
                ),
                // 버튼들
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: isMapReady ? _createSingleMarker : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text('단일 마커', style: TextStyle(fontSize: 12, color: Colors.white)),
                    ),
                    ElevatedButton(
                      onPressed: isMapReady ? _createMultipleMarkers : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text('다중 마커 (4개)', style: TextStyle(fontSize: 12, color: Colors.white)),
                    ),
                    ElevatedButton(
                      onPressed: isMapReady ? _clearMarkers : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text('지우기', style: TextStyle(fontSize: 12, color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 디버그 로그 영역
          Container(
            height: 100,
            padding: const EdgeInsets.all(8),
            color: Colors.black87,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '디버그 로그',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                    GestureDetector(
                      onTap: () {
                        debugLogs.clear();
                        setState(() {});
                      },
                      child: const Text('지우기', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: ListView.builder(
                    itemCount: debugLogs.length,
                    itemBuilder: (context, index) {
                      return Text(
                        debugLogs[index],
                        style: const TextStyle(color: Colors.white70, fontSize: 9),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
