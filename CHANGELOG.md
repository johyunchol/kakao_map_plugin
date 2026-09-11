## 1.0.0

First stable release. It adds Web support, covers all 77 official Kakao Maps JS samples, and includes the behavior changes listed below. A migration guide is available in the README (`README.md` in Korean, `README_EN.md` in English) under "Migrating from 0.x".

### ⚠️ BREAKING (behavior changes)
* `controller.clearMarker()` now removes only plain markers and **skips markers managed by a clusterer**. Migration: call `clearMarkerClusterer()` as well if you also want to remove clusterer markers.
* `controller.clear()` now also removes the clusterer object and its markers (previously the markers could just be hidden while the cluster indicators remained). Migration: if you want to keep the clusterer, call the individual `clearXxx()` methods instead of `clear()`.
* `controller.clearMarkerClusterer()` releases the clusterer object (`null`) and removes its markers from the global list. Migration: call `addMarker()` again to re-display markers after releasing the clusterer.
* Starting a new search of the same kind while a request is still in flight now terminates the previous request's legacy `xxxResult()` wait with `StateError('새 요청으로 대체되었습니다.')` instead of waiting forever. Migration: if you use the legacy static result path, wrap the `await` in `try/catch`, or use the per-request return value of `controller.keywordSearch()`.
* `controller.addMarker(markers: [])` and `KakaoMap(markers: [])` now **remove all existing plain markers**, consistent with the other overlays (previously ignored). `null` is still ignored. Migration: pass `null` instead of an empty list (`[]`) to keep existing markers.
* Re-adding a marker with the same ID but different content now updates it (previously ignored). Migration: do not re-invoke with the same ID if you want to keep the existing marker.
* Overlays passed as `KakaoMap` widget properties are now drawn automatically when the map is ready (`onMapCreated`). Migration: remove code that drew those overlays separately in the `onMapCreated` callback so they are not applied twice.
* Links (`<a href>`) inside info windows and custom overlays are now intercepted and reported through `KakaoMap(onLinkTap:)` instead of navigating the WebView away from the map. Migration: handle `onLinkTap` to open the URL yourself (for example with `url_launcher`); the tap is ignored when no callback is provided.
* Text selection, tap highlight, the long-press context menu, page pinch-zoom and overscroll are disabled by default in the map document. Migration: add the `kmp-selectable` CSS class to elements that must stay selectable.
* Added a new dependency on `pointer_interceptor` (only used on Web in practice). Migration: run `flutter pub get`; no code change is required for Android/iOS.
* Failed search calls (Kakao API returning an error status, or a `null` result) now complete the `Future` with an error instead of completing successfully. Migration: wrap search calls in `try/catch`. Zero results (`ZERO_RESULT`) is still not an error.

### Deprecated (kept, will be removed in 2.0.0)
Nothing was removed in 1.0.0. All deprecated APIs still work.

* `MapType.roadMap` is `@Deprecated` because its value is identical to `MapType.normal`. Use `MapType.normal`.
* `setStyle()` is `@Deprecated`. Control the container size with Flutter widgets and call `relayout()` instead.
* `getDraggable()` and `getZoomable()` are `@Deprecated`. Use `isDraggable()` and `isZoomable()`.
* The unused platform template classes `KakaoMapPluginPlatform` and `MethodChannelKakaoMapPlugin` are `@Deprecated`. (`KakaoMapPluginWeb` stays as the Web platform registration class.)

### Web support
* **Added support for the web platform.** On Web the same HTML is rendered in a same-origin iframe document instead of a WebView. Map, overlay, roadview, Drawing, search and tileset APIs behave the same as on mobile, and no code change is required.
* Added `KakaoMapPointerInterceptor`, a widget that wraps Flutter widgets stacked on top of the map (iframe) so they receive taps on Web. On Android/iOS it returns its child unchanged.
* You must register the app origin (including the port) under **Web platform site domains** in the Kakao console. The `baseUrl` workaround does not work on Web.
* Dart-to-JS communication is now abstracted behind `KakaoMapBridge` (`WebViewBridge` on mobile, `IframeBridge` on Web). Existing constructors such as `KakaoMapController(WebViewController)` are unchanged; on Web the `webViewController` getter throws a `StateError`.

