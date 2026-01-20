# Feature Specification: Marker Rotation (마커 회전 기능)

**Feature Branch**: `001-marker-rotation`
**Created**: 2025-01-20
**Status**: Draft
**Input**: User description: "Marker에 rotation 속성을 추가하여 마커 이미지 회전 기능 구현 (방법 2 형식)"

## 배경

카카오맵 JavaScript API의 Marker 객체는 회전 기능을 지원하지 않습니다. 그러나 CustomOverlay에 CSS `transform: rotate()`를 적용하면 회전이 가능합니다. 이 기능은 Marker 클래스에 `rotation` 속성을 추가하고, 내부적으로 CSS transform을 적용하여 사용자에게 간편한 API를 제공합니다.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 기본 마커 회전 (Priority: P1)

개발자가 차량 추적 앱을 만들 때, 차량의 이동 방향에 맞게 마커 아이콘이 회전하여 표시되어야 합니다. 개발자는 Marker 생성 시 `rotation` 속성에 각도 값(0-360)을 지정하여 마커를 원하는 방향으로 회전시킬 수 있습니다.

**Why this priority**: 마커 회전의 핵심 기능으로, 이 기능만으로도 차량/드론/배송 추적 등 다양한 앱에서 즉시 활용 가능합니다.

**Independent Test**: 예제 앱에서 rotation 값이 다른 여러 마커를 지도에 표시하고, 각 마커가 지정된 각도로 회전되어 보이는지 시각적으로 확인할 수 있습니다.

**Acceptance Scenarios**:

1. **Given** 개발자가 `rotation: 0`으로 마커를 생성할 때, **When** 지도에 마커가 표시되면, **Then** 마커 이미지가 원본 그대로(북쪽/위쪽 방향) 표시됩니다.
2. **Given** 개발자가 `rotation: 90`으로 마커를 생성할 때, **When** 지도에 마커가 표시되면, **Then** 마커 이미지가 시계 방향으로 90도 회전(동쪽 방향)하여 표시됩니다.
3. **Given** 개발자가 `rotation: 45`로 마커를 생성할 때, **When** 지도에 마커가 표시되면, **Then** 마커 이미지가 시계 방향으로 45도 회전(북동쪽 방향)하여 표시됩니다.
4. **Given** 개발자가 `rotation` 속성을 지정하지 않을 때, **When** 지도에 마커가 표시되면, **Then** 마커 이미지가 회전 없이 원본 그대로 표시됩니다(기본값 0).

---

### User Story 2 - 동적 마커 회전 업데이트 (Priority: P2)

개발자가 실시간으로 이동하는 차량의 방향이 바뀔 때, 마커의 회전 각도를 동적으로 업데이트하여 현재 이동 방향을 반영할 수 있어야 합니다.

**Why this priority**: 실시간 추적 앱에서 필수적인 기능이지만, 기본 회전 기능이 먼저 구현되어야 합니다.

**Independent Test**: 버튼 클릭 시 마커의 rotation 값을 변경하고 지도를 다시 그려서 회전이 업데이트되는지 확인할 수 있습니다.

**Acceptance Scenarios**:

1. **Given** rotation 90으로 표시된 마커가 있을 때, **When** 개발자가 해당 마커의 rotation을 180으로 변경하고 setState를 호출하면, **Then** 마커가 180도 방향으로 회전하여 다시 표시됩니다.

---

### User Story 3 - 커스텀 이미지와 함께 회전 (Priority: P1)

개발자가 커스텀 마커 이미지(예: 자동차, 화살표, 드론 아이콘)를 사용하면서 동시에 회전 기능을 적용할 수 있어야 합니다.

**Why this priority**: 기본 마커보다 커스텀 이미지 사용 시 회전 기능이 더 의미 있으므로 P1과 함께 구현되어야 합니다.

**Independent Test**: asset 이미지 또는 네트워크 이미지를 사용하는 마커에 rotation을 적용하고, 이미지가 정상적으로 회전되어 표시되는지 확인합니다.

**Acceptance Scenarios**:

1. **Given** 개발자가 `MarkerIcon.fromAsset()`으로 커스텀 이미지를 설정하고 `rotation: 120`으로 마커를 생성할 때, **When** 지도에 마커가 표시되면, **Then** 커스텀 이미지가 120도 회전하여 표시됩니다.
2. **Given** 개발자가 `MarkerIcon.fromNetwork()`으로 네트워크 이미지를 설정하고 `rotation: 270`으로 마커를 생성할 때, **When** 지도에 마커가 표시되면, **Then** 네트워크 이미지가 270도 회전하여 표시됩니다.

---

### Edge Cases

- **360도 이상의 값**: rotation 값이 360 이상일 경우 360으로 나눈 나머지 값으로 처리 (예: 450 → 90)
- **음수 값**: 음수 값은 반시계 방향 회전으로 처리 (예: -90 → 270)
- **소수점 값**: 소수점 각도 지원 (예: 45.5도)
- **이미지 없이 기본 마커 사용**: 기본 마커에도 회전 적용 가능
- **InfoWindow와 함께 사용**: 마커 회전 시 InfoWindow 위치는 영향받지 않음

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Marker 클래스에 `rotation` 속성을 추가해야 합니다 (타입: double, 기본값: 0)
- **FR-002**: rotation 값은 0부터 360까지의 각도를 나타내며, 0은 북쪽(위쪽)을 의미합니다
- **FR-003**: 시스템은 rotation 값이 0이 아닌 경우 CSS `transform: rotate()`를 적용하여 마커 이미지를 회전시켜야 합니다
- **FR-004**: rotation 값은 양수(시계 방향), 음수(반시계 방향), 소수점 모두 지원해야 합니다
- **FR-005**: 기존 Marker 기능(클릭 이벤트, 드래그, InfoWindow 등)은 회전 적용 후에도 정상 동작해야 합니다
- **FR-006**: rotation 속성 미지정 시 기본값 0으로 동작하여 기존 코드와 하위 호환성을 유지해야 합니다

### Key Entities

- **Marker**: 지도 위에 표시되는 마커 객체. rotation 속성이 추가되어 이미지 회전 각도를 지정
  - 기존 속성: markerId, latLng, width, height, offsetX, offsetY, icon, draggable, infoWindowContent, zIndex
  - 새로운 속성: rotation (double, 기본값 0)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 개발자가 rotation 속성만 추가하면 마커 회전이 동작해야 합니다 (1줄 코드 추가로 구현 가능)
- **SC-002**: 0, 15, 44, 90, 120, 180, 270, 359.5 등 모든 각도 값에서 정확하게 회전이 적용됩니다
- **SC-003**: 회전이 적용된 마커의 클릭 이벤트가 정상 동작합니다
- **SC-004**: 기존 rotation 속성 없이 작성된 코드가 수정 없이 동작합니다 (하위 호환성 100%)
- **SC-005**: 예제 앱에 마커 회전 데모 화면이 추가되어 기능을 시연할 수 있습니다

## Assumptions

- CSS transform은 모든 지원 플랫폼(Android WebView, iOS WKWebView)에서 정상 동작합니다
- 회전 중심점은 마커 이미지의 중앙으로 설정합니다 (transform-origin: center)
- 성능 최적화를 위해 rotation이 0인 경우 기존 방식 그대로 렌더링합니다
