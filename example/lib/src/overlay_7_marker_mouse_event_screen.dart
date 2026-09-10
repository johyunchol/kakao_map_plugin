import 'package:flutter/material.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 마커에 마우스 이벤트 등록하기
/// https://apis.map.kakao.com/web/sample/addMarkerMouseEvent/
class Overlay7MarkerMouseEventScreen extends StatefulWidget {
  const Overlay7MarkerMouseEventScreen({Key? key, this.title})
      : super(key: key);

  final String? title;

  @override
  State<Overlay7MarkerMouseEventScreen> createState() =>
      _Overlay7MarkerMouseEventScreenState();
}

class _Overlay7MarkerMouseEventScreenState
    extends State<Overlay7MarkerMouseEventScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Icon(
                Icons.mouse_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                '이 예제는 모바일에서 지원하지 않습니다',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'mouseover / mouseout 은 마우스 포인터가 특정 위치 위에 "머무르는"\n'
                '상태를 감지하는 이벤트입니다. 터치스크린으로 조작하는 안드로이드/iOS\n'
                '기기에는 포인터가 화면 위에 계속 머물러 있는다는 개념 자체가 없기\n'
                '때문에, 이 이벤트는 모바일 웹뷰에서 동작하지 않습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '모바일에서 비슷한 목적을 달성하려면',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• onMarkerTap 으로 탭 이벤트를 받아 인포윈도우를 열어보세요\n'
                      '• 또는 마커를 탭했을 때 이미지를 다른 이미지로 교체해\n'
                      '  선택 상태를 시각적으로 표현해보세요',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                '관련 예제',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Text(
                '• 마커에 클릭 이벤트 등록하기\n'
                '• 여러개 마커에 이벤트 등록하기2',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
