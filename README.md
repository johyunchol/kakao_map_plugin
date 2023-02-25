# kakao_map_plugin

[![pub package](https://img.shields.io/pub/v/kakao_map_plugin.svg?color=4285F4)](https://pub.dev/packages/kakao_map_plugin)

**[카카오 지도](https://apis.map.kakao.com/web/guide)** 를 구동할 수 있는 Flutter 플러그인 입니다.

네이티브 라이브러리를 사용한 것이 아닌 Javascript 라이브러리를 이용하여 제작한 플러그인 입니다.

`webview_flutter` package 를 사용하고 있어서 Android, iOS 최소 버전 확인이 필요합니다.

|             | Android        | iOS  |
|-------------|----------------|------|
| **Support** | SDK 19+ or 20+ | 9.0+ |

---

## 시작하기

### 공통

**[카카오 개발자센터](https://developers.kakao.com/)** 에서 javascript key 를 발급받아야 합니다.

`pubspec.yaml`에 dependencies에 작성

``` yaml
dependencies:
  kakao_map_plugin: [최신버전]
```

1. javascript key 등록

* Singleton 으로 되어 있어서 KakaoMap 위젯이 호출 되기 전에만 initialize 하면 됩니다. 여기서는 main 함수에서 호출하도록 했습니다.
* example 에서는 flutter_dotenv 라이브러리를 사용하였습니다. 바로 실행해 보시려면 `example/assets/env/.env.sample`을 복사하여 `example/assets/env/.env`로 만들어주시고 `.env` 파일 내부에 `APP_KEY=`뒤에 본인의 javascript key 를 넣으시면 됩니다.

``` dart
void main() {
  AuthRepository.initialize(appKey: 'javascript key');
}
```

### Android

AndroidManifest.xml 에 INTERNET 권한 및 usesCleartextTraffic="true" 설정

``` xml
<manifest>
    <!-- webview_flutter 에서 인터넷 접속을 위한 권한을 선언합니다 -->
    <uses-permission android:name="android.permission.INTERNET" />

    <application
    android:usesCleartextTraffic="true">
        ...
    </application>
</manifest>
```

### iOS

Info.plist 에 NSAppTransportSecurity 권한 및 io.flutter.embedded_views_preview 설정

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

---

## 예제

[Kakao maps api](https://apis.map.kakao.com/web/sample/) 사이트에 있는 예제를 기준으로 샘플을 만들었습니다.

* 기본 지도 생성

    ``` dart
    Scaffold(
      body: KakaoMap(),
    );
    ```

* 맵 생성 callback

    ``` dart
    Scaffold(
      body: KakaoMap(
        onMapCreated: ((controller) {
          mapController = controller;
        }),

      ),
    );
    ```

* 마커 생성 - 지도가 생성되면 마커 추가되는 예제

    ``` dart
    Set<Marker> markers = {}; // 마커 변수
  
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

* Circle, Polyline, Polygon, Rectangle 예제

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

더 많은 카카오지도 샘플소스는 **[여기](https://github.com/johyunchol/kakao_map_plugin/tree/main/example)** 에서 확인하실 수 있습니다.

---

## 실행화면

![example](https://github.com/johyunchol/kakao_map_plugin/blob/main/assets/videos/example.gif?raw=true)