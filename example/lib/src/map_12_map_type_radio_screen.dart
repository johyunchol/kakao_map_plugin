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

/// 지도 타입 바꾸기1
/// https://apis.map.kakao.com/web/sample/changeOverlay1/
class Map12MapTypeRadioScreen extends StatefulWidget {
  const Map12MapTypeRadioScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Map12MapTypeRadioScreen> createState() =>
      _Map12MapTypeRadioScreenState();
}

class _Map12MapTypeRadioScreenState extends State<Map12MapTypeRadioScreen> {
  late KakaoMapController mapController;
  late List<MenuItem> overlayList = [
    MenuItem(title: '교통정보 보기', mapType: MapType.traffic),
    MenuItem(title: '로드뷰 도로정보 보기', mapType: MapType.roadView),
    MenuItem(title: '지형정보 보기', mapType: MapType.terrain),
    MenuItem(title: '지적편집도 보기', mapType: MapType.useDistrict),
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
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ...overlayList
                    .map(
                      (selectedItem) => ElevatedButton(
                        onPressed: () {
                          clear();

                          mapController
                              .addOverlayMapTypeId(selectedItem.mapType);

                          setState(() {});
                          // setChecked(item);
                        },
                        child: Text(selectedItem.title,
                            textAlign: TextAlign.right),
                      ),
                    )
                    .toList(),
              ],
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
