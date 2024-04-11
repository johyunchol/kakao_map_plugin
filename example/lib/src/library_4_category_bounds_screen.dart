import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 카테고리별 장소 검색하기
/// https://apis.map.kakao.com/web/sample/categoryFromBounds/
class Library4CategoryBoundsScreen extends StatefulWidget {
  const Library4CategoryBoundsScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Library4CategoryBoundsScreen> createState() =>
      _Library4CategoryBoundsScreenState();
}

class _Library4CategoryBoundsScreenState
    extends State<Library4CategoryBoundsScreen> {
  late KakaoMapController mapController;

  bool draggable = true;
  bool zoomable = true;
  Set<Marker> markers = {};
  List<KeywordAddress> list = [];

  Widget _categoryWidget({
    required IconData icon,
    required String text,
    GestureTapCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            Text(text),
          ],
        ),
      ),
    );
  }

  callRequest(CategoryType categoryType) async {
    markers.clear();
    list.clear();

    final center = await mapController.getCenter();

    final request = CategorySearchRequest(
      y: center.latitude,
      x: center.longitude,
      radius: 1000,
      sort: SortBy.distance,
      categoryGroupCode: categoryType,
    );

    final response = await mapController.categorySearch(request);

    List<LatLng> bounds = [];
    for (var item in response.list) {
      LatLng latLng =
          LatLng(double.parse(item.y ?? ''), double.parse(item.x ?? ''));

      bounds.add(latLng);

      Marker marker =
          Marker(markerId: item.id ?? UniqueKey().toString(), latLng: latLng);

      markers.add(marker);
    }

    mapController.fitBounds(bounds);

    setState(() {
      list.addAll(response.list);
    });
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
            center: LatLng(37.566826, 126.9786567),
            currentLevel: 3,
            onMapCreated: (controller) {
              mapController = controller;
            },
            markers: markers.toList(),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            margin: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _categoryWidget(
                  icon: Icons.account_balance,
                  text: '은행',
                  onTap: () => callRequest(CategoryType.bk9),
                ),
                _categoryWidget(
                  icon: Icons.add_business,
                  text: '마트',
                  onTap: () => callRequest(CategoryType.mt1),
                ),
                _categoryWidget(
                  icon: Icons.masks,
                  text: '약국',
                  onTap: () => callRequest(CategoryType.pm9),
                ),
                _categoryWidget(
                  icon: Icons.oil_barrel,
                  text: '주유소',
                  onTap: () => callRequest(CategoryType.ol7),
                ),
                _categoryWidget(
                  icon: Icons.coffee,
                  text: '카페',
                  onTap: () => callRequest(CategoryType.ce7),
                ),
                _categoryWidget(
                  icon: Icons.store,
                  text: '편의점',
                  onTap: () => callRequest(CategoryType.cs2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
