# Research: Marker Rotation Implementation

**Feature**: 001-marker-rotation
**Date**: 2025-01-20

## Research Questions

### Q1: CSS transform rotate이 WebView에서 정상 동작하는가?

**Decision**: CSS transform: rotate()는 Android WebView와 iOS WKWebView 모두에서 완벽하게 지원됨

**Rationale**:
- CSS Transforms (Level 1)은 모든 주요 브라우저에서 지원
- Android WebView는 Chrome 엔진 기반으로 CSS3 완벽 지원
- iOS WKWebView는 Safari 엔진 기반으로 CSS3 완벽 지원
- 현재 플러그인의 webview_flutter ^4.12.0은 최신 WebView 사용

**Alternatives considered**:
- Canvas 기반 이미지 회전: 복잡하고 성능 저하 우려
- SVG transform: 이미지 포맷 제한
- 서버 사이드 이미지 회전: 네트워크 지연, 복잡도 증가

### Q2: 회전 적용 시 마커 이벤트(클릭, 드래그)가 정상 동작하는가?

**Decision**: CSS transform은 요소의 시각적 표현만 변경하므로 이벤트는 정상 동작

**Rationale**:
- CSS transform은 레이아웃에 영향을 주지 않음 (paint only)
- 이벤트 핸들러는 변환된 좌표 기준으로 동작
- 기존 kakao.maps.Marker 또는 kakao.maps.CustomOverlay의 이벤트 시스템 활용

**Alternatives considered**:
- 별도 투명 클릭 영역 생성: 불필요한 복잡도

### Q3: 구현 방식 - Marker 이미지에 CSS 적용 vs CustomOverlay 사용

**Decision**: 기존 Marker의 이미지에 CSS transform 직접 적용 (MarkerImage 생성 시)

**Rationale**:
- 기존 코드 변경 최소화
- Marker의 모든 기능(드래그, InfoWindow, 이벤트) 유지
- CustomOverlay 방식은 Marker 기능 재구현 필요

**Implementation approach**:
```javascript
// kakao_map.dart의 addMarker 함수 내
if (rotation && rotation !== 0) {
    // 이미지를 회전시킨 후 MarkerImage로 설정
    // 방법 1: img 태그에 CSS transform 적용 후 Canvas로 변환
    // 방법 2: CSS filter + data URL 조합
}
```

**실제 구현 방식**:
JavaScript에서 Canvas를 사용하여 이미지를 회전시킨 후 data URL로 변환하여 MarkerImage에 적용

```javascript
function rotateImage(imageSrc, rotation, width, height, callback) {
    const img = new Image();
    img.onload = function() {
        const canvas = document.createElement('canvas');
        const ctx = canvas.getContext('2d');

        // 회전 시 이미지가 잘리지 않도록 캔버스 크기 조정
        const maxSize = Math.max(width, height) * Math.sqrt(2);
        canvas.width = maxSize;
        canvas.height = maxSize;

        ctx.translate(maxSize/2, maxSize/2);
        ctx.rotate(rotation * Math.PI / 180);
        ctx.drawImage(img, -width/2, -height/2, width, height);

        callback(canvas.toDataURL());
    };
    img.src = imageSrc;
}
```

### Q4: 회전 중심점 (transform-origin) 설정

**Decision**: 이미지 중앙을 기준으로 회전 (transform-origin: center)

**Rationale**:
- 차량/화살표 등 방향성 아이콘은 중앙 회전이 자연스러움
- offset 속성으로 앵커 포인트 별도 조정 가능
- 대부분의 지도 라이브러리가 중앙 회전 사용

**Alternatives considered**:
- 하단 중앙 기준 회전: 핀 형태 마커에 적합하나 범용성 낮음
- 사용자 지정 회전 중심점: 복잡도 증가, 향후 확장으로 고려

## Technical Decisions Summary

| 항목 | 결정 | 이유 |
|------|------|------|
| 회전 방식 | Canvas 이미지 회전 후 MarkerImage 적용 | 기존 Marker 기능 유지 |
| 회전 중심점 | 이미지 중앙 | 방향성 아이콘에 자연스러움 |
| 각도 단위 | 도(degree), 시계 방향 양수 | 일반적인 지도 라이브러리 관례 |
| 기본값 | 0 (회전 없음) | 하위 호환성 보장 |

## References

- [kakao_map_plugin | Flutter package](https://pub.dev/packages/kakao_map_plugin)
- [Google Maps Advanced Markers Animation](https://developers.google.com/maps/documentation/javascript/examples/advanced-markers-animation)
- [CSS Transforms Level 1 Specification](https://www.w3.org/TR/css-transforms-1/)