### Performance
* Overlays (markers, polylines, circles, rectangles, polygons, custom overlays) are sent in a **single batch call** instead of one call per element. For N markers this cuts bridge round trips from N+1 to 1-3.
* `didUpdateWidget` now **compares a content signature per overlay kind** and re-sends only the kinds that actually changed. Unrelated parent rebuilds no longer recreate every overlay.
* Overlay bookkeeping on the JS side moved from linear array scans (O(N^2)) to **O(1) lookups through an id index (Map)**.
* Overlays with the same ID and the same content are reused instead of recreated (per-item hash). Only items whose content changed are replaced.
* Blob URLs and `MarkerImage` instances for base64 marker icons are cached and released with `revokeObjectURL` on `dispose()`. `MarkerIcon.fromAsset` results are cached by asset name.
* The `dblclick` listener is not registered when no `onMapDoubleTap` callback is set.
* `relayout()` calls are coalesced, removing the duplicate map reflow that happened on every widget rebuild. It is still applied immediately right after the map is ready and when the widget size changes.
* The SDK extension libraries to load can now be selected. Excluding unused libraries reduces download and parse cost at map creation (for example the `drawing` bundle is about 99KB uncompressed, comparable to the map core). The default is all libraries, so behavior is unchanged if you do not specify any.

### Bug fixes
* Fixed polylines, circles, rectangles and polygons not receiving a JS-side `id`, which made ID-based partial updates and `clearXxx(ids:)` always delete everything.
* Fixed coordinate or property changes on an existing `markerId` not being reflected on the map.
* Fixed `setMarkerDraggable` not always working (`markerId` property name mismatch).
* Fixed `Clusterer.disableClickZoom` being ignored and always behaving as `true`.
* Fixed the clusterer absorbing plain markers and accumulating previous markers on recreation. Clusterer markers and plain markers are now managed separately.
* Fixed clusterer creation failing when `ClustererStyle.color` or `background` was null.
* Fixed `strokeStyle` being ignored on polygons with holes (`holes`).
* Fixed `LatLng.fromJson` throwing a `TypeError` for integer coordinates, and `LatLngBounds.fromJson` always failing.
* Fixed a `TypeError` from `getBounds()` and `getLevel()` when they returned integer coordinates.
* Fixed broken JS syntax (and a possible injection) when a search term or content contained single quotes, newlines, U+2028 and similar characters. All values are now passed safely as JSON string literals.
* Blocked HTML/JS injection through custom overlay IDs.
* Fixed initial overlays passed as widget properties not being drawn until the first rebuild. They are now drawn at `onMapCreated`.
* Fixed existing overlays not being restored when the WebView page reloads. (Note: on iOS a document loaded with `loadHtmlString` does not re-execute its HTML on `reload()` due to WKWebView behavior, so it is not restored. Recreate the widget to redraw the map.)
* Fixed one failing overlay in a batch preventing the remaining overlays from being displayed.
* Fixed existing overlays staying on the map when an overlay list such as `markers` was changed to `null`.
* Fixed `setBounds()` always failing (added an optional `bounds` parameter).
* Fixed Android WebView remote debugging being enabled in release builds (now enabled only under `kDebugMode`).
* Fixed `ClustererStyle.background` being passed to CSS as a Flutter-ordered hex value (`#aarrggbb`), which produced the wrong color. It is now passed in CSS form (`#rrggbb` / `rgba()`).
* Fixed `KeywordSearchRequest.useMapCenter` and `useMapBounds` always being ignored (`Places` is now bound to the map).
* Fixed marker text being inserted unescaped into the initial `KakaoStaticMap` HTML, which broke the script when the text contained `</script>`.

### Search service
* Introduced **request-ID based routing** for keyword, category, address and coordinate conversion requests. Concurrent requests each receive their own response, and the `Future` completes with an error when the Kakao API returns an error status (previously it waited forever). Requests without a response within 60 seconds complete with a `TimeoutException`.
* Fixed search failures (Kakao API returning an `ERROR` status, or a `null` result) being treated as success. Note that **zero results (`ZERO_RESULT`) is not an error and yields an empty list**, matching the previous behavior.
* Fixed `AddressSearchRequest.analyzeType` being ignored when sending the request.
* Fixed the legacy `xxxResult()` callback path not being terminated when a search request timed out (it is now terminated together with the request).
* When the map was created without the `services` library, search API calls now complete with a `SERVICES_LIBRARY_NOT_LOADED` error instead of silently hanging.

### Native app feel (defaults)
* The map document now uses system fonts (`-apple-system`, Roboto, Noto Sans KR, ...) by default, and disables tap highlight, text selection, the long-press callout/context menu, page pinch-zoom, overscroll glow/bounce, scrollbars and focus rings. Add the `kmp-selectable` class to elements that must stay selectable. Link previews are also disabled on iOS.
* Fixed tapping an `<a href>` inside an info window or custom overlay navigating the WebView away and making the map disappear. Navigation is intercepted and reported through `KakaoMap(onLinkTap:)` (the roadview widgets behave the same). The tap is ignored when no callback is set.

