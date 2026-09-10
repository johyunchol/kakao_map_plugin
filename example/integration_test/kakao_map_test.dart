import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

/// 실제 WebView + 카카오 SDK 위에서 오버레이 동기화/배치 전송/검색 라우팅을 검증합니다.
///
/// 실행: cd example && flutter test integration_test/kakao_map_test.dart -d <device>

/// KakaoMap 에 전달할 속성 묶음. 값이 바뀌면 [MapHost] 가 rebuild 됩니다.
class MapProps {
  final LatLng? center;
  final List<Marker>? markers;
  final List<Polyline>? polylines;
  final List<Circle>? circles;
  final List<Rectangle>? rectangles;
  final List<Polygon>? polygons;
  final List<CustomOverlay>? customOverlays;
  final Clusterer? clusterer;
  final Set<KakaoMapLibrary>? libraries;
  final OnLinkTap? onLinkTap;
  final KakaoMapTheme? theme;

  const MapProps({
    this.center,
    this.markers,
    this.polylines,
    this.circles,
    this.rectangles,
    this.polygons,
    this.customOverlays,
    this.clusterer,
    this.libraries,
    this.onLinkTap,
    this.theme,
  });
}

class MapHost extends StatelessWidget {
  final ValueNotifier<MapProps> props;
  final ValueNotifier<int> rebuildTick;
  final Completer<KakaoMapController> ready;

