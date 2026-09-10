import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 앱 스타일 인포윈도우 (플러그인 추가 기능)
///
/// `InfoWindowStyle` 을 지정하면 카카오 SDK 기본 인포윈도우 대신 앱 느낌의
/// 말풍선을 그립니다. 마커별로 지정하거나 `KakaoMapTheme` 으로 지도 전체 기본값을
/// 둘 수 있습니다. 마커를 탭하면 열립니다.
class Overlay28StyledInfoWindowScreen extends StatefulWidget {
  const Overlay28StyledInfoWindowScreen({Key? key, this.title})
      : super(key: key);

  final String? title;

  @override
  State<Overlay28StyledInfoWindowScreen> createState() =>
      _Overlay28StyledInfoWindowScreenState();
}

class _Overlay28StyledInfoWindowScreenState
    extends State<Overlay28StyledInfoWindowScreen> {
  String selected = 'material';

  static const _styles = <String, InfoWindowStyle?>{
    'sdk': null,
    'material': InfoWindowStyle.material(),
    'cupertino': InfoWindowStyle.cupertino(),
    'dark': InfoWindowStyle.dark(),
  };

  List<Marker> _markers() {
    final style = _styles[selected];
    return [
      Marker(
        markerId: 'cityhall',
        latLng: LatLng(37.566826, 126.9786567),
        infoWindowContent: '<b>서울시청</b><br>'
            '<span style="opacity:.7">서울 중구 세종대로 110</span>',
        infoWindowFirstShow: true,
        infoWindowStyle: style,
      ),
      Marker(
        markerId: 'plaza',
        latLng: LatLng(37.5655, 126.9769),
        infoWindowContent: '서울광장 · 탭해서 열기',
        infoWindowStyle: style,
      ),
      Marker(
        markerId: 'deoksugung',
        latLng: LatLng(37.5658, 126.9751),
        infoWindowContent: '<b>덕수궁</b><br>닫기 버튼 없음',
        infoWindowRemovable: false,
        infoWindowStyle: style,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? selectedTitle)),
      body: Column(
        children: [
          Expanded(
            child: KakaoMap(
              center: LatLng(37.566, 126.977),
              currentLevel: 4,
              markers: _markers(),
              // 마커를 탭하면 인포윈도우가 열립니다. 콜백이 있어야 탭 이벤트가 등록됩니다.
              onMarkerTap: (markerId, latLng, zoomLevel) {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'sdk', label: Text('SDK 기본')),
                    ButtonSegment(value: 'material', label: Text('Material')),
                    ButtonSegment(value: 'cupertino', label: Text('Cupertino')),
                    ButtonSegment(value: 'dark', label: Text('Dark')),
                  ],
                  selected: {selected},
                  onSelectionChanged: (values) =>
                      setState(() => selected = values.first),
                ),
                const SizedBox(height: 8),
                const Text(
                  'InfoWindowStyle 을 바꾸면 같은 마커의 인포윈도우 모양이 바뀝니다. '
                  'KakaoMapTheme(infoWindowStyle:) 로 지도 전체 기본값도 지정할 수 있습니다.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
