import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 키워드로 장소검색하기
/// https://apis.map.kakao.com/web/sample/keywordBasic/
class Library1KeywordScreen extends StatefulWidget {
  const Library1KeywordScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Library1KeywordScreen> createState() => _Library1KeywordScreenState();
}

class _Library1KeywordScreenState extends State<Library1KeywordScreen> {
  late KakaoMapController mapController;
  late TextEditingController textEditingController;

  bool draggable = true;
  bool zoomable = true;
  String address = '';
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();

    textEditingController = TextEditingController(text: '맛집');
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
              SizedBox(
                height: 100,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(4),
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SingleChildScrollView(child: Text(address)),
                ),
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
                    onPressed: () async {
                      final text = textEditingController.value.text;

                      final center = await mapController.getCenter();

                      final result = await mapController.keywordSearch(
                        KeywordSearchRequest(
                          keyword: text,
                          y: center.latitude,
                          x: center.longitude,
                          radius: 1000,
                          sort: SortBy.distance,
                        ),
                      );

                      List<LatLng> bounds = [];
                      for (var item in result.list) {
                        LatLng latLng = LatLng(double.parse(item.y ?? ''),
                            double.parse(item.x ?? ''));

                        bounds.add(latLng);

                        Marker marker = Marker(
                            markerId: item.id ?? UniqueKey().toString(),
                            latLng: latLng,
                            infoWindowContent: '<div>${item.placeName}</div>',
                            infoWindowFirstShow: true);

                        markers.add(marker);
                      }

                      mapController.fitBounds(bounds);

                      setState(() {
                        address = result.toString();
                      });
                    },
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
