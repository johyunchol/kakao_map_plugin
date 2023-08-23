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

/// 지도 타입 바꾸기2
/// https://apis.map.kakao.com/web/sample/changeOverlay2/
class Map13MapTypeCheckScreen extends StatefulWidget {
  const Map13MapTypeCheckScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Map13MapTypeCheckScreen> createState() =>
      _Map13MapTypeCheckScreenState();
}

class _Map13MapTypeCheckScreenState extends State<Map13MapTypeCheckScreen> {
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
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ...overlayList
                    .map(
                      (selectedItem) => MaterialButton(
                        onPressed: () {
                          for (var element in overlayList) {
                            if (element.mapType == selectedItem.mapType) {
                              element.isChecked = !element.isChecked;
                            }
                          }

                          selectedItem.isChecked
                              ? mapController
                                  .addOverlayMapTypeId(selectedItem.mapType)
                              : mapController
                                  .removeOverlayMapTypeId(selectedItem.mapType);

                          setState(() {});
                          // setChecked(item);
                        },
                        color:
                            selectedItem.isChecked ? Colors.blue : Colors.grey,
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
