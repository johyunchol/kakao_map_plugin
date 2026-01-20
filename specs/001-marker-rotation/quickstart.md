# Quickstart: Marker Rotation

**Feature**: 001-marker-rotation
**Date**: 2025-01-20

## 기본 사용법

### 마커에 회전 적용하기

```dart
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

// 90도 회전된 마커 (동쪽 방향)
Marker(
  markerId: 'car_1',
  latLng: LatLng(37.5665, 126.9780),
  rotation: 90,  // 시계 방향 90도
)

// 45도 회전 (북동쪽 방향)
Marker(
  markerId: 'car_2',
  latLng: LatLng(37.5700, 126.9820),
  rotation: 45,
)

// 회전 없음 (기본값, 기존 코드와 동일)
Marker(
  markerId: 'car_3',
  latLng: LatLng(37.5630, 126.9750),
  // rotation 생략 시 기본값 0
)
```

### 커스텀 이미지와 함께 사용

```dart
// asset 이미지 + 회전
markers.add(Marker(
  markerId: 'vehicle_1',
  latLng: LatLng(37.5665, 126.9780),
  width: 40,
  height: 40,
  rotation: 120,  // 120도 회전
  icon: await MarkerIcon.fromAsset('assets/images/car.png'),
));

// 네트워크 이미지 + 회전
markers.add(Marker(
  markerId: 'vehicle_2',
  latLng: LatLng(37.5700, 126.9820),
  width: 50,
  height: 50,
  rotation: 270,  // 서쪽 방향
  icon: await MarkerIcon.fromNetwork('https://example.com/arrow.png'),
));
```

### 동적 회전 업데이트

```dart
class _MyMapScreenState extends State<MyMapScreen> {
  late KakaoMapController mapController;
  Set<Marker> markers = {};
  double currentRotation = 0;

  void updateMarkerRotation(double newRotation) {
    markers = markers.map((marker) {
      if (marker.markerId == 'tracked_vehicle') {
        return Marker(
          markerId: marker.markerId,
          latLng: marker.latLng,
          width: marker.width,
          height: marker.height,
          rotation: newRotation,  // 새로운 회전 값
          icon: marker.icon,
        );
      }
      return marker;
    }).toSet();

    // WebView에 마커 업데이트 반영 (필수!)
    mapController.addMarker(markers: markers.toList());

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return KakaoMap(
      onMapCreated: (controller) {
        mapController = controller;
        // 초기 마커 설정...
      },
      markers: markers.toList(),
      center: LatLng(37.5665, 126.9780),
    );
  }
}
```

## 각도 참조표

| 각도 | 방향 | 설명 |
|------|------|------|
| 0 | 북 (↑) | 기본값, 회전 없음 |
| 45 | 북동 (↗) | |
| 90 | 동 (→) | |
| 135 | 남동 (↘) | |
| 180 | 남 (↓) | |
| 225 | 남서 (↙) | |
| 270 | 서 (←) | |
| 315 | 북서 (↖) | |

## 주의사항

1. **정사각형 이미지 권장**: 회전 시 이미지가 잘리지 않도록 정사각형 이미지 사용 권장
2. **width/height 동일 설정**: 회전 시 왜곡 방지를 위해 width와 height를 동일하게 설정
3. **성능**: rotation 값이 0이면 회전 처리를 건너뛰므로 기존과 동일한 성능

## 예제 화면

예제 앱의 `overlay_28_marker_rotation_screen.dart`에서 다양한 회전 각도를 테스트할 수 있습니다.
