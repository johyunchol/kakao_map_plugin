import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 마커 클러스터러에 커스텀 이미지 마커 사용하기
/// Issue #70: 클러스터링 시 커스텀 마커 이미지가 적용되지 않는 문제 테스트
class Library11MarkerClustererCustomImageScreen extends StatefulWidget {
  const Library11MarkerClustererCustomImageScreen({Key? key, this.title})
      : super(key: key);

  final String? title;

  @override
  State<Library11MarkerClustererCustomImageScreen> createState() =>
      _Library11MarkerClustererCustomImageScreenState();
}

class _Library11MarkerClustererCustomImageScreenState
    extends State<Library11MarkerClustererCustomImageScreen> {
  late KakaoMapController mapController;

  Clusterer? clusterer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: KakaoMap(
        center: LatLng(37.27943075229118, 127.01763998406159),
        onMapCreated: (controller) async {
          mapController = controller;

          // 커스텀 마커 이미지 URL (카카오맵 제공 이미지)
          const customMarkerUrl =
              'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/markerStar.png';

          // asset 이미지로 마커 아이콘 생성
          final assetIcon = await MarkerIcon.fromAsset(
            'assets/images/marker2.png',
          );

          // 네트워크 이미지로 마커 아이콘 생성
          final networkIcon = await MarkerIcon.fromNetwork(customMarkerUrl);

          Set<Marker> markers = {};

          // 1. markerImageSrc 사용 (deprecated 방식)
          markers.add(Marker(
            markerId: '${markers.length + 1}',
            latLng: LatLng(37.27943075229118, 127.01763998406159),
            width: 24,
            height: 35,
            markerImageSrc: customMarkerUrl,
          ));
          markers.add(Marker(
            markerId: '${markers.length + 1}',
            latLng: LatLng(37.27953075229118, 127.01773998406159),
            width: 24,
            height: 35,
            markerImageSrc: customMarkerUrl,
          ));

          // 2. MarkerIcon.fromNetwork 사용 (새로운 방식 - URL)
          markers.add(Marker(
            markerId: '${markers.length + 1}',
            latLng: LatLng(37.55915668706214, 126.92536526611102),
            width: 24,
            height: 35,
            icon: networkIcon,
          ));
          markers.add(Marker(
            markerId: '${markers.length + 1}',
            latLng: LatLng(37.55925668706214, 126.92546526611102),
            width: 24,
            height: 35,
            icon: networkIcon,
          ));

          // 3. MarkerIcon.fromAsset 사용 (새로운 방식 - Asset)
          markers.add(Marker(
            markerId: '${markers.length + 1}',
            latLng: LatLng(35.13854258261161, 129.1014781294671),
            width: 50,
            height: 60,
            icon: assetIcon,
          ));
          markers.add(Marker(
            markerId: '${markers.length + 1}',
            latLng: LatLng(35.13864258261161, 129.1015781294671),
            width: 50,
            height: 60,
            icon: assetIcon,
          ));

          // 4. 기본 마커 (이미지 없음)
          markers.add(Marker(
            markerId: '${markers.length + 1}',
            latLng: LatLng(35.20618517638034, 129.07944301057026),
          ));
          markers.add(Marker(
            markerId: '${markers.length + 1}',
            latLng: LatLng(35.20628517638034, 129.07954301057026),
          ));

          // 추가 마커들 (다양한 위치에 커스텀 이미지로)
          markers.add(Marker(
            markerId: '${markers.length + 1}',
            latLng: LatLng(37.561110808242056, 126.9831268386891),
            width: 24,
            height: 35,
            markerImageSrc: customMarkerUrl,
          ));
          markers.add(Marker(
            markerId: '${markers.length + 1}',
            latLng: LatLng(37.86187129655063, 127.7410250820423),
            width: 24,
            height: 35,
            icon: networkIcon,
          ));
          markers.add(Marker(
            markerId: '${markers.length + 1}',
            latLng: LatLng(33.51133264696746, 126.51852347452322),
            width: 50,
            height: 60,
            icon: assetIcon,
          ));

          clusterer = Clusterer(
            markers: markers.toList(),
            minLevel: 10,
            averageCenter: true,
          );

          setState(() {});
        },
        currentLevel: 14,
        clusterer: clusterer,
        onMarkerTap: (markerId, latLng, zoomLevel) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Marker tapped: $markerId'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }
}
