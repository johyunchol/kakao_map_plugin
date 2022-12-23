import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

class MenuItem {
  final String title;
  final MapType mapType;
  bool isChecked;

  MenuItem({
    required this.title,
    required this.mapType,
    this.isChecked = false,
  });
}

/// 지도 범위 재설정 하기
/// https://apis.map.kakao.com/web/sample/setBounds/
class Map14RegionResetScreen extends StatefulWidget {
  const Map14RegionResetScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Map14RegionResetScreen> createState() => _Map14RegionResetScreenState();
}

class _Map14RegionResetScreenState extends State<Map14RegionResetScreen> {
  late KakaoMapController mapController;
  late List<MenuItem> overlayList = [
    MenuItem(title: '로드뷰', mapType: MapType.roadView),
    MenuItem(title: '레이블', mapType: MapType.overlay),
    MenuItem(title: '교통정보', mapType: MapType.traffic),
    MenuItem(title: '지형도', mapType: MapType.terrain),
    MenuItem(title: '자전거', mapType: MapType.bicycle),
    MenuItem(title: '스카이뷰\n자전거', mapType: MapType.bicycleHybrid),
    MenuItem(title: '지적편집도', mapType: MapType.useDistrict),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: Stack(
        children: [
          KakaoMap(
            onMapCreated: ((controller) {
              mapController = controller;
            }),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  MaterialButton(
                    onPressed: () {
                      mapController.fitBounds([
                        LatLng(33.452278, 126.567803),
                        LatLng(33.452671, 126.574792),
                        LatLng(33.451744, 126.572441),
                      ]);
                    },
                    color: Colors.white,
                    child: const Text("지도 범위 재설정"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  clear() {
    for (var item in overlayList) {
      item.isChecked = false;
      mapController.removeOverlayMapTypeId(item.mapType);
    }
  }
}
