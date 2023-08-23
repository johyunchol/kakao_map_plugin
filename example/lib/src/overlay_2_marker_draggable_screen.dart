import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 마커 생성하기
/// https://apis.map.kakao.com/web/sample/basicMarker/
class Overlay2MarkerDraggableScreen extends StatefulWidget {
  const Overlay2MarkerDraggableScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Overlay2MarkerDraggableScreen> createState() =>
      _Overlay2MarkerDraggableScreenState();
}

class _Overlay2MarkerDraggableScreenState
    extends State<Overlay2MarkerDraggableScreen> {
  late KakaoMapController mapController;

  Set<Marker> markers = {};
  late Marker marker;

  @override
  void initState() {
    marker = Marker(
      markerId: 'markerId',
      latLng: LatLng(37.3608681, 126.9306506),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: Stack(
        children: [
          KakaoMap(
            onMapCreated: ((controller) async {
              mapController = controller;

              markers.add(marker);

              setState(() {});
            }),
            onMarkerDragChangeCallback: ((String markerId, LatLng latLng,
                int zoomLevel, MarkerDragType markerDragType) {
              if (markerDragType == MarkerDragType.end) {
                mapController.panTo(latLng);
              }
            }),
            markers: markers.toList(),
            center: LatLng(37.3608681, 126.9306506),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                MaterialButton(
                  onPressed: () {
                    marker.draggable = true;

                    setState(() {});
                  },
                  color: Colors.white,
                  child: const Text("draggable true"),
                ),
                const SizedBox(width: 8),
                MaterialButton(
                  onPressed: () {
                    marker.draggable = false;

                    setState(() {});
                  },
                  color: Colors.white,
                  child: const Text("draggable false"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
