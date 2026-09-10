import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';
import 'package:kakao_map_plugin_example/src/hover_note.dart';

/// 마커에 마우스 이벤트 등록하기
/// https://apis.map.kakao.com/web/sample/addMarkerMouseEvent/
///
/// 공식 샘플처럼 마우스를 올리면 마커 이미지가 커지고(mouseover) 벗어나면 원래대로
/// 돌아옵니다(mouseout). hover 는 마우스 포인터가 있는 환경(데스크톱 브라우저)
/// 전용이므로, 터치 기기에서는 탭(onMarkerTap)으로 같은 동작을 하도록 함께
/// 처리합니다.
class Overlay7MarkerMouseEventScreen extends StatefulWidget {
  const Overlay7MarkerMouseEventScreen({Key? key, this.title})
      : super(key: key);

  final String? title;

  @override
  State<Overlay7MarkerMouseEventScreen> createState() =>
      _Overlay7MarkerMouseEventScreenState();
}

class _Overlay7MarkerMouseEventScreenState
    extends State<Overlay7MarkerMouseEventScreen> {
  KakaoMapController? mapController;

  /// 현재 강조(hover/탭)된 마커 ID
  String? activeId;
  String lastEvent = '아직 이벤트가 없습니다.';

  static const _normalSrc =
      'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_number_blue.png';
  // 공식 샘플의 강조 이미지(marker_number_red.png)는 더 이상 제공되지 않아 단일 이미지로 대체합니다.
  static const _overSrc =
      'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_red.png';

  static final _positions = <String, LatLng>{
    'm0': LatLng(33.450705, 126.570677),
    'm1': LatLng(33.450936, 126.569477),
    'm2': LatLng(33.450879, 126.569940),
    'm3': LatLng(33.451393, 126.570738),
  };

  List<Marker> _markers() => [
        for (final entry in _positions.entries)
          if (activeId == entry.key)
            // 강조 상태: 빨간 마커를 조금 크게 (단일 이미지)
            Marker(
              markerId: entry.key,
              latLng: entry.value,
              markerImageSrc: _overSrc,
              width: 40,
              height: 43,
              offsetX: 20,
              offsetY: 43,
            )
          else
            // 기본 상태: 번호 스프라이트 시트에서 번호별 이미지를 잘라 씁니다. (Marker.spriteOrigin)
            Marker(
              markerId: entry.key,
              latLng: entry.value,
              markerImageSrc: _normalSrc,
              width: 36,
              height: 37,
              offsetX: 18,
              offsetY: 37,
              spriteOrigin: Point(0, int.parse(entry.key.substring(1)) * 46),
              spriteWidth: 36,
              spriteHeight: 691,
            ),
      ];

  void _setActive(String? id, String event) {
    setState(() {
      activeId = id;
      lastEvent = event;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? selectedTitle)),
      body: Column(
        children: [
          HoverNote(
            controller: mapController,
            hoverText: '마커 위에 마우스를 올리면 이미지가 바뀝니다.',
            touchText: '마커를 탭하면 강조되고, 다시 탭하면 해제됩니다.',
          ),
          Expanded(
            child: KakaoMap(
              onMapCreated: (c) => setState(() => mapController = c),
              center: LatLng(33.450701, 126.570667),
              markers: _markers(),
              // 마우스 환경: hover 로 강조
              onMarkerMouseOver: (id, latLng, level) =>
                  _setActive(id, 'mouseover: $id'),
              onMarkerMouseOut: (id, latLng, level) =>
                  _setActive(null, 'mouseout: $id'),
              // 터치 환경 대체: 탭으로 토글
              onMarkerTap: (id, latLng, level) =>
                  _setActive(activeId == id ? null : id, 'tap: $id'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(lastEvent, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