  const MapHost({
    super.key,
    required this.props,
    required this.rebuildTick,
    required this.ready,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ValueListenableBuilder<int>(
          valueListenable: rebuildTick,
          builder: (_, __, ___) => ValueListenableBuilder<MapProps>(
            valueListenable: props,
            builder: (_, p, __) => KakaoMap(
              onMapCreated: (c) {
                if (!ready.isCompleted) ready.complete(c);
              },
              onMapTap: (_) {},
              onMarkerTap: (_, __, ___) {},
              onCustomOverlayTap: (_, __) {},
              onMarkerClustererTap: (_, __, ___) {},
              center: p.center ?? LatLng(37.5665, 126.9780),
              markers: p.markers,
              polylines: p.polylines,
              circles: p.circles,
              rectangles: p.rectangles,
              polygons: p.polygons,
              customOverlays: p.customOverlays,
              clusterer: p.clusterer,
              libraries: p.libraries,
              onLinkTap: p.onLinkTap,
              theme: p.theme,
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> pumpFor(WidgetTester tester, Duration duration) async {
  final end = DateTime.now().add(duration);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 50));
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

/// JS 표현식을 평가해 JSON 으로 디코드한 값을 돌려줍니다.
///
/// 결과를 `{v: expr}` 로 감싸 undefined/null 도 안전하게 받고,
/// Android 가 문자열 결과를 JSON 문자열 리터럴로 한 번 더 감싸는 것도 처리합니다.
Future<dynamic> js(KakaoMapController c, String expr) async {
  final raw = await c.evaluateJavaScript(
      'JSON.stringify({v: (function(){ try { return ($expr); } '
      'catch (e) { return "__js_error__: " + String(e); } })()})');
  dynamic value = raw;
  if (value is String) {
    value = jsonDecode(value);
    if (value is String) value = jsonDecode(value);
  }
  final unwrapped = (value as Map)['v'];
  if (unwrapped is String && unwrapped.startsWith('__js_error__')) {
    fail('JS 평가 실패 ($expr): $unwrapped');
  }
  return unwrapped;
}

/// [expr] 이 true 가 될 때까지 폴링합니다. 첫 WebView 로드 직후처럼 JS 스레드가
/// 바쁜 상황에서도 "결국 반영된다"를 검증하기 위한 헬퍼입니다.
Future<void> waitUntil(WidgetTester tester, KakaoMapController c, String expr,
    {Duration timeout = const Duration(seconds: 15)}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    if (await js(c, expr) == true) return;
    await pumpFor(tester, const Duration(milliseconds: 200));
  }
  fail('시간 내에 조건이 충족되지 않았습니다: $expr (현재 값: ${await js(c, expr)})');
}

Future<int> jsInt(KakaoMapController c, String expr) async =>
    ((await js(c, expr)) as num).toInt();

Future<void> installErrorTrap(KakaoMapController c) async {
  await c.runJavaScript('''
    window.__errs = [];
    window.onerror = function (msg, src, line) { window.__errs.push(String(msg) + '@' + line); };
    window.addEventListener('unhandledrejection', function (e) { window.__errs.push('rejection:' + String(e.reason)); });
  ''');
}

Future<void> expectNoJsErrors(KakaoMapController c) async {
  final errs = await js(c, 'window.__errs');
  expect(errs, isEmpty, reason: 'JS 오류 발생(테스트 트랩): $errs');
  // 페이지 로드 시점부터 라이브러리가 수집한 오류 (트랩 설치 전 발생분 포함)
  final libErrs = await js(c, 'window.__kakaoMapErrors');
  expect(libErrs, isEmpty, reason: 'JS 오류 발생(로드 이후 전체): $libErrs');
}

List<Marker> sampleMarkers() => [
      Marker(markerId: 'm1', latLng: LatLng(37.5665, 126.9780), zIndex: 1),
      Marker(
        markerId: 'm2',
        latLng: LatLng(37.5670, 126.9790),
        infoWindowContent: '<div>He said "hi" & \'bye\'\n</div>',
        infoWindowFirstShow: true,
      ),
      Marker(
        markerId: "m3'quote",
        latLng: LatLng(37.5660, 126.9770),
        markerImageSrc:
            'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/markerStar.png',
        width: 24,
        height: 35,
      ),
    ];

MapProps sampleProps({List<Marker>? markers}) => MapProps(
      markers: markers ?? sampleMarkers(),
      polylines: [
        Polyline(
          polylineId: 'p1',
          points: [LatLng(37.5665, 126.9780), LatLng(37.5675, 126.9800)],
          strokeColor: Colors.red,
        ),
      ],
      circles: [
        Circle(
            circleId: 'c1',
            center: LatLng(37.5665, 126.9780),
            radius: 100,
            strokeColor: Colors.blue),
      ],
      rectangles: [
        Rectangle(
          rectangleId: 'r1',
          rectangleBounds:
              LatLngBounds(LatLng(37.5660, 126.9770), LatLng(37.5670, 126.9790)),
        ),
      ],
      polygons: [
        Polygon(
          polygonId: 'g1',
          points: [
            LatLng(37.5650, 126.9750),
            LatLng(37.5655, 126.9770),
            LatLng(37.5645, 126.9770),
          ],
          strokeStyle: StrokeStyle.dash,
        ),
        Polygon(
          polygonId: 'g2',
          points: [
            LatLng(37.5680, 126.9750),
            LatLng(37.5690, 126.9770),
            LatLng(37.5670, 126.9770),
          ],
          holes: [
            [
              LatLng(37.5680, 126.9758),
              LatLng(37.5684, 126.9764),
              LatLng(37.5676, 126.9764),
            ]
          ],
        ),
      ],
      customOverlays: [
        CustomOverlay(
          customOverlayId: 'o1',
          latLng: LatLng(37.5665, 126.9780),
          content: '<div style="padding:4px;background:#fff">`tick` "q" \'s\'</div>',
        ),
      ],
    );

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await dotenv.load(fileName: 'assets/env/.env');
    AuthRepository.initialize(
      appKey: dotenv.env['APP_KEY'] ?? '',
      baseUrl: dotenv.env['BASE_URL'] ?? '',
    );
  });

  late ValueNotifier<MapProps> props;
  late ValueNotifier<int> tick;
  late Completer<KakaoMapController> ready;

  Future<KakaoMapController> mount(WidgetTester tester, MapProps initial) async {
    props = ValueNotifier(initial);
    tick = ValueNotifier(0);
    ready = Completer();
    await tester.pumpWidget(MapHost(props: props, rebuildTick: tick, ready: ready));
    // web 에서는 프레임이 그려져야 HtmlElementView(iframe)가 문서에 붙으므로,
    // 준비될 때까지 프레임을 계속 펌프하면서 기다린다.
    final deadline = DateTime.now().add(const Duration(seconds: 40));
    while (!ready.isCompleted) {
      if (DateTime.now().isAfter(deadline)) {
        fail('onMapCreated 가 40초 안에 호출되지 않았습니다.');
      }
      await pumpFor(tester, const Duration(milliseconds: 200));
    }
    final c = await ready.future;
    await pumpFor(tester, const Duration(seconds: 2));
    await installErrorTrap(c);
    return c;
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await pumpFor(tester, const Duration(milliseconds: 500));
  }

  testWidgets('위젯 속성으로 넘긴 초기 오버레이가 onMapCreated 시점에 모두 그려진다', (tester) async {
    final c = await mount(tester, sampleProps());

    // 첫 WebView 로드 직후에는 JS 스레드가 바쁠 수 있으므로 반영될 때까지 기다린다.
    await waitUntil(tester, c, 'markerIndex.size === 3 && customOverlayIndex.size === 1');
    expect(await jsInt(c, 'markerIndex.size'), 3);
    expect(await jsInt(c, 'markers.length'), 3);
    expect(await jsInt(c, 'polylineIndex.size'), 1);
    expect(await jsInt(c, 'circleIndex.size'), 1);
    expect(await jsInt(c, 'rectangleIndex.size'), 1);
    expect(await jsInt(c, 'polygonIndex.size'), 2);
    expect(await jsInt(c, 'customOverlayIndex.size'), 1);

    // 도형에도 id 가 부여된다 (이전에는 undefined 였음)
    expect(await js(c, 'polylines[0].id'), 'p1');
    expect(await js(c, 'polygons.map(p => p.id).sort()'), ['g1', 'g2']);
    // 인포윈도우 콘텐츠가 원형 그대로 전달된다
    expect(await js(c, "markerIndex.get('m2').__infoWindow.getContent()"),
        '<div>He said "hi" & \'bye\'\n</div>');
    // 따옴표가 있는 ID 도 그대로 인덱싱된다
    expect(await js(c, "markerIndex.has(\"m3'quote\")"), true);

    await expectNoJsErrors(c);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('내용이 같은 rebuild 는 오버레이를 재생성하지 않는다', (tester) async {
    final c = await mount(tester, sampleProps());

    await c.runJavaScript('''
      markerIndex.get('m1').__tag = 1;
      polylineIndex.get('p1').__tag = 1;
      circleIndex.get('c1').__tag = 1;
      rectangleIndex.get('r1').__tag = 1;
      polygonIndex.get('g2').__tag = 1;
      customOverlayIndex.get('o1').__tag = 1;
    ''');

    // 1) 부모 rebuild (속성 동일 인스턴스)
    tick.value++;
    await pumpFor(tester, const Duration(milliseconds: 800));
    // 2) 내용은 같지만 새 인스턴스
    props.value = sampleProps();
    await pumpFor(tester, const Duration(milliseconds: 800));

    expect(await js(c, "markerIndex.get('m1').__tag"), 1);
    expect(await js(c, "polylineIndex.get('p1').__tag"), 1);
    expect(await js(c, "circleIndex.get('c1').__tag"), 1);
    expect(await js(c, "rectangleIndex.get('r1').__tag"), 1);
    expect(await js(c, "polygonIndex.get('g2').__tag"), 1);
    expect(await js(c, "customOverlayIndex.get('o1').__tag"), 1);
    expect(await jsInt(c, 'markerIndex.size'), 3);

    await expectNoJsErrors(c);
    await unmount(tester);
  });

  testWidgets('같은 ID 마커의 좌표가 바뀌면 해당 마커만 갱신된다', (tester) async {
    final c = await mount(tester, sampleProps());
    await c.runJavaScript('''
      markerIndex.get('m1').__tag = 1;
      markerIndex.get('m2').__tag = 1;
    ''');

    final moved = sampleMarkers();
    moved[0] = Marker(markerId: 'm1', latLng: LatLng(37.5700, 126.9800), zIndex: 1);
    props.value = sampleProps(markers: moved);
    await pumpFor(tester, const Duration(milliseconds: 800));

    expect(await js(c, "markerIndex.get('m1').__tag"), isNull); // 재생성됨
    expect(await js(c, "markerIndex.get('m2').__tag"), 1); // 유지됨
    final lat = (await js(c, "markerIndex.get('m1').getPosition().getLat()")) as num;
    expect(lat, closeTo(37.5700, 1e-6));
    expect(await jsInt(c, 'markerIndex.size'), 3);

    await expectNoJsErrors(c);
    await unmount(tester);
  });

  testWidgets('addPolyline 은 목록에 없는 기존 폴리라인을 제거한다 (id 기반 retain)', (tester) async {
    final c = await mount(tester, sampleProps());
    expect(await js(c, 'polylines.map(p => p.id)'), ['p1']);

    await c.addPolyline(polylines: [
      Polyline(
        polylineId: 'p2',
        points: [LatLng(37.5600, 126.9700), LatLng(37.5610, 126.9710)],
      ),
    ]);
    await pumpFor(tester, const Duration(milliseconds: 300));

    expect(await js(c, 'polylines.map(p => p.id)'), ['p2']);
    expect(await js(c, "polylineIndex.get('p2').getMap() !== null"), true);

    await expectNoJsErrors(c);
    await unmount(tester);
  });

  testWidgets('클러스터러 마커와 일반 마커가 분리 관리된다', (tester) async {
    final clusterMarkers = List.generate(
      20,
      (i) => Marker(
        markerId: 'cl$i',
        latLng: LatLng(37.5665 + i * 0.0005, 126.9780 + i * 0.0005),
      ),
    );
    final c = await mount(
      tester,
      MapProps(
        markers: sampleMarkers(),
        clusterer: Clusterer(
          markers: clusterMarkers,
          gridSize: 60,
          minLevel: 1,
          disableClickZoom: false,
          styles: [ClustererStyle(width: 40, height: 40, background: Colors.orange)],
        ),
      ),
    );

    expect(await jsInt(c, 'markerIndex.size'), 23);
    expect(await jsInt(c, 'clustererMarkerIds.size'), 20);
    expect(await js(c, 'clusterer !== null'), true);
    // disableClickZoom 파라미터가 실제로 반영된다 (이전에는 true 하드코딩)
    expect(await js(c, 'clusterer.getDisableClickZoom ? clusterer.getDisableClickZoom() : false'), false);

    // 일반 마커 clear 는 클러스터러 마커를 건드리지 않는다
    await c.clearMarker();
    await pumpFor(tester, const Duration(milliseconds: 300));
    expect(await jsInt(c, 'markerIndex.size'), 20);

    // 클러스터러 clear 는 자기 마커만 제거한다
    await c.addMarker(markers: sampleMarkers());
    await c.clearMarkerClusterer();
    await pumpFor(tester, const Duration(milliseconds: 300));
    expect(await jsInt(c, 'markerIndex.size'), 3);
    expect(await jsInt(c, 'clustererMarkerIds.size'), 0);
    expect(await js(c, 'clusterer'), isNull);

    await expectNoJsErrors(c);
    await unmount(tester);
  });

  testWidgets('setMarkerDraggable 이 실제로 동작한다', (tester) async {
    final c = await mount(tester, sampleProps());
    expect(await js(c, "markerIndex.get('m2').getDraggable()"), false);
    await c.setMarkerDraggable('m2', true);
    await pumpFor(tester, const Duration(milliseconds: 200));
    expect(await js(c, "markerIndex.get('m2').getDraggable()"), true);
    await expectNoJsErrors(c);
    await unmount(tester);
  });

  testWidgets('마커 500개가 소수의 브릿지 호출로 추가된다', (tester) async {
    final c = await mount(tester, const MapProps());
    final many = List.generate(
      500,
      (i) => Marker(
        markerId: 'bulk$i',
        latLng: LatLng(37.50 + (i % 25) * 0.004, 126.90 + (i ~/ 25) * 0.004),
      ),
    );

    final sw = Stopwatch()..start();
    await c.addMarker(markers: many);
    sw.stop();
    await pumpFor(tester, const Duration(milliseconds: 500));

    expect(await jsInt(c, 'markerIndex.size'), 500);
    expect(await jsInt(c, 'markers.length'), 500);
    // ignore: avoid_print
    print('[perf] addMarker x500 took ${sw.elapsedMilliseconds} ms');
    expect(sw.elapsedMilliseconds, lessThan(10000));

    // 동일 내용 재전송은 전부 skip 되어야 한다
    await c.runJavaScript("markerIndex.get('bulk0').__tag = 1;");
    await c.addMarker(markers: many);
    await pumpFor(tester, const Duration(milliseconds: 300));
    expect(await js(c, "markerIndex.get('bulk0').__tag"), 1);

    await expectNoJsErrors(c);
    await unmount(tester);
  });

  testWidgets('동시에 보낸 검색 요청이 각자의 결과를 받는다', (tester) async {
    final c = await mount(tester, const MapProps());

    final f1 = c.keywordSearch(KeywordSearchRequest(keyword: '카카오프렌즈', size: 1));
    final f2 = c.keywordSearch(KeywordSearchRequest(keyword: '스타벅스', size: 3));
    final f3 = c.addressSearch(AddressSearchRequest(addr: '전북 삼성동 100'));

    final r1 = await f1.timeout(const Duration(seconds: 20));
    final r2 = await f2.timeout(const Duration(seconds: 20));
    final r3 = await f3.timeout(const Duration(seconds: 20));

    expect(r1.list, hasLength(1));
    expect(r2.list, hasLength(3));
    expect(r3.list, isNotEmpty);

    // 작은따옴표가 포함된 검색어도 JS 오류 없이 처리된다
    final r4 = await c
        .keywordSearch(KeywordSearchRequest(keyword: "Dunkin' Donuts", size: 1))
        .timeout(const Duration(seconds: 20));
    expect(r4.list.length, lessThanOrEqualTo(1));

    await expectNoJsErrors(c);
    await unmount(tester);
  });

  testWidgets('JS 상태가 초기화되고 onMapCreated 가 다시 발화해도 오버레이가 복구된다',
      (tester) async {
    final c = await mount(tester, sampleProps());
    await waitUntil(tester, c, 'markerIndex.size === 3');

    // WebView 페이지 재로드(Android 렌더러 복구 등)와 동일한 상황을 재현한다.
    // JS 측 오버레이 상태를 전부 비우고 onMapCreated 를 다시 발화시킨다.
    await c.runJavaScript('''
      markerIndex.clear();
      polylineIndex.clear();
      circleIndex.clear();
      rectangleIndex.clear();
      polygonIndex.clear();
      customOverlayIndex.clear();
      clustererMarkerIds = new Set();
      syncOverlayArrays();
      onMapCreated.postMessage(JSON.stringify({ ready: true }));
    ''');
    await pumpFor(tester, const Duration(milliseconds: 500));

    // Dart 쪽 시그니처 캐시가 무효화되어 위젯 속성 오버레이가 다시 그려져야 한다.
    await waitUntil(tester, c, 'markerIndex.size === 3',
        timeout: const Duration(seconds: 20));
    expect(await jsInt(c, 'polylineIndex.size'), 1);
    expect(await jsInt(c, 'customOverlayIndex.size'), 1);

    await expectNoJsErrors(c);
    await unmount(tester);
  });

  testWidgets('Android: reload() 후에도 오버레이가 복구된다', (tester) async {
    // iOS(WKWebView) 는 loadHtmlString 으로 띄운 문서를 reload() 하면 HTML 을 다시
    // 실행하지 않아 페이지가 비어버립니다. 플랫폼 동작이라 Android 에서만 검증합니다.
    final c = await mount(tester, sampleProps());
    await waitUntil(tester, c, 'markerIndex.size === 3');

    await c.webViewController.reload();
    await pumpFor(tester, const Duration(seconds: 3));

    await waitUntil(tester, c, 'markerIndex.size === 3',
        timeout: const Duration(seconds: 25));
    expect(await jsInt(c, 'polylineIndex.size'), 1);
    expect(await jsInt(c, 'customOverlayIndex.size'), 1);

    await installErrorTrap(c);
    await expectNoJsErrors(c);
    await unmount(tester);
  }, skip: kIsWeb || defaultTargetPlatform != TargetPlatform.android);

  testWidgets('오버레이 목록을 null 로 바꾸면 지도에서 제거된다', (tester) async {
    final c = await mount(tester, sampleProps());
    await waitUntil(tester, c, 'markerIndex.size === 3 && polylineIndex.size === 1');

    props.value = const MapProps();
    await pumpFor(tester, const Duration(milliseconds: 1200));

    expect(await jsInt(c, 'markerIndex.size'), 0);
    expect(await jsInt(c, 'polylineIndex.size'), 0);
    expect(await jsInt(c, 'circleIndex.size'), 0);
    expect(await jsInt(c, 'rectangleIndex.size'), 0);
    expect(await jsInt(c, 'polygonIndex.size'), 0);
    expect(await jsInt(c, 'customOverlayIndex.size'), 0);

    await expectNoJsErrors(c);
    await unmount(tester);
  });

  testWidgets('따옴표/백틱이 포함된 커스텀 오버레이 ID 도 안전하게 처리된다', (tester) async {
    const trickyId = 'ov"\'`)</div><img src=x onerror="__pwned=1">';
    final c = await mount(
      tester,
      MapProps(customOverlays: [
        CustomOverlay(
          customOverlayId: trickyId,
          latLng: LatLng(37.5665, 126.9780),
          content: '<div>tap me</div>',
        ),
      ]),
    );
    await waitUntil(tester, c, 'customOverlayIndex.size === 1');

    // ID 가 그대로 보존되고, 인젝션된 스크립트는 실행되지 않아야 한다.
    expect(await js(c, 'Array.from(customOverlayIndex.keys())[0]'), trickyId);
    expect(await js(c, "typeof window.__pwned"), 'undefined');

    await expectNoJsErrors(c);
    await unmount(tester);
  });

  testWidgets('배치 중 잘못된 항목이 있어도 나머지 마커는 그려진다', (tester) async {
    final c = await mount(tester, const MapProps());

    // latLng 이 없는 항목을 중간에 섞어 JS 배치 루프에서 예외를 유발한다.
    await c.runJavaScript('''
      addMarkers([
        {markerId: 'ok1', latLng: {latitude: 37.5665, longitude: 126.9780}},
        {markerId: 'broken'},
        {markerId: 'ok2', latLng: {latitude: 37.5670, longitude: 126.9790}}
      ]);
    ''');
    await pumpFor(tester, const Duration(milliseconds: 500));

    // 예외가 난 항목만 건너뛰고 나머지는 정상 처리되어야 한다.
    expect(await jsInt(c, 'markerIndex.size'), 2);
    expect(await js(c, "markerIndex.has('ok2')"), true);
    final errs = await js(c, 'window.__kakaoMapErrors') as List;
    expect(errs.length, 1);
    expect(errs.first.toString(), contains('addMarkers'));

    await unmount(tester);
  });

  testWidgets('libraries 옵션으로 drawing 을 제외할 수 있다', (tester) async {
    final c = await mount(
      tester,
      const MapProps(libraries: {KakaoMapLibrary.services}),
    );

    expect(await js(c, 'typeof kakao.maps.drawing'), 'undefined');
    expect(await js(c, 'typeof kakao.maps.services'), 'object');

    // services 는 포함했으므로 검색이 정상 동작해야 한다.
    final r = await c
        .keywordSearch(KeywordSearchRequest(keyword: '카카오프렌즈', size: 1))
        .timeout(const Duration(seconds: 20));
    expect(r.list, hasLength(1));

    await expectNoJsErrors(c);
    await unmount(tester);
  });

  testWidgets('clusterer 를 쓰면 libraries 에 없어도 클러스터러가 자동 포함된다',
      (tester) async {
    final c = await mount(
      tester,
      MapProps(
        libraries: const {KakaoMapLibrary.services},
        clusterer: Clusterer(
          markers: List.generate(
            5,
            (i) => Marker(
              markerId: 'ac$i',
              latLng: LatLng(37.5665 + i * 0.001, 126.9780 + i * 0.001),
            ),
          ),
          minLevel: 1,
        ),
      ),
    );

    expect(await js(c, 'typeof kakao.maps.MarkerClusterer'), 'function');
    await waitUntil(tester, c, 'clustererMarkerIds.size === 5');

    await expectNoJsErrors(c);
    await unmount(tester);
  });

  testWidgets('검색 결과가 없으면 예외가 아니라 빈 목록을 돌려준다', (tester) async {
    // 0.4.x 는 ZERO_RESULT 를 빈 목록으로 처리했다. 결과 0건은 정상 상황이므로
    // 예외를 던지면 기존 사용자 코드가 깨진다.
    final c = await mount(tester, const MapProps());

    final keyword = await c
        .keywordSearch(KeywordSearchRequest(
            keyword: 'ZZZQQQ존재하지않는장소XYZ123'))
        .timeout(const Duration(seconds: 20));
    expect(keyword.list, isEmpty);

    final address = await c
        .addressSearch(AddressSearchRequest(addr: 'ZZZQQQ존재하지않는주소XYZ123'))
        .timeout(const Duration(seconds: 20));
    expect(address.list, isEmpty);

    // 정상 검색은 그대로 동작해야 한다.
    final ok = await c
        .keywordSearch(KeywordSearchRequest(keyword: '카카오프렌즈', size: 1))
        .timeout(const Duration(seconds: 20));
    expect(ok.list, hasLength(1));

    await expectNoJsErrors(c);
    await unmount(tester);
  });
  testWidgets('setCenter/getCenter, setLevel/getLevel, getBounds 왕복', (tester) async {
    final c = await mount(tester, MapProps(center: LatLng(37.5, 127.0)));
    // 초기 center 는 WebView 레이아웃 시점에 따라 뷰포트 절반만큼 어긋날 수 있으므로
    // 명시적으로 설정한 뒤 왕복을 검증한다.
    await c.setCenter(LatLng(37.5, 127.0));
    await pumpFor(tester, const Duration(milliseconds: 300));
    final center = await c.getCenter();
    expect(center.latitude, closeTo(37.5, 1e-4));
    expect(center.longitude, closeTo(127.0, 1e-4));

    // 줌 변경 전 안정된 상태에서 영역을 확인한다.
    expect(await c.getLevel(), 3);
    final bounds = await c.getBounds();
    expect(bounds.sw.latitude, lessThan(bounds.ne.latitude));
    expect(bounds.sw.longitude, lessThan(bounds.ne.longitude));

    // setLevel 은 줌 애니메이션을 유발하므로 레벨이 반영될 때까지 기다린다.
    // (애니메이션 도중의 map.getBounds() 는 일시적으로 축퇴된 값을 돌려줄 수 있다)
    await c.setLevel(5);
    await waitUntil(tester, c, 'map.getLevel() === 5');
    expect(await c.getLevel(), 5);

    // 줌이 끝난 뒤에는 영역이 다시 정상 범위를 갖는다.
    await waitUntil(tester, c,
        'map.getBounds().getSouthWest().getLat() < map.getBounds().getNorthEast().getLat()');
    final zoomed = await c.getBounds();
    expect(zoomed.sw.latitude, lessThan(zoomed.ne.latitude));

    await expectNoJsErrors(c);
    await unmount(tester);
  });
  testWidgets('커스텀 타일셋을 등록해 기본 지도와 오버레이로 쓸 수 있다', (tester) async {
    final c = await mount(tester, MapProps(center: LatLng(37.5, 127.0)));

    await c.addTileset(const Tileset(
      id: 'TEST_URL',
      urlTemplate: 'https://i1.daumcdn.net/dmaps/apis/white.png?z={z}&y={y}&x={x}',
      copyright: [TilesetCopyright('test')],
    ));
    await c.addTileset(const Tileset(
      id: 'TEST_DOM',
      tileFunction:
          "function (x, y, z) { var d = document.createElement('div'); d.textContent = x + ',' + y + ',' + z; return d; }",
    ));
    expect(await c.getActiveTilesetId(), isNull);

    // 기본 지도 타입으로 전환하면 SDK 가 우리 주소 함수를 실제로 호출한다.
    await c.setTileset('TEST_URL');
    expect(await c.getActiveTilesetId(), 'TEST_URL');
    await waitUntil(tester, c, "(__tilesetStats['TEST_URL'] || 0) > 0");
    // 템플릿 치환이 되었는지 확인한다.
    final url = await js(c,
        "kakao.maps.MapTypeId['TEST_URL'] !== undefined && __tilesets['TEST_URL'] ? 'ok' : 'missing'");
    expect(url, 'ok');

    // getTile 타일셋은 오버레이로 겹친다.
    await c.addOverlayTileset('TEST_DOM');
    await waitUntil(tester, c, "(__tilesetStats['TEST_DOM'] || 0) > 0");

    // 표시 중인 타일셋을 같은 ID 로 다시 등록하면 새 타일셋으로 갈아끼워진다.
    // (호출 횟수는 재등록 시 0 으로 초기화되므로 다시 늘어나야 새 타일 함수가 쓰인 것)
    await c.addTileset(const Tileset(
      id: 'TEST_URL',
      urlTemplate: 'https://i1.daumcdn.net/dmaps/apis/white.png?v2&z={z}&y={y}&x={x}',
    ));
    expect(await c.getActiveTilesetId(), 'TEST_URL');
    await waitUntil(tester, c, "(__tilesetStats['TEST_URL'] || 0) > 0");
    await c.addTileset(const Tileset(
      id: 'TEST_DOM',
      tileFunction:
          "function (x, y, z) { var d = document.createElement('div'); d.textContent = 'v2 ' + x; return d; }",
    ));
    await waitUntil(tester, c, "(__tilesetStats['TEST_DOM'] || 0) > 0");
    await c.removeOverlayTileset('TEST_DOM');
    expect(await js(c, "__tilesetOverlays['TEST_DOM'] === undefined"), isTrue);

    // SDK 기본 지도 타입 ID 는 등록이 거부되고 오류만 기록된다.
    await c.addTileset(const Tileset(id: 'ROADMAP', urlTemplate: 'x'));
    final errs = await js(c, 'window.__kakaoMapErrors') as List;
    expect(errs.where((e) => '$e'.contains('TILESET_ID_RESERVED')), hasLength(1));
    expect(await js(c, "__tilesets['ROADMAP'] === undefined"), isTrue);
    await js(c, 'window.__kakaoMapErrors.length = 0');

    // 일반 지도로 되돌린다.
    await c.setMapTypeId(MapType.normal);
    expect(await c.getActiveTilesetId(), isNull);
    expect(await c.getMapTypeId(), MapType.normal);

    await expectNoJsErrors(c);
    await unmount(tester);
  });
  testWidgets('콘텐츠 안 링크를 탭하면 문서가 이동하지 않고 onLinkTap 으로 전달된다', (tester) async {
    final tapped = <Uri>[];
    final c = await mount(
      tester,
      MapProps(
        customOverlays: [
          CustomOverlay(
            customOverlayId: 'link',
            latLng: LatLng(37.5665, 126.9780),
            content: '<div><a id="probe-link" href="https://place.map.kakao.com/123">장소</a></div>',
          ),
        ],
        onLinkTap: tapped.add,
      ),
    );
    await waitUntil(tester, c, "!!document.getElementById('probe-link')");
    final before = await js(c, 'location.href');

    await c.runJavaScript("document.getElementById('probe-link').click();");
    await pumpFor(tester, const Duration(milliseconds: 500));

    expect(tapped, [Uri.parse('https://place.map.kakao.com/123')]);
    // 지도 문서는 그대로 살아 있다.
    expect(await js(c, 'location.href'), before);
    expect(await js(c, 'typeof map === "object" && map !== null'), isTrue);
    await expectNoJsErrors(c);
    await unmount(tester);
  });
  testWidgets('InfoWindowStyle 을 지정하면 SDK 인포윈도우 대신 앱 스타일 말풍선이 그려진다',
      (tester) async {
    final c = await mount(
      tester,
      MapProps(markers: [
        Marker(
          markerId: 'styled',
          latLng: LatLng(37.5665, 126.9780),
          infoWindowContent: '<b>스타일</b>',
          infoWindowFirstShow: true,
          infoWindowStyle: const InfoWindowStyle.material(),
        ),
      ]),
    );
    await waitUntil(tester, c, "document.querySelectorAll('.kmp-iw').length === 1");
    expect(await js(c, "document.querySelector('.kmp-iw-body').innerHTML"), contains('스타일'));
    expect(await js(c, "document.querySelector('.kmp-iw').style.borderRadius"), '12px');
    // 닫기 버튼이 있고, 누르면 사라진다.
    await c.runJavaScript("document.querySelector('.kmp-iw-close').click();");
    await waitUntil(tester, c, "document.querySelectorAll('.kmp-iw').length === 0");
    await expectNoJsErrors(c);
    await unmount(tester);

    // 테마 기본값: 마커에 스타일이 없어도 테마 스타일로 그려진다.
    final c2 = await mount(
      tester,
      MapProps(
        theme: const KakaoMapTheme(infoWindowStyle: InfoWindowStyle.dark()),
        markers: [
          Marker(
            markerId: 'themed',
            latLng: LatLng(37.5665, 126.9780),
            infoWindowContent: '테마',
            infoWindowFirstShow: true,
          ),
        ],
      ),
    );
    await waitUntil(tester, c2, "document.querySelectorAll('.kmp-iw').length === 1");
    expect(await js(c2, "document.querySelector('.kmp-iw').style.backgroundColor"),
        anyOf('rgb(28, 28, 30)', 'rgba(28, 28, 30, 1)', '#1c1c1eff'));
    await expectNoJsErrors(c2);
    await unmount(tester);
  });
}
