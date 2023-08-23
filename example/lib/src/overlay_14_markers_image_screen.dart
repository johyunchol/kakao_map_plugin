import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

enum ButtonType {
  coffee,
  store,
  carpark,
}

/// 다양한 이미지 마커 표시하기
/// https://apis.map.kakao.com/web/sample/categoryMarker/
class Overlay14MarkersImage2Screen extends StatefulWidget {
  const Overlay14MarkersImage2Screen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Overlay14MarkersImage2Screen> createState() =>
      _Overlay14MarkersImage2ScreenState();
}

class _Overlay14MarkersImage2ScreenState
    extends State<Overlay14MarkersImage2Screen> {
  late KakaoMapController mapController;

  Set<Marker> markers = {};
  ButtonType buttonType = ButtonType.coffee;

  @override
  void initState() {
    super.initState();
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
            onMapCreated: ((controller) async {
              mapController = controller;

              setState(() {});
            }),
            markers: markers.toList(),
            center: LatLng(37.498004414546934, 127.02770621963765),
          ),
          Row(
            children: [
              MaterialButton(
                onPressed: () {
                  markers.add(Marker(
                      markerId: markers.length.toString(),
                      latLng: LatLng(37.499590490909185, 127.0263723554437)));
                  markers.add(Marker(
                      markerId: markers.length.toString(),
                      latLng: LatLng(37.499427948430814, 127.02794423197847)));
                  markers.add(Marker(
                      markerId: markers.length.toString(),
                      latLng: LatLng(37.498553760499505, 127.02882598822454)));
                  markers.add(Marker(
                      markerId: markers.length.toString(),
                      latLng: LatLng(37.497625593121384, 127.02935713582038)));
                  markers.add(Marker(
                      markerId: markers.length.toString(),
                      latLng: LatLng(37.49646391248451, 127.02675574250912)));
                  markers.add(Marker(
                      markerId: markers.length.toString(),
                      latLng: LatLng(37.49629291770947, 127.02587362608637)));
                  markers.add(Marker(
                      markerId: markers.length.toString(),
                      latLng: LatLng(37.49754540521486, 127.02546694890695)));

                  buttonType = ButtonType.coffee;
                  setState(() {});

                  mapController
                      .setCenter(LatLng(37.499590490909185, 127.0263723554437));
                },
                color:
                    buttonType == ButtonType.coffee ? Colors.blue : Colors.grey,
                child: const Text('커피숍'),
              ),
              MaterialButton(
                onPressed: () {
                  markers.add(Marker(
                      markerId: markers.length.toString(),
                      latLng: LatLng(37.497535461505684, 127.02948149502778)));
                  markers.add(Marker(
                      markerId: markers.length.toString(),
                      latLng: LatLng(37.49671536281186, 127.03020491448352)));
                  markers.add(Marker(
                      markerId: markers.length.toString(),
                      latLng: LatLng(37.496201943633714, 127.02959405469642)));
                  markers.add(Marker(
                      markerId: markers.length.toString(),
                      latLng: LatLng(37.49640072567703, 127.02726459882308)));
                  markers.add(Marker(
                      markerId: markers.length.toString(),
                      latLng: LatLng(37.49640098874988, 127.02609983175294)));
                  markers.add(Marker(
                      markerId: markers.length.toString(),
                      latLng: LatLng(37.49932849491523, 127.02935780247945)));
                  markers.add(Marker(
                      markerId: markers.length.toString(),
                      latLng: LatLng(37.49996818951873, 127.02943721562295)));

                  buttonType = ButtonType.store;
                  setState(() {});

                  mapController.setCenter(
                      LatLng(37.497535461505684, 127.02948149502778));
                },
                color:
                    buttonType == ButtonType.store ? Colors.blue : Colors.grey,
                child: const Text('편의점'),
              ),
              MaterialButton(
                onPressed: () {
                  markers.add(Marker(
                      markerId: markers.length.toString(),
                      latLng: LatLng(37.49966168796031, 127.03007039430118)));
                  markers.add(Marker(
                      markerId: markers.length.toString(),
                      latLng: LatLng(37.499463762912974, 127.0288828824399)));
                  markers.add(Marker(
                      markerId: markers.length.toString(),
                      latLng: LatLng(37.49896834100913, 127.02833986892401)));
                  markers.add(Marker(
                      markerId: markers.length.toString(),
                      latLng: LatLng(37.49893267508434, 127.02673400572665)));
                  markers.add(Marker(
                      markerId: markers.length.toString(),
                      latLng: LatLng(37.49872543597439, 127.02676785815386)));
                  markers.add(Marker(
                      markerId: markers.length.toString(),
                      latLng: LatLng(37.49813096097184, 127.02591949495914)));
                  markers.add(Marker(
                      markerId: markers.length.toString(),
                      latLng: LatLng(37.497680616783086, 127.02518427952202)));

                  buttonType = ButtonType.carpark;
                  setState(() {});

                  mapController
                      .setCenter(LatLng(37.49966168796031, 127.03007039430118));
                },
                color: buttonType == ButtonType.carpark
                    ? Colors.blue
                    : Colors.grey,
                child: const Text('주차장'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
