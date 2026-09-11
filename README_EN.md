# kakao_map_plugin

[한국어](README.md) | English

[![pub package](https://img.shields.io/pub/v/kakao_map_plugin.svg?color=4285F4)](https://pub.dev/packages/kakao_map_plugin)

A Flutter plugin that runs **[Kakao Map](https://apis.map.kakao.com/web/guide)**.

It is not built on a native library — it is built on the Kakao Maps JavaScript library.

Android and iOS run through `webview_flutter`, and Web runs through an iframe. Mobile platforms have minimum version requirements.

|             | Android        | iOS  | Web                                                    |
|-------------|----------------|------|--------------------------------------------------------|
| **Support** | SDK 19+ or 20+ | 9.0+ | Supported (site domain registration required, see below) |

---

## Getting started

### Common

You need to issue a JavaScript key from the **[Kakao Developers console](https://developers.kakao.com/)**.

Add the dependency to `pubspec.yaml`

``` yaml
dependencies:
  kakao_map_plugin: [latest version]
```

1. Register the JavaScript key

* It is a singleton, so you only need to initialize it before the `KakaoMap` widget is created. Here it is called from the `main` function.
* The example app uses the `flutter_dotenv` package. To run it right away, copy `example/assets/env/.env.sample` to
  `example/assets/env/.env` and put your JavaScript key after `APP_KEY=` inside the `.env` file.
* To use the services features — keyword place search, category place search, address search, coordinate-to-address lookup, and coordinate transformation — you must also set `baseUrl`.
* Put your baseUrl after `BASE_URL=` in `.env`.

``` dart
void main() {
  AuthRepository.initialize(appKey: 'javascript key');
}

or

void main() {
  AuthRepository.initialize(appKey: 'javascript key', baseUrl: 'http://localhost');
}
```

### Android

Declare the INTERNET permission and set `usesCleartextTraffic="true"` in AndroidManifest.xml

``` xml
<manifest>
    <!-- Declares the permission that webview_flutter needs for internet access -->
    <uses-permission android:name="android.permission.INTERNET" />

    <application
    android:usesCleartextTraffic="true">
        ...
    </application>
</manifest>
```

### iOS

Set NSAppTransportSecurity and io.flutter.embedded_views_preview in Info.plist

``` xml
<dict>
    <key>NSAppTransportSecurity</key>
      <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
        <key>NSAllowsArbitraryLoadsInWebContent</key>
        <true/>
      </dict>
    <key>io.flutter.embedded_views_preview</key>
    <true/>
</dict>
```

### Web

On web the map is rendered in an iframe instead of a WebView. It runs with `flutter run -d chrome` without extra setup, but **the map only appears once you register the site domain in the Kakao Developers console.**

1. Go to [Kakao Developers](https://developers.kakao.com) → My Application → Platform → **Web** → Site domain, and add the origin your app is served from. The port is compared exactly, so during development register `http://localhost:port` as-is. (For example, `flutter run -d chrome --web-port=8080` means `http://localhost:8080`.)
2. On an unregistered domain the Kakao SDK returns 401 and the browser console logs a `domain mismatched! caller=...` error.

Differences on web:

* **Wrap Flutter widgets that sit on top of the map with `KakaoMapPointerInterceptor`.** On web the map is an iframe, so buttons and cards placed over it with a `Stack` never receive taps. This widget routes pointer events in the child's area back to Flutter, and on Android/iOS it simply returns the child, so you can use it on every platform. This also applies to things that overlap the map such as `Scaffold`'s `floatingActionButton`.

    ``` dart
    Stack(
      children: [
        KakaoMap(onMapCreated: (c) => mapController = c),
        Positioned(
          top: 16,
          right: 16,
          child: KakaoMapPointerInterceptor(
            child: ElevatedButton(onPressed: () {}, child: const Text('Current location')),
          ),
        ),
      ],
    )
    ```

* `AuthRepository.initialize(baseUrl:)` is ignored. The domain check uses the actual page origin.
* `gestureRecognizers` is not used. Pointer events inside the iframe are handled directly by the browser.
* `KakaoMapController.webViewController` throws a `StateError` on web (there is no WebView). To run JavaScript directly inside the map document regardless of platform, use `controller.runJavaScript()` / `controller.evaluateJavaScript()`.

    ``` dart
    // Calling SDK features the plugin does not wrap yet (Android / iOS / Web)
    await mapController.runJavaScript('map.setCopyrightPosition(kakao.maps.CopyrightPosition.BOTTOMRIGHT);');
    final raw = await mapController.evaluateJavaScript('JSON.stringify(map.getLevel())');
    ```
* Every other map, overlay, Roadview, Drawing, search, and tileset API behaves the same as on mobile.

### Platform differences

| Item | Android | iOS | Web |
|---|---|---|---|
| `gestureRecognizers` | ✅ | ✅ | Ignored (the iframe handles it) |
| `AuthRepository.initialize(baseUrl:)` | ✅ | ✅ | Ignored (the actual origin is checked) |
| `controller.webViewController` | ✅ | ✅ | `StateError` → use `runJavaScript / evaluateJavaScript` |
| Tapping Flutter widgets layered over the map | ✅ | ✅ | Must be wrapped in `KakaoMapPointerInterceptor` |
| HTML re-execution after `reload()` | ✅ | ❌ (WKWebView limitation, recreating the widget is recommended) | ✅ |
| `scrollwheel`, `keyboardShortcuts` | N/A | N/A | ✅ |
| Hover callbacks (`onMarkerMouseOver`, etc.) | ❌ | ❌ | ✅ when a mouse is present (`supportsHover()`) |
| `onMapLongPress` | ✅ | ✅ | ✅ (including right-click) |

### What the Kakao Maps API does not support

These features do not exist in the Kakao JavaScript API itself, so this plugin cannot provide them either.

* Map rotation (bearing), tilt, 3D buildings, indoor maps
* Map style JSON / dark mode base map (only tiles you build yourself as a custom tileset)
* Tap events on POIs (business name labels) drawn into the tiles
* Offline caching of the base map tiles
* Map snapshots (image capture) — the tiles are cross-origin, so they cannot be read from a canvas. Use `KakaoStaticMap` if you need a static map

---

## Migrating from 0.x to 1.0.0

1.0.0 is the first stable release. **No API was removed.** All signatures are unchanged; only the items below behave differently, so check whether your code relies on them.

### APIs with changed behavior

| Before (0.x) | 1.0.0 | What to do |
|---|---|---|
| `controller.clearMarker()` also removed clusterer markers | Removes only regular markers | Call `clearMarkerClusterer()` as well to remove clusterer markers |
| Cluster visuals could remain after `controller.clear()` | Removes the clusterer objects and their markers too | To keep the clusterer, use individual `clearXxx()` calls such as `clearPolyline()` instead of `clear()` |
| `controller.clearMarkerClusterer()` left the markers behind | Releases the clusterer and also removes its markers from the list | Call `addMarker()` again to show the markers |
| `addMarker(markers: [])` and `KakaoMap(markers: [])` were ignored | **Removes all regular markers**, like the other overlays | Pass `null` instead of `[]` to keep the existing markers |
| Re-adding a marker with the same ID was ignored | Updates it if the content changed | Do not call again with the same ID if you want it left alone |
| Overlays passed through widget properties (`markers:`, etc.) had to be drawn manually in `onMapCreated` | Drawn automatically once the map is ready | Remove the duplicate `addMarker()` calls inside `onMapCreated` |
| Search failures (error status, `null` result) were returned as successes | The `Future` completes with an error | Wrap in `try/catch` |
| Overlapping calls of the same search type left the previous `xxxResult()` waiting forever | The previous wait ends with a `StateError` | Use the return value of `controller.keywordSearch()`, or `try/catch` |
| Tapping an `<a href>` inside an info window or custom overlay navigated the WebView and the map disappeared | Navigation is intercepted and reported through `onLinkTap` (ignored when there is no callback) | `KakaoMap(onLinkTap: (url) => launchUrl(url))` |
| Text selection, tap highlight, long-press menus, and page pinch zoom were possible in the map document | All disabled, like a native app | Add `class="kmp-selectable"` to elements that need selection |

``` dart
// Example: code that intended to clear everything
await controller.clearMarker();            // 0.x: also removed the clusterer markers
// 1.0.0
await controller.clearMarker();
await controller.clearMarkerClusterer();   // add this to also remove the clusterer markers

// Example: search
try {
  final result = await controller.keywordSearch(KeywordSearchRequest(keyword: '카페'));
} catch (e) {
  // From 1.0.0 on, failures arrive as exceptions.
}
```

### Deprecated (still working, to be removed in 2.0.0)

| Deprecated | Replacement |
|---|---|
| `MapType.roadMap` | `MapType.normal` (same value) |
| `controller.setStyle(width, height)` | Control the container size with Flutter widgets, and call `controller.relayout()` if needed |
| `controller.getDraggable()` / `getZoomable()` | `isDraggable()` / `isZoomable()` (return `bool` on every platform) |
| `Marker.markerImageSrc` | `Marker.icon` with `MarkerIcon.network(url)`, etc. (the existing string form keeps working) |
| `KakaoMapPluginPlatform`, `MethodChannelKakaoMapPlugin` | Unused template classes. Remove references to them (`KakaoMapPluginWeb` is kept for Web registration) |

### Newly added (no impact on existing code)

* Web support — you must register the site domain in the Kakao Developers console. See the [Web](#web) section above.
* Added the `pointer_interceptor` dependency — it lets Flutter widgets on top of the map receive taps on Web, and has no effect on mobile behavior.
* `AuthRepository.initialize(libraries:)` lets you reduce the Kakao libraries that get loaded. If you do not specify it, everything is loaded as before.
* See the [CHANGELOG](CHANGELOG.md) for the other new widgets and APIs.

## Examples

The samples are based on the examples on the [Kakao maps api](https://apis.map.kakao.com/web/sample/) site.

* Creating a basic map

    ``` dart
    Scaffold(
      body: KakaoMap(),
    );
    ```

* Map creation callback

    ``` dart
    Scaffold(
      body: KakaoMap(
        onMapCreated: ((controller) {
          mapController = controller;
        }),

      ),
    );
    ```

* Creating a marker — adds a marker once the map is created

    ``` dart
    Set<Marker> markers = {}; // marker variable
  
    Scaffold(
      body: KakaoMap(
        onMapCreated: ((controller) async {
          mapController = controller;

          markers.add(Marker(
            markerId: UniqueKey().toString(),
            latLng: await mapController.getCenter(),
          ));

          setState(() { });
        }),
        markers: markers.toList(),
        center: LatLng(37.3608681, 126.9306506),
      ),
    );
    ```

* Creating a marker clusterer — adds markers once the map is created (do not use markers and a clusterer together; put the markers inside the clusterer.)

    ``` dart
    Clusterer? clusterer;
  
    Scaffold(
      body: KakaoMap(
        onMapCreated: ((controller) async {
          mapController = controller;

          Set<Marker> markers = {};
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.27943075229118, 127.01763998406159)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.55915668706214, 126.92536526611102)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.13854258261161, 129.1014781294671)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.55518388656961, 126.92926237742505)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.20618517638034, 129.07944301057026)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.561110808242056, 126.9831268386891)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.86187129655063, 127.7410250820423)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.47160156778542, 126.62818064142286)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.10233410927457, 129.02611815856181)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.10215562270429, 129.02579793018205)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.475423012251106, 128.76666923366042)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.93282824693927, 126.95307628834287)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(36.33884892276137, 127.393666019664)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.520412849636, 126.9742764161581)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.155139675209675, 129.06154773758374)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.816041994696576, 127.11046706211324)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(38.20441110638504, 128.59038671285234)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.586112739308916, 127.02949148517999)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.50380641844987, 127.02130716617751)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.55155704387368, 126.92161115892036)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.55413060051369, 126.92207472929526)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(36.362321615174835, 127.35000483225389)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.55227862908755, 126.92280546294998)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.490413948014606, 127.02079678472444)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.172358507549596, 126.90545394866643)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.15474103200252, 129.11827889154455)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.516081250973485, 127.02369057166361)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(36.80711722863776, 127.14020346037576)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.28957415752673, 127.00103752005424)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.83953896766896, 128.7566880321854)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.51027412948879, 127.08227718124704)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.493581783270294, 126.72541955660554)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.135291862962795, 129.10060911448775)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.174574933144065, 126.91389980787773)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.795887691878654, 127.10660416587146)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.59288687521181, 126.96560524627377)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.45076411130452, 127.14593003749792)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.86008337557079, 127.1263912488061)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.23773491330953, 129.08371037429578)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.524297321304886, 127.05018281937049)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(36.33386658021849, 127.4461721466889)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.72963747546802, 128.27079056365005)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(36.02726828142973, 129.37257233594056)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.0708030360945, 129.0593185494088)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.86835862950247, 128.59755089175871)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(33.51133264696746, 126.51852347452322)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.61284289586752, 127.03120547238589)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.851696038722466, 128.59092937125666)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.59084695083232, 127.01872773588882)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.52114874288784, 129.33573629945764)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(36.362326407439845, 127.33577420148076)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.28941189110747, 127.00446132665141)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.32049801117398, 129.1810343576788)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.53338631541601, 127.00615481678061)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.413461468258156, 126.67735680840826)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.920390371093205, 128.54411720249956)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(36.65489374054824, 127.48374816871991)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.49491987110441, 127.01493134206048)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.64985695608336, 127.14496345268074)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.55686770317417, 127.16927880543041)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.37014007589146, 127.10614330185591)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.5350236507627, 126.96157681184789)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.40549630594667, 126.8980581820004)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(34.867950544005744, 128.69069690081176)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.16317059543225, 128.98452978748048)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(36.607484825953186, 127.48520451195111)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.651724785213986, 126.58306748337554)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.86059690063427, 128.59193087665244)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.25685847585025, 128.59912605060455)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(33.509258155694496, 126.5109451464813)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.64366155701157, 126.63255039247507)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.82667262227336, 127.1030670574823)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.82003554991111, 127.14810974062483)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.097485195649455, 128.99486181862338)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.32204249590605, 127.95591893585816)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.50535127272031, 127.1047465440526)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(36.99081407156533, 127.09338324956647)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.323486640444834, 127.12285239871076)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.78973089440451, 127.13644319545601)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.641373953578196, 129.35463220719618)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.47423127310911, 126.97625029161996)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.84357192991226, 128.61143720719716)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.180974984085736, 128.20294526341132)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.57895718642583, 126.9316897337244)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(33.49077253755052, 126.49314817000993)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(36.42175925330255, 128.67409133225766)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.46405540570109, 126.7153544119173)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.594758776232126, 127.10099917489818)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.7239966558994, 127.0478671731854)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.86680171505329, 128.5923738376741)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.560573727266785, 126.81239107485251)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.78692224857484, 126.98966010341789)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.10368644802913, 129.0206862606022)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.063839948992644, 127.06856523030079)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.34344643728643, 127.94382181350932)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.512521267219064, 127.40054805648133)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.15286653837983, 126.90419903971498)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.173238445546296, 129.176082844468)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(36.082394201323524, 129.40330471725923)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.51043665598106, 127.03974070036524)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(36.627816673285054, 127.44969866021904)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.59194624756919, 127.01817545576053)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.387147045560866, 127.1253365438929)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.89948383848115, 128.60809550730653)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.555316235235324, 127.14038447894715)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(36.09622092762977, 128.43314679004078)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.582855922985544, 126.91907857008522)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.516000983841586, 128.72798872032757)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.48429363675198, 127.0379630203579)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.54502575965604, 126.95429338245707)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.236247173046394, 128.8677618015292)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.40157536691968, 127.11717457214067)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(36.95191038001258, 127.91064040877527)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.491526492971346, 126.85463749525812)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(36.124356479753196, 128.09517052346138)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.15715169307048, 128.15853461363773)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.5808156608605, 126.95109705510639)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.46931787249714, 126.89904775044873)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.52195614910054, 129.3209904841746)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.58625703195563, 126.9496035206742)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.28463639199199, 126.85984474757359)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.534169458631226, 129.31169021536095)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.553341234194285, 127.15481222237025)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(37.62293367990081, 126.83445005122417)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.5272027005698, 127.72953798950101)));
          markers.add(Marker(
              markerId: '${markers.length + 1}',
              latLng: LatLng(35.180032285898854, 128.06954509175367)));
  
          clusterer = Clusterer(
            markers: markers.toList(),
            minLevel: 6,
            gridSize: 45,
            calculator: [30, 60],
            texts: ['Few', 'Medium', 'Many'],
            styles: [
              ClustererStyle(
                width: 50,
                height: 50,
                background: Colors.blue.withOpacity(0.8),
                borderRadius: 25,
                color: Colors.white,
                textAlign: 'center',
                lineHeight: 60,
              ),
              ClustererStyle(
                width: 50,
                height: 50,
                background: Colors.red.withOpacity(0.8),
                borderRadius: 25,
                color: Colors.yellow,
                textAlign: 'center',
                lineHeight: 60,
              ),
              ClustererStyle(
                width: 50,
                height: 50,
                background: Colors.purple.withOpacity(0.8),
                borderRadius: 25,
                color: Colors.white,
                textAlign: 'center',
                lineHeight: 60,
              ),
            ],
          );

          setState(() { });
        }),
        clusterer: clusterer,
        center: LatLng(37.3608681, 126.9306506),
      ),
    );
    ```

* Circle, Polyline, Polygon, and Rectangle example

    ``` dart
    Set<Circle> circles = {};
    Set<Polyline> polylines = {};
    Set<Polygon> polygons = {};
    Set<Rectangle> rectangles = {};
  
    Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: KakaoMap(
        onMapCreated: ((controller) async {
          mapController = controller;

          circles.add(
            Circle(
              circleId: circles.length.toString(),
              center: LatLng(33.450701, 126.570667),
              strokeWidth: 5,
              strokeColor: Colors.red,
              strokeOpacity: 0.5,
              strokeStyle: StrokeStyle.longDashDotDot,
              fillColor: Colors.black,
              fillOpacity: 0.7,
              radius: 50,
            ),
          );

          polylines.add(
            Polyline(
              polylineId: 'polyline_${polylines.length}',
              points: [
                LatLng(33.452344169439975, 126.56878163224233),
                LatLng(33.452739313807456, 126.5709308145358),
                LatLng(33.45178067090639, 126.5726886938753)
              ],
              strokeColor: Colors.purple,
            ),
          );

          polygons.add(
            Polygon(
              polygonId: 'polygon_${polygons.length}',
              points: [
                LatLng(33.45133510810506, 126.57159381623066),
                LatLng(33.44955812811862, 126.5713551811832),
                LatLng(33.449986291544086, 126.57263296172184),
                LatLng(33.450682513554554, 126.57321034054742),
                LatLng(33.451346760004206, 126.57235740081413)
              ],
              strokeWidth: 4,
              strokeColor: Colors.blue,
              strokeOpacity: 1,
              strokeStyle: StrokeStyle.shortDashDot,
              fillColor: Colors.black,
              fillOpacity: 0.3,
            ),
          );
  
          rectangles.add(
            Rectangle(
              rectangleId: 'rectangle_${rectangles.length}',
              rectangleBounds: LatLngBounds(
                LatLng(33.42133510810506, 126.53159381623066),
                LatLng(33.44955812811862, 126.5713551811832),
              ),
              strokeWidth: 6,
              strokeColor: Colors.blue,
              strokeOpacity: 1,
              strokeStyle: StrokeStyle.dot,
              fillColor: Colors.black,
              fillOpacity: 0.7,
            ),
          );

          setState(() {});
        }),
        circles: circles.toList(),
        polylines: polylines.toList(),
        polygons: polygons.toList(),
        rectangles: rectangles.toList(),
        center: LatLng(33.450701, 126.570667),
      ),
    );
    ```

* Choosing which extension libraries to load — the default is all of them (`services`, `clusterer`, `drawing`). Dropping libraries you do not use makes map creation slightly faster.

    ``` dart
    // App-wide default
    AuthRepository.initialize(
      appKey: 'YOUR_JAVASCRIPT_KEY',
      libraries: {KakaoMapLibrary.services},
    );

    // Override per widget (clusterer is included automatically when you use one)
    KakaoMap(
      libraries: const {KakaoMapLibrary.services, KakaoMapLibrary.drawing},
    );
    ```

* Creating a Roadview — use the `KakaoRoadviewController` from `onRoadviewCreated` to move the panorama and control the viewpoint.

    ``` dart
    KakaoRoadviewController? roadviewController;

    Scaffold(
      body: KakaoRoadMap(
        center: LatLng(33.450701, 126.570667),
        radius: 50,
        viewpoint: const Viewpoint(pan: 90, tilt: 0, zoom: 0),
        markers: [
          Marker(
            markerId: 'm1',
            latLng: LatLng(33.450701, 126.570667),
            altitude: 5,   // Height (m) at which the marker sits in the Roadview
            range: 100,    // Radius (m) within which the marker is visible
          ),
        ],
        onRoadviewCreated: (controller) => roadviewController = controller,
        onViewpointChange: (viewpoint) => print('pan ${viewpoint.pan}'),
        onRoadviewNotFound: (latLng) => print('No Roadview at this location.'),
      ),
    );

    // Move to the nearest panorama at another location
    await roadviewController?.setPanoIdNear(LatLng(37.566826, 126.9786567));
    await roadviewController?.setViewpoint(const Viewpoint(pan: 180, tilt: 0, zoom: 1));
    ```

* Using a map and a Roadview together — move the Roadview by clicking the map on a single screen, and the MapWalker on the map follows the Roadview's viewing direction.

    ``` dart
    KakaoMapRoadviewController? linkController;

    Scaffold(
      body: KakaoMapRoadviewView(
        center: LatLng(33.450701, 126.570667),
        initialViewMode: RoadviewViewMode.split, // map / roadview / split
        splitRatio: 50,                          // Map ratio (%) in split mode
        showRoadviewOverlay: true,               // Show roads that have Roadview coverage
        useMapWalker: true,
        onCreated: (controller) => linkController = controller,
      ),
    );

    await linkController?.toggleRoadview(LatLng(33.450701, 126.570667));
    await linkController?.setViewMode(RoadviewViewMode.roadview);
    ```

* Drawing Library — let users draw markers, lines, polygons, circles, and more on the map, then read the result back as data.

    ``` dart
    late KakaoMapController mapController;

    Scaffold(
      body: KakaoMap(
        onMapCreated: ((controller) async {
          mapController = controller;

          await mapController.createDrawingManager(
            options: const DrawingOptions(
              drawingMode: [
                DrawingOverlayType.marker,
                DrawingOverlayType.polyline,
                DrawingOverlayType.polygon,
              ],
              polylineStyle: DrawingStyle(strokeColor: Colors.blue, strokeWidth: 3),
            ),
          );
          await mapController.showDrawingToolbox(); // Kakao's built-in toolbox UI (optional)
          await mapController.selectDrawingMode(DrawingOverlayType.polyline);
        }),
        onDrawingEnd: (type) async {
          final data = await mapController.getDrawingData();
          for (final line in data.polylines) {
            print('line points: ${line.points.length}');
          }
        },
      ),
    );

    // Undo / redo / cancel the shape being drawn
    await mapController.undoDrawing();
    await mapController.redoDrawing();
    await mapController.cancelDrawing();
    ```

* Custom tilesets — use your own tile images as the base map, or overlay them on the existing map.

    ``` dart
    // 1) URL template ({x} {y} {z} are substituted)
    await mapController.addTileset(const Tileset(
      id: 'MY_TILES',
      urlTemplate: 'https://tiles.example.com/{z}/{y}/{x}.png',
      copyright: [TilesetCopyright('© Example')],
    ));
    await mapController.setTileset('MY_TILES');         // Use as the base map
    await mapController.setMapTypeId(MapType.normal);   // Back to the normal map

    // 2) DOM tiles (pass the JavaScript function source as-is)
    await mapController.addTileset(const Tileset(
      id: 'TILE_NUMBER',
      tileFunction: '''
        function (x, y, z) {
          var div = document.createElement('div');
          div.innerHTML = x + ', ' + y + ', ' + z;
          div.style.border = '1px dashed #ff5050';
          return div;
        }
      ''',
    ));
    await mapController.addOverlayTileset('TILE_NUMBER');    // Overlay on the map
    await mapController.removeOverlayTileset('TILE_NUMBER');
    ```

    `urlFunction` / `tileFunction` are executed verbatim inside the WebView, so only pass strings your app wrote itself.

* Making it feel like an app — info window styles, themes, Flutter controls, and widget markers

    The UI the Kakao SDK draws itself (info windows, zoom and map type controls, clusters, default markers) looks like a web page. The features below let you match your app's design. If you do not set them, the original appearance is kept.

    ``` dart
    // 1) Info window — per marker, or as a map-wide default via a theme
    Marker(
      markerId: 'm1',
      latLng: LatLng(37.5665, 126.9780),
      infoWindowContent: '<b>서울시청</b><br>02-120',
      infoWindowStyle: const InfoWindowStyle.material(),   // .cupertino(), .dark(), or your own
    );

    // 2) Theme — global (AuthRepository.initialize(theme:)) or per map
    KakaoMap(
      theme: const KakaoMapTheme(
        infoWindowStyle: InfoWindowStyle.material(),
        backgroundColor: Color(0xFFEFF3F6),   // Background before tiles load (instead of the SDK's gray grid)
        fontFamily: 'Pretendard, sans-serif', // Defaults to the system font stack
      ),
      copyrightPosition: CopyrightPosition.bottomLeft, // Keeps it clear of the bottom-right buttons
    );

    // 3) Flutter controls — layer them with a Stack instead of the SDK controls (they work on web too)
    Stack(children: [
      KakaoMap(onMapCreated: (c) => setState(() => controller = c)),
      if (controller != null) KakaoMapControls(controller: controller!, showMapType: true),
    ]);
    KakaoDrawingToolbar(controller: controller!, modes: const [DrawingOverlayType.polyline, DrawingOverlayType.polygon]);

    // 4) Markers — a pin with a different color, or a Flutter widget rendered as a marker
    Marker(markerId: 'p', latLng: latLng, icon: MarkerIcon.pin(color: Colors.red), width: 28, height: 40, offsetX: 14, offsetY: 40);
    final tag = await MarkerIcon.fromWidget(PriceTag('12,000원'), logicalSize: const Size(96, 44));
    Marker(markerId: 't', latLng: latLng, icon: tag, width: 96, height: 44, offsetX: 48, offsetY: 44);

    // 5) Clusters — round Material preset
    Clusterer(markers: markers, styles: [ClustererStyle.material(Colors.indigo, size: 48)]);
    ```

* Flutter widget overlays — attach real Flutter widgets to map coordinates

    ``` dart
    KakaoMap(
      widgetOverlays: [
        KakaoMapWidgetOverlay(
          id: 'cafe',
          position: LatLng(37.5665, 126.9780),
          anchor: Alignment.bottomCenter,           // Aligns the widget's bottom center to the coordinate
          child: GestureDetector(
            onTap: () => showModalBottomSheet(...), // Pattern for continuing into your app's UI on tap
            child: Card(child: Padding(padding: EdgeInsets.all(8), child: Text('카페 · 4,500원'))),
          ),
        ),
      ],
    )
    ```

    When the map moves, JS sends the pixel coordinates so the widgets follow along (once per frame). They work on web too. Use `CustomOverlay` if you need hundreds or more.

* Overlay events and long press

    ``` dart
    KakaoMap(
      onPolylineTap: (id, latLng, level) {},   // Line / circle / rectangle taps (use onPolygonTap for polygons)
      onCircleTap: (id, latLng, level) {},
      onRectangleTap: (id, latLng, level) {},
      onMapLongPress: (latLng) {},             // Press for 0.5s or longer (right-click too on mouse environments)
    )
    ```

* Mouse hover — **only on environments with a mouse pointer (desktop browsers)**

    These are never called on touch devices, so handle the tap callbacks as well. You can check the runtime environment with `await controller.supportsHover()`.

    ``` dart
    KakaoMap(
      onMarkerMouseOver: (id, latLng, level) {},   // onMarkerMouseOut
      onPolygonMouseOver: (id, latLng, level) {},  // onPolygonMouseMove (once per frame) / onPolygonMouseOut
      onMarkerTap: (id, latLng, level) {},         // Touch fallback
    )
    ```

* Marker options and partial updates

    ``` dart
    Marker(
      markerId: 'bus', latLng: latLng,
      opacity: 0.6, clickable: false, title: 'tooltip (web)', visible: true,
      // Crop from a sprite sheet
      markerImageSrc: 'https://…/sprite.png', width: 36, height: 37,
      spriteOrigin: Point(0, 46), spriteWidth: 36, spriteHeight: 691,
    );
    await controller.setMarkerPosition('bus', newLatLng); // Move without recreating (live positions)
    await controller.setMarkerVisible('bus', false);
    await controller.showInfoWindow('bus');                 // List tap → open the info window on the map
    await controller.hideInfoWindow('bus');
    ```

* Search pagination info

    ``` dart
    final r = await controller.keywordSearch(KeywordSearchRequest(keyword: '카페', size: 15, page: 1));
    if (r.pagination?.hasNextPage == true) {
      final next = await controller.keywordSearch(KeywordSearchRequest(keyword: '카페', size: 15, page: 2));
    }
    ```

* Opening the KakaoMap app (directions, places, Roadview) — the plugin only builds the URL; launch it with `url_launcher`

    ``` dart
    // Web link: opens the app when installed, otherwise the mobile web (recommended)
    final uri = KakaoMapLinks.web.route(to: LatLng(37.5665, 126.9780), toName: '서울시청', mode: KakaoMapRouteMode.transit);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    // App scheme: kakaomap:// (on iOS add kakaomap to LSApplicationQueriesSchemes; fall back to KakaoMapLinks.storeUrl())
    KakaoMapLinks.app.route(to: LatLng(37.5665, 126.9780), mode: KakaoMapRouteMode.car);
    ```

* Static map — when you need a map image that does not move (list thumbnails, share previews, and so on)

    ``` dart
    KakaoStaticMap(
      center: LatLng(33.450701, 126.570667),
      currentLevel: 3,
      markers: [
        Marker(markerId: 'm1', latLng: LatLng(33.450701, 126.570667), infoWindowContent: '카카오'),
      ],
    )
    ```

* Camera control and measurement

    ``` dart
    // Center and level at once, with an animation duration
    await mapController.jump(LatLng(37.5665, 126.9780), 5, animate: true, duration: const Duration(milliseconds: 400));
    // Move so that a bounds area is visible (padding in px)
    await mapController.panToBounds(LatLngBounds(LatLng(37.55, 126.96), LatLng(37.58, 127.0)), padding: 48);
    await mapController.fitBounds(points, padding: 48);
    // Push the map up when a bottom sheet opens
    await mapController.panBy(0, -150);
    // Limit the zoom range (changes to KakaoMap(minLevel:, maxLevel:) on rebuild are applied too)
    await mapController.setMinLevel(2);
    await mapController.setMaxLevel(10);

    // Length (m) and area (㎡) calculated by the SDK
    final meters = await mapController.getPolylineLength('route');
    final squareMeters = await mapController.getPolygonArea('area');
    ```

* Map creation options and events

    ``` dart
    KakaoMap(
      mapTypeId: MapType.skyView,        // Start in sky view
      disableDoubleClickZoom: true,      // Turn off double-tap zoom
      onMapTypeChanged: (type) => print('map type: $type'),
      // Links inside info windows and custom overlays arrive in this callback instead of navigating the WebView.
      onLinkTap: (url) => launchUrl(url, mode: LaunchMode.externalApplication),
    )
    ```

More Kakao Map sample code is available **[here](https://github.com/johyunchol/kakao_map_plugin/tree/main/example)**.

---

## Screenshots

![example](https://github.com/johyunchol/kakao_map_plugin/blob/main/assets/videos/example.gif?raw=true)

### Web

The same code runs as-is in the browser. (Chrome, `flutter run -d chrome`)

| Map | Map + Roadview (MapWalker) | Drawing Library |
|---|---|---|
| ![web map](https://github.com/johyunchol/kakao_map_plugin/blob/main/assets/images/web_map.png?raw=true) | ![web roadview](https://github.com/johyunchol/kakao_map_plugin/blob/main/assets/images/web_roadview.png?raw=true) | ![web drawing](https://github.com/johyunchol/kakao_map_plugin/blob/main/assets/images/web_drawing.png?raw=true) |
