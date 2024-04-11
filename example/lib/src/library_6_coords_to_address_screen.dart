import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 좌표로 주소를 얻어내기
/// https://apis.map.kakao.com/web/sample/coord2addr/
class Library6CoordsToAddressScreen extends StatefulWidget {
  const Library6CoordsToAddressScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Library6CoordsToAddressScreen> createState() =>
      _Library6CoordsToAddressScreenState();
}

class _Library6CoordsToAddressScreenState
    extends State<Library6CoordsToAddressScreen> {
  late KakaoMapController mapController;

  bool draggable = true;
  bool zoomable = true;
  String address1 = '';
  String address2 = '';

  coord2Address() async {
    LatLng latLng = await mapController.getCenter();

    final request = Coord2AddressRequest(
      x: latLng.longitude,
      y: latLng.latitude,
    );

    final response = await mapController.coord2Address(request);
    final coord2address = response.list.first;

    final request2 = Coord2RegionCodeRequest(
      x: latLng.longitude,
      y: latLng.latitude,
    );
    final response2 = await mapController.coord2RegionCode(request2);
    final coord2RegionCode = response2.list.first;

    setState(() {
      address1 =
          '${coord2RegionCode.region1DepthName} ${coord2RegionCode.region2DepthName} ${coord2RegionCode.region3DepthName}';

      address2 = '';
      if (coord2address.roadAddress != null) {
        address2 += '도로명주소 : ${coord2address.roadAddress?.addressName}\n';
      }

      if (coord2address.address != null) {
        address2 += '지번주소 : ${coord2address.address?.addressName ?? ''}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                KakaoMap(
                  center: LatLng(37.4944992, 127.0252582),
                  onMapCreated: (controller) {
                    mapController = controller;

                    coord2Address();
                  },
                  onDragChangeCallback: (latLng, zoomLevel, dragType) async {
                    if (dragType == DragType.end) {
                      coord2Address();
                    }
                  },
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/marker.png',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 0, height: 0),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '지도중심기준 행정동 주소정보',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(address1),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 140,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '법정동 주소정보',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(address2),
              ],
            ),
          )
        ],
      ),
    );
  }
}
