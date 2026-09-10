## 0.5.0

### 성능
* 오버레이(마커, 폴리라인, 원, 사각형, 다각형, 커스텀 오버레이)를 요소별 개별 호출 대신 **배치 1회 호출**로 전송합니다. 마커 N개 기준 N+1회 → 1~3회 브릿지 왕복.
* `didUpdateWidget` 에서 오버레이 종류별 **내용 시그니처를 비교**해 실제로 바뀐 종류만 재전송합니다. 부모 위젯의 무관한 rebuild 로 인한 전량 재생성이 사라집니다.
* JS 쪽 오버레이 관리를 배열 선형 탐색(O(N²))에서 **id 인덱스(Map) 기반 O(1) 조회**로 전환했습니다.
* 같은 ID + 같은 내용의 오버레이는 재생성하지 않고 재사용합니다(항목별 hash). 내용이 바뀐 항목만 교체됩니다.
* base64 마커 아이콘의 Blob URL 과 `MarkerImage` 인스턴스를 캐시하고, `dispose()` 시 `revokeObjectURL` 로 해제합니다. `MarkerIcon.fromAsset` 결과도 assetName 기준으로 캐시합니다.
* `onMapDoubleTap` 콜백이 없으면 `dblclick` 리스너를 등록하지 않습니다.
* `relayout()` 호출을 코얼레싱해 위젯 rebuild 마다 중복 발생하던 지도 리플로우를 제거했습니다. 지도 준비 직후와 위젯 크기 변경 시에는 즉시 반영됩니다.
* 불러올 SDK 확장 라이브러리를 선택할 수 있게 했습니다. 사용하지 않는 라이브러리를 제외하면 지도 생성 시 다운로드/파싱 비용이 줄어듭니다(예: `drawing` 번들은 압축 전 약 99KB 로 지도 본체와 맞먹습니다). 기본값은 전체이므로 지정하지 않으면 기존과 동일합니다.

### 버그 수정
* 폴리라인/원/사각형/다각형에 JS 측 `id` 가 할당되지 않아 ID 기반 부분 갱신과 `clearXxx(ids:)` 가 항상 전량 삭제되던 문제를 수정했습니다.
* 같은 `markerId` 로 좌표나 속성을 바꿔도 지도에 반영되지 않던 문제를 수정했습니다.
* `setMarkerDraggable` 이 항상 동작하지 않던 문제(`markerId` 속성명 불일치)를 수정했습니다.
* `Clusterer.disableClickZoom` 이 무시되고 항상 `true` 로 동작하던 문제를 수정했습니다.
* 클러스터러가 일반 마커까지 흡수하고, 재생성 시 이전 마커가 누적되던 문제를 수정했습니다. 클러스터러 마커와 일반 마커는 이제 분리 관리됩니다.
* `ClustererStyle.color`/`background` 가 null 이면 클러스터러 생성이 실패하던 문제를 수정했습니다.
* 구멍이 있는 폴리곤(`holes`)에서 `strokeStyle` 이 무시되던 문제를 수정했습니다.
* `LatLng.fromJson` 이 정수 좌표에서 `TypeError` 를 던지던 문제, `LatLngBounds.fromJson` 이 항상 실패하던 문제를 수정했습니다.
* `getBounds()`, `getLevel()` 이 정수 좌표를 반환하는 경우 `TypeError` 가 발생하던 문제를 수정했습니다.
* 검색어/콘텐츠에 작은따옴표·줄바꿈·U+2028 등이 포함되면 JS 구문이 깨지던 문제(인젝션 가능)를 수정했습니다. 모든 값은 JSON 문자열 리터럴로 안전하게 전달됩니다.
* 커스텀 오버레이 ID 를 통한 HTML/JS 인젝션을 차단했습니다.
* 위젯 속성으로 전달한 초기 오버레이가 rebuild 전까지 그려지지 않던 문제를 수정했습니다. 이제 `onMapCreated` 시점에 그려집니다.
* WebView 페이지가 재로드될 때 기존에 그려져 있던 오버레이가 복구되지 않던 문제를 수정했습니다. (참고: iOS 는 `loadHtmlString` 으로 로드한 문서를 `reload()` 하면 HTML 이 다시 실행되지 않는 WKWebView 동작 때문에 복구되지 않습니다. 지도를 다시 그리려면 위젯을 재생성하세요.)
* 배치 전송 중 오버레이 하나가 실패해도 나머지 오버레이는 정상적으로 표시되도록 수정했습니다.
* `markers` 등 오버레이 목록을 `null` 로 바꿔도 기존 오버레이가 지도에 남아있던 문제를 수정했습니다.
* `setBounds()` 가 항상 실패하던 문제를 수정했습니다(optional `bounds` 파라미터 추가).
* 릴리스 빌드에서도 Android WebView 원격 디버깅이 켜져 있던 문제를 수정했습니다(`kDebugMode` 에서만 활성화).

