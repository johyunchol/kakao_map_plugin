import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// Issue #69 Test Screen
/// iOS에서 Stack 위 위젯의 gesture가 지도에 전달되는 문제 테스트
///
/// 테스트 방법:
/// 1. 하단 ScrollView를 스크롤해봅니다
/// 2. iOS에서 ScrollView 스크롤 시 아래 지도도 함께 이동하면 버그
/// 3. ScrollView만 스크롤되고 지도는 움직이지 않아야 정상
class Issue69GestureTestScreen extends StatefulWidget {
  const Issue69GestureTestScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Issue69GestureTestScreen> createState() =>
      _Issue69GestureTestScreenState();
}

class _Issue69GestureTestScreenState extends State<Issue69GestureTestScreen> {
  late KakaoMapController mapController;
  String logMessage = '';

  void addLog(String message) {
    setState(() {
      logMessage = '$message\n$logMessage';
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
          // Background: KakaoMap
          KakaoMap(
            onMapCreated: (controller) {
              setState(() {
                mapController = controller;
              });
              addLog('Map created');
            },
            onMapTap: (latLng) {
              addLog('Map tapped: ${latLng.latitude}, ${latLng.longitude}');
            },
            onDragChangeCallback: (latLng, zoomLevel, dragType) {
              addLog('Map drag: $dragType');
            },
          ),
          // Foreground: ScrollView overlay on bottom half
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.of(context).size.height * 0.4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(242),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(51),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Issue #69 Test: ScrollView over KakaoMap',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Scroll this list. On iOS, the map should NOT move when scrolling here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  // ScrollView
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollStartNotification) {
                          addLog('ScrollView: scroll started');
                        }
                        return false;
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: 30,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text('${index + 1}'),
                              ),
                              title: Text('List Item ${index + 1}'),
                              subtitle:
                                  const Text('Scroll this item to test gesture'),
                              onTap: () {
                                addLog('Tapped item ${index + 1}');
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Log panel at top
          Positioned(
            left: 8,
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(maxHeight: 100),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(178),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  logMessage.isEmpty ? 'Logs will appear here...' : logMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}
