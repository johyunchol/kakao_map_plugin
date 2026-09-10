import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 원의 반경 계산하기
/// https://apis.map.kakao.com/web/sample/calculateCircleRadius/
class Overlay20CircleRadiusScreen extends StatefulWidget {
  const Overlay20CircleRadiusScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Overlay20CircleRadiusScreen> createState() =>
      _Overlay20CircleRadiusScreenState();
}

class _Overlay20CircleRadiusScreenState
    extends State<Overlay20CircleRadiusScreen> {
  late KakaoMapController mapController;

  LatLng? centerPoint;
  LatLng? edgePoint;

  Set<Marker> markers = {};
  Set<Circle> circles = {};
  Set<Polyline> polylines = {};

  double radius = 0;

  @override
  void initState() {
    super.initState();
  }

  double _degToRad(double deg) => deg * pi / 180;

  /// 하버사인 공식으로 두 좌표 사이의 거리(미터)를 계산합니다.
  double _calculateDistance(LatLng from, LatLng to) {
    const earthRadius = 6371000.0;

    final dLat = _degToRad(to.latitude - from.latitude);
    final dLon = _degToRad(to.longitude - from.longitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(from.latitude)) *
            cos(_degToRad(to.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  void _handleMapTap(LatLng latLng) {
    setState(() {
      if (centerPoint == null || edgePoint != null) {
        // 처음 탭이거나 이미 원이 완성된 상태면 새로 시작합니다
        centerPoint = latLng;
        edgePoint = null;
        radius = 0;
        circles = {};
        polylines = {};
      } else {
        // 두 번째 탭으로 반경을 확정합니다
        edgePoint = latLng;
        radius = _calculateDistance(centerPoint!, edgePoint!);

        circles = {
          Circle(
            circleId: 'radiusCircle',
            center: centerPoint!,
            radius: radius,
            strokeWidth: 3,
            strokeColor: Colors.blue,
            strokeOpacity: 0.8,
            strokeStyle: StrokeStyle.solid,
            fillColor: Colors.blue,
            fillOpacity: 0.2,
          ),
        };

        polylines = {
          Polyline(
            polylineId: 'radiusLine',
            points: [centerPoint!, edgePoint!],
            strokeWidth: 2,
            strokeColor: Colors.red,
            strokeOpacity: 0.8,
            strokeStyle: StrokeStyle.shortDash,
          ),
        };
      }

      markers = {
        Marker(
          markerId: 'center',
          latLng: centerPoint!,
          width: 24,
          height: 24,
        ),
        if (edgePoint != null)
          Marker(
            markerId: 'edge',
            latLng: edgePoint!,
            width: 24,
            height: 24,
          ),
      };
    });
  }

  void _resetCircle() {
    setState(() {
      centerPoint = null;
      edgePoint = null;
      radius = 0;
      markers = {};
      circles = {};
      polylines = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    String guideText;
    if (centerPoint == null) {
      guideText = '지도를 탭해 원의 중심을 지정하세요';
    } else if (edgePoint == null) {
      guideText = '지도를 탭해 반경 끝점을 지정하세요';
    } else if (radius >= 1000) {
      guideText =
          '반경: ${radius.toStringAsFixed(1)} m (${(radius / 1000).toStringAsFixed(2)} km)';
    } else {
      guideText = '반경: ${radius.toStringAsFixed(1)} m';
    }

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
            onMapTap: _handleMapTap,
            markers: markers.toList(),
            circles: circles.toList(),
            polylines: polylines.toList(),
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
                child: Text(
                  guideText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )),
          ),
        ],
      ),
      floatingActionButton: KakaoMapPointerInterceptor(
          child: FloatingActionButton(
        onPressed: _resetCircle,
        tooltip: '초기화',
        child: const Icon(Icons.refresh),
      )),
    );
  }
}
