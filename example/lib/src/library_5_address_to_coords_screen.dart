import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 주소로 장소 표시하기
/// https://apis.map.kakao.com/web/sample/addr2coord/
class Library5AddressToCoordsScreen extends StatefulWidget {
  const Library5AddressToCoordsScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Library5AddressToCoordsScreen> createState() =>
      _Library5AddressToCoordsScreenState();
}

class _Library5AddressToCoordsScreenState
    extends State<Library5AddressToCoordsScreen> {
  late KakaoMapController mapController;
  late TextEditingController textEditingController;

  bool draggable = true;
  bool zoomable = true;
  String address = '';
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();

    textEditingController = TextEditingController(text: '제주특별자치도 제주시 첨단로 242');
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
                      markers.clear();

                      final text = textEditingController.value.text;

                      final request = AddressSearchRequest(
                        addr: text,
                        analyzeType: AnalyzeType.exact,
                      );
                      final result = await mapController.addressSearch(request);

                      setState(() {
                        address = result.toString();
                      });

                      if (result.list.isEmpty) return;

                      List<LatLng> bounds = [];
                      for (var item in result.list) {
                        LatLng latLng = LatLng(double.parse(item.y ?? ''),
                            double.parse(item.x ?? ''));

                        bounds.add(latLng);

                        Marker marker = Marker(
                            markerId: item.id ?? UniqueKey().toString(),
                            latLng: latLng,
                            infoWindowContent: '<div>${item.addressName}</div>',
                            infoWindowFirstShow: true);

                        markers.add(marker);
                      }

                      await mapController.fitBounds(bounds);
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
