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

/// 지도 영역 크기 동적 변경하기
/// https://apis.map.kakao.com/web/sample/mapRelayout/
class Map15RelayoutScreen extends StatefulWidget {
  const Map15RelayoutScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Map15RelayoutScreen> createState() => _Map15RelayoutScreenState();
}

class _Map15RelayoutScreenState extends State<Map15RelayoutScreen> {
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

  double height = 200;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: height,
                child: KakaoMap(
                  onMapCreated: ((controller) {
                    mapController = controller;
                  }),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                color: Colors.white,
                child: const Text(
                    '웹에서는 width, height가 변경되면 relayout 호출하여 다시 렌더해야 하지 flutter 에서는 setState를 통해 rebuild 해주면 됩니다.'),
              )
            ],
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
                      height = 300;
                    },
                    color: Colors.white,
                    child: const Text("지도 크기 바꾸기"),
                  ),
                  const SizedBox(width: 8),
                  MaterialButton(
                    onPressed: () {
                      setState(() {});
                    },
                    color: Colors.white,
                    child: const Text("relayout 호출하기"),
                  )
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
