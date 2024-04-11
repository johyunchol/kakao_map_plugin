import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 카테고리로 장소 검색하기
/// https://apis.map.kakao.com/web/sample/categoryBasic/
class Library3CategoryScreen extends StatefulWidget {
  const Library3CategoryScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Library3CategoryScreen> createState() => _Library3CategoryScreenState();
}

class _Library3CategoryScreenState extends State<Library3CategoryScreen> {
  late KakaoMapController mapController;

  bool draggable = true;
  bool zoomable = true;
  Set<Marker> markers = {};
  List<KeywordAddress> list = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: KakaoMap(
        center: LatLng(37.566826, 126.9786567),
        currentLevel: 3,
        onMapCreated: (controller) async {
          mapController = controller;

          final center = await mapController.getCenter();

          final request = CategorySearchRequest(
            categoryGroupCode: CategoryType.bk9,
            y: center.latitude,
            x: center.longitude,
            radius: 1000,
            sort: SortBy.distance,
            page: 1,
            size: 5,
            useMapCenter: true,
            useMapBounds: true,
          );

          final result = await mapController.categorySearch(request);

          List<LatLng> bounds = [];
          for (var item in result.list) {
            LatLng latLng =
                LatLng(double.parse(item.y ?? ''), double.parse(item.x ?? ''));

            bounds.add(latLng);

            Marker marker = Marker(
                markerId: item.id ?? UniqueKey().toString(), latLng: latLng);

            markers.add(marker);
          }

          mapController.fitBounds(bounds);

          setState(() {
            list.addAll(result.list);
          });

          debugPrint('***** [JHC_DEBUG] ${result.toString()}');
        },
        markers: markers.toList(),
      ),
    );
  }
}