### App-feel package
* Added `InfoWindowStyle`. Set it through `Marker.infoWindowStyle` or `KakaoMapTheme.infoWindowStyle` to draw an app-style bubble (rounded corners, shadow, tail, close button) instead of the SDK default info window. `material()`, `cupertino()` and `dark()` presets are available; the shape is unchanged when not specified.
* Added `KakaoMapTheme` (`AuthRepository.initialize(theme:)` globally, `KakaoMap(theme:)` per map) to set the font, the background color shown before tiles load, the default info window style, and extra CSS.
* Added `KakaoMapControls` (Flutter zoom in/out and map type buttons) and `KakaoDrawingToolbar` (a chip bar for Drawing shape selection and undo). Both use `KakaoMapPointerInterceptor` internally so they remain tappable on Web.
* Added `MarkerIcon.pin(color:)` (an SVG pin recolored on the fly) and `MarkerIcon.fromWidget()` (renders a Flutter widget into a marker image).
* Added the `ClustererStyle.material(color)` preset and the `fontSize`, `fontWeight`, `fontFamily`, `border`, `boxShadow` and `opacity` fields.
* Added `KakaoMap(copyrightPosition:, copyrightReversed:)` and `KakaoRoadMap` / `KakaoMapRoadviewView(disableZoomControl:)`.

### Overlay events / markers / Flutter widget overlays / search pagination / Kakao Map links
* Added `KakaoMapWidgetOverlay` and `KakaoMap(widgetOverlays:)`. They attach real Flutter widgets to map coordinates and follow the pixel positions reported by JS as the map moves (once per frame). They are tappable on Web too.
* Added the tap callbacks `onPolylineTap`, `onCircleTap` and `onRectangleTap`, plus `onMapLongPress` (which includes right-click in mouse environments).
* Added the mouse hover callbacks `onMarkerMouseOver`, `onMarkerMouseOut`, `onPolygonMouseOver`, `onPolygonMouseMove`, `onPolygonMouseOut` and `supportsHover()`. These are **mouse-pointer environments only** and are never called on touch devices. The examples "마커에 마우스 이벤트 등록하기" (registering mouse events on a marker) and "다각형에 이벤트 등록하기 1 / 2" (registering events on a polygon) were restored to match the official samples, with a touch fallback added.
* Added `opacity`, `visible`, `clickable`, `title` and sprite support (`spriteOrigin`, `spriteWidth`, `spriteHeight`) to `Marker`, plus `setMarkerPosition()` (moves without recreating), `setMarkerVisible()`, `showInfoWindow()` and `hideInfoWindow()`.
* Added `pagination` to keyword, category and address search responses (`SearchPagination`: `totalCount`, `current`, `hasNextPage`, `hasPrevPage`).
* Added `KakaoMapLinks`, which builds place, directions, roadview and search URLs as Kakao Map web links (`map.kakao.com/link/...`) and app schemes (`kakaomap://`). Launch them yourself with `url_launcher` or similar.

### Camera / measurement
* Fixed `KakaoMap(minLevel:, maxLevel:)` not being applied when changed by a rebuild, and added `setMinLevel()` and `setMaxLevel()`.
* Added `jump(center, level, animate:, duration:)`, `panBy(dx, dy)`, `panToBounds(bounds, padding:)` and `fitBounds(points, padding:)`.
* Added `getPolylineLength()`, `getPolygonArea()` and `getPolygonLength()`, which return the SDK-computed values. The examples "선의 거리 계산하기" (calculating the distance of a line) and "다각형의 면적 계산하기" (calculating the area of a polygon) now behave like the official samples.
* Added the map creation options `mapTypeId` (initial map type), `disableDoubleClick`, `disableDoubleClickZoom`, `scrollwheel` and `keyboardShortcuts`, plus the `onMapTypeChanged` callback.

### Roadview
* Fixed `KakaoRoadMap` not calling `onMapCreated`, not drawing markers, and duplicating markers indefinitely on every rebuild.
* Fixed the roadview turning into a blank screen on iOS after returning from the background (uses `relayout()` instead of `reload()`).
* The `onRoadviewNotFound` callback is now invoked without an error in areas that have no roadview (`panoId === null`).
* Added `KakaoRoadviewController` (delivered through `onRoadviewCreated`). It provides `setPanoId`, `setPanoIdNear`, `getPanoId`, `setViewpoint`, `getViewpoint`, `getPosition`, `viewpointFromCoords`, `relayout`, `addMarker`, `addCustomOverlay`, `clearMarker`, `clearCustomOverlay` and `clear`.
* Added `panoId`, `radius`, `viewpoint` and `customOverlays` to `KakaoRoadMap`, plus the callbacks `onRoadviewInit`, `onPanoIdChange`, `onViewpointChange`, `onPositionChange`, `onRoadviewNotFound`, `onMarkerTap` and `onCustomOverlayTap`. The existing `onMapCreated` and `currentLevel` are unchanged.
* Added the `Viewpoint` model (`pan`, `tilt`, `zoom`).
* Added `altitude` and `range` to `Marker`, and `altitude` to `CustomOverlay` (used in roadview).
* Fixed the MapWalker sprite coordinates being wrong, which made the icon look cropped (now uses the official Kakao sample coordinates).
* Fixed the map center being off by half the viewport in `KakaoMapRoadviewView` after switching display mode or resizing. Entering split or roadview mode for the first time now loads the roadview at the map center automatically.
* Added `KakaoMapRoadviewView` / `KakaoMapRoadviewController` / `RoadviewViewMode`, which show a map and a roadview together in one WebView. Clicking the map moves the roadview, and the MapWalker indicates the roadview viewpoint direction on the map.