### 검색 서비스
* 키워드/카테고리/주소/좌표 변환 요청에 **요청 ID 기반 라우팅**을 도입했습니다. 동시에 여러 요청을 보내도 각자의 응답을 받으며, 카카오 API 가 오류 상태를 반환하면 `Future` 가 에러로 완료됩니다(이전에는 영구 대기). 60초 안에 응답이 없으면 `TimeoutException` 으로 완료됩니다.
* 검색 실패(카카오 API 가 `ERROR` 상태를 반환하거나 결과가 `null` 인 경우)가 성공으로 처리되던 문제를 수정했습니다. 단, **결과 0건(`ZERO_RESULT`)은 오류가 아니라 빈 목록**으로 처리되며 이는 기존 동작과 동일합니다.
* `AddressSearchRequest.analyzeType` 이 요청 시 무시되던 문제를 수정했습니다.
* 검색 요청이 타임아웃될 때 레거시 `xxxResult()` 콜백 경로도 함께 종료되지 않던 문제를 수정했습니다(이제 타임아웃 시 레거시 경로도 함께 종료됩니다).
* `services` 라이브러리를 제외하고 지도를 만든 경우, 검색 API 호출이 조용히 멈추지 않고 `SERVICES_LIBRARY_NOT_LOADED` 오류로 완료됩니다.

### ⚠️ BREAKING (동작 변경)
* `controller.clearMarker()` 는 이제 **클러스터러가 관리하는 마커를 제외**하고 일반 마커만 제거합니다. 마이그레이션: 클러스터러 마커까지 지우려면 `clearMarkerClusterer()` 를 함께 호출하세요.
* `controller.clear()` 는 이제 클러스터러 객체와 클러스터러 마커까지 함께 제거합니다(이전에는 마커만 숨겨지고 클러스터 표시가 남을 수 있었음). 마이그레이션: 클러스터러만 남기고 싶다면 `clear()` 대신 개별 `clearXxx()` 메서드를 조합해서 호출하세요.
* `controller.clearMarkerClusterer()` 는 클러스터러 객체를 해제하고(`null`) 소속 마커를 전역 목록에서 제거합니다. 마이그레이션: 클러스터러 해제 후 마커를 다시 표시하려면 `addMarker()` 를 다시 호출하세요.
* 진행 중인 검색 요청이 있는 상태에서 같은 종류의 새 검색을 시작하면, 이전 요청의 레거시 `xxxResult()` 대기가 영구 대기 대신 `StateError('새 요청으로 대체되었습니다.')` 로 종료됩니다. 마이그레이션: 레거시 정적 결과 경로를 쓰고 있다면 `await` 지점을 `try/catch` 로 감싸거나, 요청별로 결과를 받는 `controller.keywordSearch()` 반환값을 사용하세요.
* `controller.addMarker(markers: [])` 및 `KakaoMap(markers: [])` 는 이제 다른 오버레이와 동일하게 **기존 일반 마커를 모두 제거**합니다(이전에는 무시됨). `null` 은 여전히 무시됩니다. 마이그레이션: 기존 마커를 유지하려면 빈 리스트(`[]`) 대신 `null` 을 전달하세요.
* 같은 ID 의 마커를 다른 내용으로 다시 추가하면 갱신됩니다(이전에는 무시됨). 마이그레이션: 기존 마커를 유지하고 싶다면 동일한 ID 로 재호출하지 마세요.
* `KakaoMap` 위젯 속성으로 넘긴 오버레이는 지도 준비(`onMapCreated`) 시점에 자동으로 그려집니다. 마이그레이션: `onMapCreated` 콜백에서 별도로 오버레이를 그리던 코드는 중복 호출이 되지 않도록 제거하세요.

### API 추가 (하위호환 유지)
* `KakaoMapLibrary` 열거형과 `AuthRepository.initialize(libraries:)`, `KakaoMap(libraries:)` 를 추가했습니다. 지정하지 않으면 기존과 동일하게 전체를 불러오며, `clusterer` 를 사용하면 자동으로 포함됩니다.
* `MarkerIcon.network(url)` 동기 생성자를 추가했습니다. 기존 `MarkerIcon.fromNetwork` 는 `Future<MarkerIcon>` 을 그대로 반환합니다.
* `MarkerIcon.fromBytes(bytes)`, `MarkerIcon.fromBase64(base64)` 를 추가했습니다.
* 같은 base64 아이콘을 쓰는 마커가 여러 개여도 이미지는 WebView 에 1회만 전송됩니다(`registerImages` 레지스트리).
* `BaseService.createRequest()` / `requestFuture()` / `failRequest()` / `handleMessage()` 를 추가했습니다. 기존 `resetCompleter()` / `completer` / `xxxCallback` 은 유지됩니다.
* `AuthRepository.isInitialized` 를 추가했고, 초기화 전에 `appKey` 에 접근하면 명확한 `StateError` 를 던집니다. `appKey` setter 는 유지됩니다.
* `setBounds()` 에 optional `bounds` 파라미터를 추가했습니다.
* `isDraggable()`, `isZoomable()` 을 추가했습니다. 기존 `getDraggable()`, `getZoomable()` 은 `@Deprecated` 되었으며 계속 동작합니다.

