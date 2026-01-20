# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

이 프로젝트는 `kakao_map_plugin` Flutter 플러그인의 **예제 앱**입니다. 카카오 지도 JavaScript API를 Flutter에서 사용할 수 있도록 webview_flutter를 활용한 플러그인의 다양한 기능을 시연합니다.

## 빌드 및 실행 명령어

```bash
# 의존성 설치
flutter pub get

# 앱 실행
flutter run

# 분석 실행
flutter analyze

# 테스트 실행
flutter test
```

## 환경 설정 (필수)

앱 실행 전 카카오 개발자센터에서 발급받은 JavaScript 키 설정이 필요합니다.

1. `assets/env/.env.sample`을 `assets/env/.env`로 복사
2. `.env` 파일에 키 입력:
   ```
   APP_KEY=your_javascript_key
   BASE_URL=http://localhost  # services 기능 사용 시 필요
   ```

## 아키텍처

### 플러그인 구조 (상위 디렉토리: `../`)

```
lib/
├── kakao_map_plugin.dart     # 라이브러리 진입점 (모든 part 파일 export)
└── src/
    ├── basic/                # 핵심 위젯 및 컨트롤러
    │   ├── kakao_map.dart           # KakaoMap 위젯 (메인)
    │   ├── kakao_map_controller.dart # 지도 제어 컨트롤러
    │   ├── marker.dart, circle.dart, polygon.dart... # 오버레이 객체들
    │   └── constants/               # 열거형 상수들
    ├── model/                # 데이터 모델 (LatLng, Address 등)
    ├── protocol/             # API 요청/응답 객체
    ├── service/              # REST API 서비스 클래스
    ├── repository/           # AuthRepository (앱 키 관리)
    ├── road/                 # 로드뷰 위젯
    └── static/               # 정적 지도 위젯
```

### 예제 앱 구조

```
lib/
├── main.dart           # 앱 진입점, AuthRepository.initialize() 호출
└── src/
    ├── home_screen.dart    # 메인 메뉴 화면 (탭 + 리스트)
    ├── map_*.dart          # 지도 기능 예제 (22개)
    ├── overlay_*.dart      # 오버레이 예제 (27개)
    ├── library_*.dart      # 라이브러리/서비스 예제 (14개)
    ├── roadview_*.dart     # 로드뷰 예제 (9개)
    └── static_*.dart       # 정적 지도 예제 (3개)
```

## 주요 패턴

### 초기화 패턴
```dart
// main.dart에서 앱 시작 전 호출 필수
AuthRepository.initialize(
  appKey: 'your_key',
  baseUrl: 'http://localhost'  // REST API 사용 시
);
```

### 지도 생성 패턴
```dart
KakaoMap(
  onMapCreated: (controller) {
    mapController = controller;
    // 지도 준비 완료 후 작업
  },
  center: LatLng(37.5, 127.0),
  markers: markers.toList(),
)
```

### 예제 화면 명명 규칙
- `map_N_*_screen.dart`: 지도 기본 기능
- `overlay_N_*_screen.dart`: 마커, 도형 등 오버레이
- `library_N_*_screen.dart`: 검색, 좌표 변환 등 서비스
- `roadview_N_*_screen.dart`: 로드뷰
- `static_N_*_screen.dart`: 정적 이미지 지도

## 플랫폼별 설정

### Android
`AndroidManifest.xml`에 필요:
- `android.permission.INTERNET`
- `android:usesCleartextTraffic="true"`

### iOS
`Info.plist`에 필요:
- `NSAllowsArbitraryLoads: true`
- `NSAllowsArbitraryLoadsInWebContent: true`
- `io.flutter.embedded_views_preview: true`