### Overlay interaction
* Added the `KakaoMap(onPolygonTap:)` polygon tap callback.
* Added `CustomOverlay.removable` (close button plus the `onCustomOverlayRemove` callback) and `CustomOverlay.draggable` (drag plus the `onCustomOverlayDragEnd` callback). Map panning is locked while dragging, and document-level listeners are removed as soon as the drag ends.
* Fixed `coordToPixel` and `pixelToCoord` throwing an opaque cast error when called after the map was disposed. They now throw a `StateError` that explains the cause.

### Drawing Library
* Added bindings for the Drawing Library, which lets users draw shapes on the map: `KakaoMapController.createDrawingManager`, `selectDrawingMode`, `cancelDrawing`, `undoDrawing`, `redoDrawing`, `removeDrawingShape`, `getDrawingData`, `showDrawingToolbox`, `removeDrawingToolbox`.
* Added `DrawingOverlayType`, `DrawingOptions`, `DrawingStyle` and the result DTOs `DrawingData` / the `DrawingShape` family (`DrawingMarkerShape`, `DrawingPathShape`, `DrawingRectangleShape`, `DrawingCircleShape`, `DrawingEllipseShape`). Coordinates are normalized to `LatLng`.
* Added the `KakaoMap` callbacks `onDrawingEnd`, `onDrawingRemove` and `onDrawingStateChange`.
* When the map is created without `KakaoMapLibrary.drawing`, the Drawing APIs are silently ignored and the error is recorded in `window.__kakaoMapErrors`.

### Custom tileset
* Added `Tileset` / `TilesetCopyright` and `KakaoMapController.addTileset`, `setTileset`, `addOverlayTileset`, `removeOverlayTileset`, `getActiveTilesetId`. The tile source can be a URL template (`{x}`, `{y}`, `{z}`), a URL function, or a DOM tile function.
* `getMapTypeId()` now returns `MapType.normal` without throwing while a custom tileset is the base map type. Use `getActiveTilesetId()` to read the tileset ID.

### New APIs (backward compatible)
* Added the `KakaoMapLibrary` enum with `AuthRepository.initialize(libraries:)` and `KakaoMap(libraries:)`. All libraries are loaded when unspecified, as before, and `clusterer` is included automatically when used.
* Added the synchronous `MarkerIcon.network(url)` constructor. The existing `MarkerIcon.fromNetwork` still returns a `Future<MarkerIcon>`.
* Added `MarkerIcon.fromBytes(bytes)` and `MarkerIcon.fromBase64(base64)`.
* The image is sent to the WebView only once even when several markers use the same base64 icon (`registerImages` registry).
* Added `BaseService.createRequest()`, `requestFuture()`, `failRequest()` and `handleMessage()`. The existing `resetCompleter()`, `completer` and `xxxCallback` are kept.
* Added `AuthRepository.isInitialized`; accessing `appKey` before initialization now throws a clear `StateError`. The `appKey` setter is kept.
* Added an optional `bounds` parameter to `setBounds()`.
* Added `isDraggable()` and `isZoomable()`. The existing `getDraggable()` and `getZoomable()` still work.

### Examples
* All 77 official Kakao samples can now be run from the example app. Added 9 roadview screens, 12 overlay screens, 4 Drawing screens and 2 custom tileset screens. (Marker mouseover/mouseout is replaced by an informational screen because mobile has no hover concept.)
* Cleaned up duplicated library example file numbers (three `library_11_*` files).

### Docs
* Documented that the `ids` argument of `clearXxx(ids:)` (for example `clearMarker(markerIds:)`) is the **list of IDs to keep** (no behavior change).

### Misc
* Added the `pointer_interceptor` dependency for Web support (no effect on mobile behavior).
* Removed the `dart:io` dependency.
* Applied `flutter_lints` to strengthen the static analysis rules.

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
