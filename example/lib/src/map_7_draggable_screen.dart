import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 지도 이동 막기
/// https://apis.map.kakao.com/web/sample/disableMapDragMove/
class Map7DraggableScreen extends StatefulWidget {
  const Map7DraggableScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Map7DraggableScreen> createState() => _Map7DraggableScreenState();
}

class _Map7DraggableScreenState extends State<Map7DraggableScreen> {
  late KakaoMapController mapController;

  bool isDraggable = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: Stack(
        children: [
          KakaoMap(onMapCreated: ((controller) async {
            mapController = controller;
          })),
          Row(
            children: [
              MaterialButton(
                onPressed: () async {
                  isDraggable = !isDraggable;

                  await mapController.setDraggable(isDraggable);
                  setState(() {});
                },
                color: isDraggable ? Colors.blue : Colors.grey,
                child: const Text('draggable'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
