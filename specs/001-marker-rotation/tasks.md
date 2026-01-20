# Tasks: Marker Rotation (마커 회전 기능)

**Input**: Design documents from `/specs/001-marker-rotation/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

**Tests**: 테스트는 예제 앱을 통한 시각적 검증으로 대체 (별도 단위 테스트 미요청)

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Plugin**: `lib/` at repository root
- **Example app**: `example/lib/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 기존 코드 구조 확인 및 수정 대상 파일 준비

- [x] T001 현재 Marker 클래스 및 addMarker 함수 구조 분석 in lib/src/basic/marker.dart

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: 모든 User Story에서 공통으로 사용되는 핵심 구현

**⚠️ CRITICAL**: 이 단계가 완료되어야 모든 User Story 구현 가능

### Marker 클래스 수정

- [x] T002 Marker 클래스에 rotation 속성 추가 (double, 기본값 0) in lib/src/basic/marker.dart
- [x] T003 Marker.toJson()에 rotation 필드 추가 in lib/src/basic/marker.dart
- [x] T004 Marker.toString()에 rotation 필드 추가 in lib/src/basic/marker.dart

### JavaScript 이미지 회전 함수 추가

- [x] T005 rotateImage 헬퍼 함수 추가 (Canvas 기반 이미지 회전) in lib/src/basic/kakao_map.dart

### addMarker 함수 수정

- [x] T006 addMarker JS 함수 시그니처에 rotation 파라미터 추가 in lib/src/basic/kakao_map.dart
- [x] T007 addMarker JS 함수 내부에 rotation 처리 로직 구현 in lib/src/basic/kakao_map.dart

### Controller 수정

- [x] T008 addMarker 호출 시 rotation 값 전달하도록 수정 in lib/src/basic/kakao_map_controller.dart

**Checkpoint**: 기본 rotation 기능 구현 완료 - User Story 구현 시작 가능

---

## Phase 3: User Story 1 & 3 - 기본 마커 회전 + 커스텀 이미지 회전 (Priority: P1) 🎯 MVP

**Goal**: 개발자가 Marker 생성 시 rotation 속성을 지정하여 마커를 회전시킬 수 있음 (기본 마커 및 커스텀 이미지 모두)

**Independent Test**: 예제 앱에서 다양한 각도(0, 45, 90, 180, 270도)의 마커를 생성하여 시각적으로 확인

### Implementation for User Story 1 & 3

- [x] T009 [US1] 예제 화면 파일 생성 in example/lib/src/overlay_28_marker_rotation_screen.dart
- [x] T010 [US1] 기본 마커 회전 예제 구현 (0, 45, 90, 180, 270도) in example/lib/src/overlay_28_marker_rotation_screen.dart
- [x] T011 [US1] [P] 커스텀 이미지 마커 회전 예제 추가 (asset 이미지) in example/lib/src/overlay_28_marker_rotation_screen.dart
- [x] T012 [US1] home_screen.dart에 예제 화면 메뉴 항목 추가 in example/lib/src/home_screen.dart

**Checkpoint**: User Story 1 & 3 완료 - 기본 회전 및 커스텀 이미지 회전이 동작해야 함

---

## Phase 4: User Story 2 - 동적 마커 회전 업데이트 (Priority: P2)

**Goal**: 개발자가 실시간으로 마커의 회전 각도를 업데이트할 수 있음

**Independent Test**: 버튼 클릭으로 마커의 rotation 값을 변경하고 즉시 반영되는지 확인

### Implementation for User Story 2

- [x] T013 [US2] 동적 회전 업데이트 예제 추가 (슬라이더로 각도 조절) in example/lib/src/overlay_28_marker_rotation_screen.dart
- [x] T014 [US2] 회전 각도 표시 UI 추가 in example/lib/src/overlay_28_marker_rotation_screen.dart

**Checkpoint**: User Story 2 완료 - 동적 회전 업데이트가 동작해야 함

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: 문서화 및 최종 검증

- [x] T015 [P] CHANGELOG.md에 rotation 기능 추가 내용 작성 in CHANGELOG.md
- [x] T016 [P] README.md에 마커 회전 예제 코드 추가 in README.md
- [x] T017 quickstart.md 기반 전체 기능 검증 실행

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - 즉시 시작 가능
- **Foundational (Phase 2)**: Setup 완료 후 - **모든 User Story를 BLOCK**
- **User Story 1 & 3 (Phase 3)**: Foundational 완료 후
- **User Story 2 (Phase 4)**: Phase 3 완료 후 (동적 업데이트는 기본 회전 기반)
- **Polish (Phase 5)**: 모든 User Story 완료 후

### User Story Dependencies

- **User Story 1 & 3 (P1)**: Foundational 완료 후 시작 가능 - 서로 종속 없음 (동일 파일이므로 통합)
- **User Story 2 (P2)**: Phase 3 완료 후 시작 가능 (기본 회전 기능 필요)

### Within Each User Story

- 예제 화면 파일 생성 → 기능 구현 → 메뉴 추가

### Parallel Opportunities

- T003, T004는 T002 완료 후 병렬 가능 (같은 파일이지만 다른 메서드)
- T015, T016은 병렬 실행 가능 (다른 파일)

---

## Parallel Example: Foundational Phase

```bash
# T002 완료 후 다음 태스크들 병렬 실행:
Task: "Marker.toJson()에 rotation 필드 추가" (T003)
Task: "Marker.toString()에 rotation 필드 추가" (T004)

# T005, T006, T007은 순차 실행 필요 (같은 함수 수정)
```

---

## Implementation Strategy

### MVP First (User Story 1 & 3 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1 & 3
4. **STOP and VALIDATE**: 예제 앱에서 기본 회전 테스트
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → 기본 rotation 속성 사용 가능
2. Add User Story 1 & 3 → 예제 앱에서 검증 (MVP!)
3. Add User Story 2 → 동적 업데이트 검증
4. Polish → 문서화 완료

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- US1과 US3은 동일 파일에서 구현되므로 통합
- rotation 기본값 0으로 하위 호환성 보장
- 예제 앱에서 시각적 검증 수행
