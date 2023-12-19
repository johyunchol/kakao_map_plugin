import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 로드뷰 도로를 이용하여 로드뷰 생성하기
/// https://apis.map.kakao.com/web/sample/basicRoadview2/
class RoadView2DefaultScreen extends StatefulWidget {
  const RoadView2DefaultScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<RoadView2DefaultScreen> createState() => _RoadView2DefaultScreenState();
}

class _RoadView2DefaultScreenState extends State<RoadView2DefaultScreen> {
  late KakaoMapController mapController;
  late KakaoRoadMapController roadMapController;

  Set<Marker> markers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: MediaQuery.of(context).orientation == Orientation.portrait
          ? _portrait()
          : _landscape(),
    );
  }

  _portrait() {
    return Column(
      children: [
        Expanded(
          child: KakaoMap(
            markers: markers.toList(),
            onMapCreated: (controller) {
              mapController = controller;
              mapController.addOverlayMapTypeId(MapType.roadView);

              markers.add(
                Marker(
                  markerId: '${markers.length + 1}',
                  latLng: LatLng(33.450701, 126.570667),
                  width: 64,
                  height: 69,
                  offsetX: 27,
                  offsetY: 69,
                  markerImageSrc:
                      'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_red.png',
                  draggable: true,
                ),
              );

              setState(() {});
            },
            onMapTap: (latLng) {
              debugPrint('***** [latLng] ${latLng}');
              roadMapController.toggleRoadview(latLng);
            },
            onMarkerDragChangeCallback:
                (markerId, latLng, zoomLevel, markerDragType) {
              // roadMapController.
              debugPrint('***** [markerId] ${markerId}');
              debugPrint('***** [latLng] ${latLng}');
              debugPrint('***** [zoomLevel] ${zoomLevel}');
              debugPrint('***** [markerDragType] ${markerDragType}');
              roadMapController.toggleRoadview(latLng);
            },
          ),
        ),
        Expanded(child: KakaoRoadMap(
          onMapCreated: (controller) {
            roadMapController = controller;
            debugPrint('***** [roadview created] ');
          },
        )),
      ],
    );
  }

  _landscape() {
    return Row(
      children: [
        Expanded(child: KakaoMap()),
        Expanded(child: KakaoRoadMap()),
      ],
    );
  }
}
