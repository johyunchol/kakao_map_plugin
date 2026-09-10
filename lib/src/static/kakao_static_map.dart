import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../basic/callbacks.dart';
import '../basic/marker.dart';
import '../bridge/bridge_factory.dart';
import '../bridge/kakao_map_bridge.dart';
import '../constants/wrapper.dart';
import '../model/lat_lng.dart';
import '../repository/auth_repository.dart';

class KakaoStaticMap extends StatefulWidget {
  final MapCreateCallback? onMapCreated;
  final int currentLevel;
  final LatLng? center;
  final List<Marker>? markers;

  /// Specifies which gestures should be consumed by the map.
  ///
  /// When this set is empty (default), the map will only handle pointer events
  /// for gestures that were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  const KakaoStaticMap({
    super.key,
    this.onMapCreated,
    this.currentLevel = 3,
    this.center,
    this.markers,
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
  });

  @override
  State<KakaoStaticMap> createState() => _KakaoStaticMapState();
}

class _KakaoStaticMapState extends State<KakaoStaticMap> with WidgetsBindingObserver {
  String json = '';
  List<Map<String, dynamic>> mapList = [];
  late final KakaoMapBridge _bridge;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initMarkers();
    _initializeWebView();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bridge.dispose().catchError((_) {});
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Handle app lifecycle changes to fix WebView rendering issues
    // when returning from background (Flutter 3.27+ issue)
    if (state == AppLifecycleState.resumed && _isInitialized) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _bridge.reload();
        }
      });
    }
  }

  void _initializeWebView() {
    _bridge = createKakaoMapBridge();
    _bridge.loadHtml(_loadMap(), baseUrl: AuthRepository.instance.baseUrl);
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return _bridge.buildView(
      gestureRecognizers: widget.gestureRecognizers,
    );
  }

  void initMarkers() {
    int length = widget.markers?.length ?? 0;

    for (int i = 0; i < length; i++) {
      final item = widget.markers![i];
      Map<String, dynamic> marker = {
        "markerId": item.markerId,
        "latitude": item.latLng.latitude,
        "longitude": item.latLng.longitude,
        "text": item.infoWindowContent,
      };

      mapList.add(marker);
    }

    json = jsonEncode(mapList);
  }

  String _loadMap() {
    return htmlWrapper("""<script>
  let map = null;

  window.onload = function () {
    // Kakao Maps SDK가 완전히 로드된 후 지도를 초기화합니다
    kakao.maps.load(function() {
      initializeStaticMap();
    });
  }

  function initializeStaticMap() {
    const staticMapContainer = document.getElementById('map');

    let center = new kakao.maps.LatLng(33.450701, 126.570667);
    if (${widget.center != null}) {
      center = new kakao.maps.LatLng(${widget.center?.latitude}, ${widget.center?.longitude});
    }

    const staticMapOption = {
      center: center,
      level: ${widget.currentLevel},
      marker: getMarkers(),
    };

    map = new kakao.maps.StaticMap(staticMapContainer, staticMapOption);
  }

  function getMarkers() {

    let markers = [];
    const list = $json;

    for (let i = 0; i < list.length; i++) {
      const item = list[i];
      const obj = {
        'position': new kakao.maps.LatLng(item.latitude, item.longitude),
      }

      if (item.text !== null && item.text !== '') {
        obj['text'] = item.text;
      }

      markers.push(obj);
    }

    return markers;
  }
</script>""");
  }
}
