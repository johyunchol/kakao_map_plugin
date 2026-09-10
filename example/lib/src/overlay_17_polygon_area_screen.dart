import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 다각형의 면적 계산하기
/// https://apis.map.kakao.com/web/sample/calculatePolygonArea/
class Overlay17PolygonAreaScreen extends StatefulWidget {
  const Overlay17PolygonAreaScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Overlay17PolygonAreaScreen> createState() =>
      _Overlay17PolygonAreaScreenState();
}

class _Overlay17PolygonAreaScreenState
    extends State<Overlay17PolygonAreaScreen> {
  late KakaoMapController mapController;

  final List<LatLng> points = [];

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  Set<Polygon> polygons = {};

  double area = 0;

  @override
  void initState() {
    super.initState();
  }

  /// 지도에 그려진 다각형의 면적을 SDK(`getArea`)로 다시 계산해 반영합니다.
  ///
  /// 다각형은 위젯 속성으로 전달되어 다음 프레임에 지도에 반영되므로, 프레임이
  /// 끝난 뒤 조회합니다.
  Future<void> _refreshAreaFromSdk() async {
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    try {
      final sdkArea = await mapController.getPolygonArea('areaPolygon');
      if (!mounted) return;
      setState(() => area = sdkArea);
    } catch (e) {
      debugPrint('면적 조회 실패: $e');
    }
  }

  /// 위경도 좌표를 미터 단위 평면 좌표로 근사 변환한 뒤
  /// 신발끈 공식(shoelace formula)으로 다각형의 면적(㎡)을 계산합니다.
  double _calculatePolygonArea(List<LatLng> vertices) {
    if (vertices.length < 3) return 0;

    final avgLat = vertices.map((e) => e.latitude).reduce((a, b) => a + b) /
        vertices.length;
    final avgLatRad = avgLat * pi / 180;

    final xs = <double>[];
    final ys = <double>[];
    for (final vertex in vertices) {
      xs.add((vertex.longitude - vertices.first.longitude) *
          111320 *
          cos(avgLatRad));
      ys.add((vertex.latitude - vertices.first.latitude) * 110540);
    }

    var shoelaceSum = 0.0;
    for (var i = 0; i < xs.length; i++) {
      final j = (i + 1) % xs.length;
      shoelaceSum += xs[i] * ys[j] - xs[j] * ys[i];
    }

    return shoelaceSum.abs() / 2;
  }

  void _updateOverlays() {
    markers = {
      for (var i = 0; i < points.length; i++)
        Marker(
          markerId: 'vertex_$i',
          latLng: points[i],
          width: 20,
          height: 20,
        ),
    };

    polylines = points.length >= 2
        ? {
            Polyline(
              polylineId: 'polygonGuideLine',
              points: points,
              strokeWidth: 3,
              strokeColor: Colors.blue,
              strokeOpacity: 0.8,
              strokeStyle: StrokeStyle.solid,
            ),
          }
        : {};

    if (points.length >= 3) {
      polygons = {
        Polygon(
          polygonId: 'areaPolygon',
          points: points,
          strokeWidth: 3,
          strokeColor: Colors.red,
          strokeOpacity: 0.8,
          strokeStyle: StrokeStyle.solid,
          fillColor: Colors.red,
          fillOpacity: 0.3,
        ),
      };
      // 즉시 표시용 근사값. 지도에 다각형이 그려진 뒤 SDK 계산값으로 바꿉니다.
      area = _calculatePolygonArea(points);
      _refreshAreaFromSdk();
    } else {
      polygons = {};
      area = 0;
    }
  }

  void _resetPolygon() {
    setState(() {
      points.clear();
      markers = {};
      polylines = {};
      polygons = {};
      area = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final areaText = points.length < 3
        ? '점을 3개 이상 찍어주세요'
        : area >= 10000
            ? '면적: ${area.toStringAsFixed(2)} ㎡ (${(area / 1000000).toStringAsFixed(3)} ㎢)'
            : '면적: ${area.toStringAsFixed(2)} ㎡';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: Stack(
        children: [
          KakaoMap(
            onMapCreated: ((controller) async {
              mapController = controller;
            }),
            onMapTap: (latLng) {
              setState(() {
                points.add(latLng);
                _updateOverlays();
              });
            },
            markers: markers.toList(),
            polylines: polylines.toList(),
            polygons: polygons.toList(),
            center: LatLng(37.3608681, 126.9306506),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: KakaoMapPointerInterceptor(
                child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('찍은 꼭짓점 개수: ${points.length}개'),
                    const SizedBox(height: 8),
                    Text(
                      areaText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ),
        ],
      ),
      floatingActionButton: KakaoMapPointerInterceptor(
          child: FloatingActionButton(
        onPressed: _resetPolygon,
        tooltip: '초기화',
        child: const Icon(Icons.refresh),
      )),
    );
  }
}
