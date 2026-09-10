import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 지도 영역 밖의 마커위치 추적하기
/// https://apis.map.kakao.com/web/sample/markerTracker/
class Overlay26MarkerTrackerScreen extends StatefulWidget {
  const Overlay26MarkerTrackerScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Overlay26MarkerTrackerScreen> createState() =>
      _Overlay26MarkerTrackerScreenState();
}

class _Overlay26MarkerTrackerScreenState
    extends State<Overlay26MarkerTrackerScreen> {
  late KakaoMapController mapController;

  /// 지구 반지름(미터). 하버사인 거리 계산에 사용합니다.
  static const double _earthRadiusMeters = 6371000;

  /// 초기 지도 중심(서울시청)입니다.
  static final LatLng _initialCenter = LatLng(37.5665, 126.9780);

  /// 추적할 고정 마커 좌표입니다. 화면 밖으로 벗어난 모습을 바로 확인할 수 있도록
  /// 초기 중심에서 멀리 떨어진 부산에 둡니다.
  static final LatLng _trackedLatLng = LatLng(35.1795543, 129.0756416);

  Set<Marker> markers = {};

  bool _mapReady = false;

  /// KakaoMap 이 차지하는 영역의 크기입니다. LayoutBuilder 로 얻습니다.
  Size? _mapSize;

  /// 추적 마커의 현재 화면 픽셀 좌표입니다.
  Point? _markerPixel;

  /// 마커가 화면(지도 영역) 안에 있는지 여부입니다.
  bool _isMarkerInside = true;

  /// 화면 중심에서 마커를 향하는 방향 각도(라디안)입니다.
  double _bearingRadians = 0;

  /// 지도 중심에서 마커까지의 거리(미터)입니다.
  double _distanceMeters = 0;

  double _degToRad(double deg) => deg * math.pi / 180;

  /// 하버사인 공식으로 두 좌표 사이의 거리(미터)를 계산합니다.
  double _haversineDistance(LatLng from, LatLng to) {
    final dLat = _degToRad(to.latitude - from.latitude);
    final dLng = _degToRad(to.longitude - from.longitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(from.latitude)) *
            math.cos(_degToRad(to.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return _earthRadiusMeters * c;
  }

  /// 추적 마커의 화면 픽셀 좌표를 다시 계산하고, 화면 밖 여부/방향/거리를 갱신합니다.
  Future<void> _updateTracker(LatLng currentCenter) async {
    final size = _mapSize;
    if (size == null || !_mapReady) return;

    // 화면을 벗어나는 도중이면 WebView 가 이미 정리되어 호출이 실패할 수 있습니다.
    final Point pixel;
    try {
      pixel = await mapController.coordToPixel(_trackedLatLng);
    } catch (_) {
      return;
    }
    if (!mounted) return;

    final isInside = pixel.x >= 0 &&
        pixel.x <= size.width &&
        pixel.y >= 0 &&
        pixel.y <= size.height;

    setState(() {
      _markerPixel = pixel;
      _isMarkerInside = isInside;
      _bearingRadians =
          math.atan2(pixel.y - size.height / 2, pixel.x - size.width / 2);
      _distanceMeters = _haversineDistance(currentCenter, _trackedLatLng);
    });
  }

  /// 화면 중심에서 [_bearingRadians] 방향으로 나아가 사각형 가장자리와
  /// 만나는 지점을 계산합니다(레이-사각형 교차).
  Offset _edgePosition(Size size) {
    const margin = 28.0; // 화살표 아이콘이 잘리지 않도록 여백을 둡니다.
    final halfWidth = math.max(size.width / 2 - margin, 0);
    final halfHeight = math.max(size.height / 2 - margin, 0);

    final cosT = math.cos(_bearingRadians);
    final sinT = math.sin(_bearingRadians);

    var t = double.infinity;
    if (cosT.abs() > 1e-6) {
      t = math.min(t, halfWidth / cosT.abs());
    }
    if (sinT.abs() > 1e-6) {
      t = math.min(t, halfHeight / sinT.abs());
    }

    return Offset(
      size.width / 2 + t * cosT,
      size.height / 2 + t * sinT,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          _mapSize = Size(constraints.maxWidth, constraints.maxHeight);

          return Stack(
            children: [
              KakaoMap(
                onMapCreated: (controller) async {
                  mapController = controller;
                  _mapReady = true;

                  markers = {
                    Marker(
                      markerId: 'tracked_marker',
                      latLng: _trackedLatLng,
                      width: 30,
                      height: 44,
                      offsetX: 15,
                      offsetY: 44,
                      markerImageSrc:
                          'https://w7.pngwing.com/pngs/96/889/png-transparent-marker-map-interesting-places-the-location-on-the-map-the-location-of-the-thumbnail.png',
                    ),
                  };

                  setState(() {});

                  await _updateTracker(await mapController.getCenter());
                },
                onCameraIdle: (latLng, zoomLevel) => _updateTracker(latLng),
                markers: markers.toList(),
                currentLevel: 5,
                center: _initialCenter,
              ),
              if (!_isMarkerInside && _mapSize != null)
                KakaoMapPointerInterceptor(child: _buildEdgeArrow(_mapSize!)),
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: KakaoMapPointerInterceptor(child: _buildStatusPanel()),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEdgeArrow(Size size) {
    final edge = _edgePosition(size);
    const iconSize = 36.0;

    return Positioned(
      left: edge.dx - iconSize / 2,
      top: edge.dy - iconSize / 2,
      child: IgnorePointer(
        child: Transform.rotate(
          // Icons.arrow_upward 는 기본적으로 위쪽(-90도)을 가리키므로
          // 목표 방향(bearing)에 맞추려면 +90도를 더해 회전시킵니다.
          angle: _bearingRadians + math.pi / 2,
          child: Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_upward, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPanel() {
    final bearingDegrees = (_bearingRadians * 180 / math.pi + 360) % 360;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isMarkerInside ? '마커가 화면 안에 있습니다' : '마커가 화면 밖에 있습니다 (화살표 방향 참고)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _isMarkerInside ? Colors.green[700] : Colors.red,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '마커까지 거리: ${(_distanceMeters / 1000).toStringAsFixed(2)} km'
            ' / 방향: ${bearingDegrees.toStringAsFixed(0)}°',
            style: const TextStyle(fontSize: 12),
          ),
          if (_markerPixel != null) ...[
            const SizedBox(height: 4),
            Text(
              '마커 픽셀 좌표: (${_markerPixel!.x.toStringAsFixed(0)}, ${_markerPixel!.y.toStringAsFixed(0)})',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ],
      ),
    );
  }
}
