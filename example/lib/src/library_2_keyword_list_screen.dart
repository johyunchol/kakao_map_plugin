import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 키워드로 장소검색하고 목록으로 표출하기
/// https://apis.map.kakao.com/web/sample/keywordList/
class Library2KeywordListScreen extends StatefulWidget {
  const Library2KeywordListScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Library2KeywordListScreen> createState() =>
      _Library2KeywordListScreenState();
}

class _Library2KeywordListScreenState extends State<Library2KeywordListScreen> {
  late KakaoMapController mapController;
  late TextEditingController textEditingController;

  int page = 1;
  bool draggable = true;
  bool zoomable = true;
  Set<Marker> markers = {};
  List<KeywordAddress> list = [];

  @override
  void initState() {
    super.initState();

    textEditingController = TextEditingController(text: '맛집');
  }

  void search() async {
    final text = textEditingController.value.text;

    final center = await mapController.getCenter();

    final result = await mapController.keywordSearch(
      KeywordSearchRequest(
        keyword: text,
        y: center.latitude,
        x: center.longitude,
        radius: 1000,
        sort: SortBy.distance,
        page: page,
      ),
    );

    List<LatLng> bounds = [];
    for (var item in result.list) {
      LatLng latLng =
          LatLng(double.parse(item.y ?? ''), double.parse(item.x ?? ''));

      bounds.add(latLng);

      Marker marker =
          Marker(markerId: item.id ?? UniqueKey().toString(), latLng: latLng);

      markers.add(marker);
    }

    mapController.fitBounds(bounds);

    setState(() {
      list.addAll(result.list);
    });
  }

  Widget listItem({
    required int index,
    required String name,
    required String addressRoad,
    required String address,
    required String tel,
    required String distance,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipOval(
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(addressRoad),
                Text(address),
                Text(tel),
                Text('${distance}m'),
              ],
            )
          ],
        ),
      ),
    );
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
            child: KakaoMap(
              center: LatLng(37.4944992, 127.0252582),
              onMapCreated: ((controller) async {
                mapController = controller;
              }),
              markers: markers.toList(),
            ),
          ),
          Column(
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      ElevatedButton(
                        child: const Text('1'),
                        onPressed: () {
                          setState(() {
                            markers.clear();
                            list.clear();

                            page = 1;
                          });

                          search();
                        },
                      ),
                      ElevatedButton(
                        child: const Text('2'),
                        onPressed: () {
                          setState(() {
                            markers.clear();
                            list.clear();

                            page = 2;
                          });
                          search();
                        },
                      ),
                      ElevatedButton(
                        child: const Text('3'),
                        onPressed: () {
                          setState(() {
                            markers.clear();
                            list.clear();

                            page = 3;
                          });
                          search();
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 110,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: list
                          .map(
                            (e) => listItem(
                              index: list.indexOf(e),
                              name: e.placeName ?? '',
                              addressRoad: e.roadAddressName ?? '',
                              address: e.addressName ?? '',
                              tel: e.phone ?? '',
                              distance: e.distance ?? '',
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textEditingController,
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: search,
                    child: const Text('검색'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
