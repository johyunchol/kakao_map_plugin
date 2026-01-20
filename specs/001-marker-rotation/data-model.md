# Data Model: Marker Rotation

**Feature**: 001-marker-rotation
**Date**: 2025-01-20

## Entity Changes

### Marker (수정)

기존 `Marker` 클래스에 `rotation` 속성 추가

```dart
class Marker {
  // 기존 속성
  final String markerId;
  LatLng latLng;
  int width = 24;
  int height = 30;
  int? offsetX;
  int? offsetY;
  MarkerIcon? icon;
  String markerImageSrc = '';
  String infoWindowContent = '';
  bool draggable;
  bool infoWindowRemovable;
  bool infoWindowFirstShow;
  int zIndex = 0;

  // 새로운 속성
  double rotation;  // 마커 회전 각도 (0-360도, 시계 방향)

  Marker({
    required this.markerId,
    required this.latLng,
    this.width = 24,
    this.height = 30,
    this.offsetX,
    this.offsetY,
    this.icon,
    this.markerImageSrc = '',
    this.infoWindowContent = '',
    this.draggable = false,
    this.infoWindowRemovable = true,
    this.infoWindowFirstShow = false,
    this.zIndex = 0,
    this.rotation = 0,  // 기본값: 0 (회전 없음)
  });
}
```

### Validation Rules

| 속성 | 타입 | 기본값 | 유효 범위 | 설명 |
|------|------|--------|----------|------|
| rotation | double | 0 | -∞ ~ +∞ | 시계 방향 회전 각도 (도 단위) |

- **음수 값**: 반시계 방향 회전으로 처리 (예: -90 = 270)
- **360 초과**: 자동으로 360으로 나눈 나머지 사용 (예: 450 = 90)
- **소수점**: 지원 (예: 45.5도)

### State Transitions

마커 회전은 상태 전이가 없는 단순 속성입니다. `setState()` 호출 시 새로운 rotation 값이 적용됩니다.

```
[마커 생성] → [rotation 적용하여 렌더링]
     ↑                    ↓
     ← [rotation 값 변경] ←
```

## JSON Serialization

### Marker.toJson() 수정

```dart
Map<String, dynamic> toJson() {
  return {
    'markerId': markerId,
    'latLng': {
      'latitude': latLng.latitude,
      'longitude': latLng.longitude,
    },
    'width': width,
    'height': height,
    'offsetX': offsetX,
    'offsetY': offsetY,
    'icon': icon,
    'markerImageSrc': markerImageSrc,
    'infoWindowContent': infoWindowContent,
    'draggable': draggable,
    'infoWindowRemovable': infoWindowRemovable,
    'infoWindowFirstShow': infoWindowFirstShow,
    'zIndex': zIndex,
    'rotation': rotation,  // 추가
  };
}
```

## JavaScript Interface

### addMarker 함수 시그니처 변경

```javascript
// 기존
function addMarker(markerId, latLng, draggable, width, height,
                   offsetX, offsetY, imageSrc, infoWindowText,
                   infoWindowRemovable, infoWindowFirstShow, zIndex, imageType)

// 변경 후
function addMarker(markerId, latLng, draggable, width, height,
                   offsetX, offsetY, imageSrc, infoWindowText,
                   infoWindowRemovable, infoWindowFirstShow, zIndex, imageType,
                   rotation)  // 추가
```

### 새로운 헬퍼 함수

```javascript
// 이미지를 회전시켜 data URL로 반환
function rotateImage(imageSrc, rotation, width, height, callback)
```
