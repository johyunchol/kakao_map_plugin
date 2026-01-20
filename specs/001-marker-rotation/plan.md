# Implementation Plan: Marker Rotation (마커 회전 기능)

**Branch**: `001-marker-rotation` | **Date**: 2025-01-20 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-marker-rotation/spec.md`

## Summary

Marker 클래스에 `rotation` 속성을 추가하여 마커 이미지를 임의의 각도로 회전시킬 수 있는 기능을 구현합니다. 카카오맵 JavaScript API의 Marker는 회전을 지원하지 않으므로, rotation 값이 설정된 경우 내부적으로 CSS `transform: rotate()`가 적용된 이미지로 렌더링합니다.

## Technical Context

**Language/Version**: Dart 2.18.4+ / Flutter 2.5.0+
**Primary Dependencies**: webview_flutter ^4.12.0, kakao_map_plugin (self)
**Storage**: N/A
**Testing**: flutter_test (visual verification in example app)
**Target Platform**: Android SDK 19+, iOS 9.0+ (via WebView)
**Project Type**: Flutter Plugin (single package + example app)
**Performance Goals**: 마커 렌더링 시 기존 대비 성능 저하 없음
**Constraints**: 카카오맵 JS API Marker 회전 미지원 → CSS transform 사용
**Scale/Scope**: 단일 속성 추가 (rotation: double)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Gate | Status | Notes |
|------|--------|-------|
| 하위 호환성 | PASS | rotation 속성 기본값 0, 기존 코드 변경 불필요 |
| 기존 기능 유지 | PASS | 클릭 이벤트, 드래그, InfoWindow 모두 유지 |
| 플랫폼 지원 | PASS | CSS transform은 Android/iOS WebView 모두 지원 |

## Project Structure

### Documentation (this feature)

```text
specs/001-marker-rotation/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
lib/
├── kakao_map_plugin.dart           # 라이브러리 진입점
└── src/
    └── basic/
        ├── marker.dart             # [수정] rotation 속성 추가
        ├── kakao_map.dart          # [수정] addMarker JS 함수 수정
        └── kakao_map_controller.dart # [수정] addMarker 호출 시 rotation 전달

example/
└── lib/
    └── src/
        └── overlay_28_marker_rotation_screen.dart  # [신규] 회전 예제 화면
```

**Structure Decision**: 기존 Flutter Plugin 구조 유지. 플러그인 본체(lib/)와 예제 앱(example/) 분리.

## Complexity Tracking

> 위반 사항 없음 - 단순 속성 추가로 기존 구조 유지