### Deprecated
* `MapType.roadMap` 은 `MapType.normal` 과 값이 동일하여 `@Deprecated` 되었습니다. `normal` 을 사용하세요.
* `setStyle()` 을 `@Deprecated` 처리했습니다.
* 사용되지 않는 웹 플랫폼 템플릿 클래스(`KakaoMapPluginWeb`, `KakaoMapPluginPlatform`, `MethodChannelKakaoMapPlugin`)를 `@Deprecated` 처리했습니다. 다음 메이저 버전에서 제거될 예정입니다.

### 기타
* `dart:io` 의존성을 제거했습니다.
* `flutter_lints` 를 적용해 정적 분석 규칙을 강화했습니다.

### 문서
* `clearMarker(markerIds:)` 등 `clearXxx(ids:)` 의 `ids` 는 **남길 ID 목록**임을 문서에 명시했습니다(동작 변경 없음).

## 0.4.0

* **BREAKING**: Minimum SDK version updated to Dart 3.3.0 and Flutter 3.19.0.
* Migrated from deprecated `dart:html` to `package:web` for web platform support.
* Improved static analysis score for pub.dev.
* Removed unused variables and imports.
* Updated Kotlin version to 2.1.0 for Android.
* Cleaned up example app by removing internal test screens.

## 0.3.7

* Changed the parameter order of coord2Address and coord2RegionCode.
* Update the example to display the marker at the clicked location.

## 0.3.6

* Add marker image loading from assets.

## 0.3.5

* Optimize drawing performance
* Removed "isClickable" option from custom overlay.

## 0.3.4

* Modify to retrieve the list of markers for the selected cluster.

## 0.3.3

* Modify code to be depreciated.
* The package related to webview has been updated.
* fix onBoundsChanged is not working on android device.

## 0.3.2

* added dispose method.
* apply dart format.

## 0.3.1

* Modified the parameters for coord2RegionCode and coord2Address.

## 0.3.0

* Integration and implementation of an example for searching places by keyword
* Integration and implementation of an example for displaying a list of places searched by keyword
* Integration and implementation of an example for searching places by category
* Integration and implementation of an example for searching places by specific categories
* Integration and implementation of an example for displaying places by address
* Integration and implementation of an example for obtaining an address by coordinates
* Integration and implementation of an example for converting WTM coordinates to WGS84 coordinates
* Modification of the example source for marker clustering
* Addition of options when using setLevel

## 0.2.6

* Modified the street view to allow dynamic setting of central coordinates.
* Added zIndex properties for polyline, polygon, circle, and rectangle.
* Changed the location of the addJavaScriptChannels code.
* Fixed a missing > tag in div element for addCustomOverlay.

## 0.2.5

* Modify the hard-coded style in the Polyline drawing.

## 0.2.4

* Modified CustomOverlay click event

## 0.2.3

* Added Marker Clusterer

## 0.2.2

* Changed the default value of the image marker's offset.

## 0.2.1

* Modified to accept xAnchor, yAnchor, and zIndex as parameters.

## 0.2.0

* Fixed bugs in getLevel and getMapTypeId.

## 0.1.9

* Adjusted the timing of the 'addJavaScriptChannels' invocation

## 0.1.8

* Changed the timing of setting map for CustomOverlay

## 0.1.7

* Added CustomOverlay click event

## 0.1.4

* Added callbacks to detect the drag start and end events of a marker

## 0.1.3

* Add the "isClickable" option to the CustomOverlay creation.

## 0.1.2

* Added Dart document comments
* Added "generated" folder to .gitignore

## 0.1.1

* Changed ControlPosition enum variables from upper camel case to lower camel case
* Updated webview_flutter package to the latest version
* Added webview_flutter_android and webview_flutter_wkwebview
* Migrated to the new version of webview_flutter package

## 0.1.0

* Implemented and added a sample for loading views
* Added drawing rectangles functionality
* Changed onMarkerClick to onMarkerTap

## 0.0.1

* Initial release.
