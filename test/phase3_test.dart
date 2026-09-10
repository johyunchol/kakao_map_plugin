@TestOn('vm')
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'fake_webview_platform.dart';

void main() {
  group('KakaoMapLinks', () {
    final seoul = LatLng(37.5665, 126.9780);

    test('web 링크는 map.kakao.com/link 형식을 만든다', () {
      expect(KakaoMapLinks.web.place(seoul, name: '서울시청').toString(),
          'https://map.kakao.com/link/map/${Uri.encodeComponent('서울시청')},37.5665,126.978');
      expect(KakaoMapLinks.web.placeById('12345').toString(),
          'https://map.kakao.com/link/map/12345');
      expect(KakaoMapLinks.web.route(to: seoul, toName: '시청').toString(),
          'https://map.kakao.com/link/to/${Uri.encodeComponent('시청')},37.5665,126.978');
      expect(
        KakaoMapLinks.web
            .route(
                to: seoul,
                toName: 'B',
                from: LatLng(37.5, 127.0),
                fromName: 'A',
                mode: KakaoMapRouteMode.transit)
            .toString(),
        'https://map.kakao.com/link/by/traffic/A,37.5,127.0/B,37.5665,126.978',
      );
      expect(KakaoMapLinks.web.roadview(seoul).toString(),
          'https://map.kakao.com/link/roadview/37.5665,126.978');
      expect(KakaoMapLinks.web.search('카페 라떼').toString(),
          'https://map.kakao.com/link/search/${Uri.encodeComponent('카페 라떼')}');
    });

    test('app 스킴은 kakaomap:// 형식을 만든다', () {
      expect(KakaoMapLinks.app.look(seoul).toString(),
          'kakaomap://look?p=37.5665,126.978');
      final route =
          KakaoMapLinks.app.route(to: seoul, mode: KakaoMapRouteMode.walk);
      expect(route.scheme, 'kakaomap');
      expect(route.host, 'route');
      expect(route.queryParameters, {'ep': '37.5665,126.978', 'by': 'FOOT'});
      expect(KakaoMapLinks.app.search('카페', near: seoul).queryParameters,
          {'q': '카페', 'p': '37.5665,126.978'});
      expect(KakaoMapLinks.storeUrl(platform: TargetPlatform.iOS).host,
          'apps.apple.com');
      expect(KakaoMapLinks.storeUrl(platform: TargetPlatform.android).host,
          'play.google.com');
    });
  });

  group('SearchPagination', () {
    test('fromJson 은 누락 값을 안전하게 처리한다', () {
      final p = SearchPagination.fromJson(
          {'totalCount': 45, 'current': 2, 'hasNextPage': true});
      expect(p.totalCount, 45);
      expect(p.current, 2);
      expect(p.hasNextPage, isTrue);
      expect(p.hasPrevPage, isFalse);
      expect(SearchPagination.fromJson({}).current, 1);
    });

    test('BaseService.handleMessage 가 응답에 pagination 을 붙인다', () async {
      final service = KeywordSearchService();
      final id = service.createRequest();
      final future = service.requestFuture(id);
      service.handleMessage(
        jsonEncode({
          'requestId': id,
          'result': [],
          'pagination': {
            'totalCount': 30,
            'current': 1,
            'hasNextPage': true,
            'hasPrevPage': false
          },
        }),
        (json) => KeywordSearchResponse.fromJson(json as List<dynamic>),
      );
      final response = await future;
      expect(response.pagination?.totalCount, 30);
      expect(response.pagination?.hasNextPage, isTrue);
    });
  });

  group('KakaoMap 3차 채널', () {
    late FakeWebViewPlatform platform;

    setUp(() {
      platform = FakeWebViewPlatform();
      WebViewPlatform.instance = platform;
      AuthRepository.initialize(appKey: 'test-key');
    });

    Widget host(Widget child) =>
        MaterialApp(home: SizedBox(width: 400, height: 600, child: child));

    Future<void> ready(WidgetTester tester) async {
      platform.lastController!.channels['onMapCreated']!.onMessageReceived(
          const JavaScriptMessage(message: '{"ready":true}'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
    }

    testWidgets('도형 탭 / 롱프레스 / hover 채널이 콜백으로 전달되고 JS 리스너는 콜백이 있을 때만 켜진다',
        (tester) async {
      final events = <String>[];
      await tester.pumpWidget(host(KakaoMap(
        onPolylineTap: (id, ll, z) => events.add('polyline:$id'),
        onCircleTap: (id, ll, z) => events.add('circle:$id'),
        onRectangleTap: (id, ll, z) => events.add('rect:$id'),
        onMapLongPress: (ll) => events.add('long:${ll.latitude}'),
        onMarkerMouseOver: (id, ll, z) => events.add('over:$id'),
        onPolygonMouseMove: (id, ll, z) => events.add('move:$id'),
      )));
      await ready(tester);
      final fake = platform.lastController!;
      final html = fake.lastHtml!;
      // 콜백 유무는 JS 안의 상수 조건으로 켜고 끕니다.
      expect(
          html, contains("if (true) __attachShapeTap(polyline, onPolylineTap"));
      expect(html, contains("if (true) __attachShapeTap(circle, onCircleTap"));
      expect(html,
          contains("if (true) __attachShapeTap(rectangle, onRectangleTap"));
      expect(html, contains("if (true) __attachPolygonHover(polygon)"));
      expect(html, contains("if (true) {\n            // 길게 누르기"));
      expect(html, contains("if (true) {\n            // 마우스 환경 전용"));

      String payload(String key, String id) => jsonEncode(
          {key: id, 'latitude': 37.5, 'longitude': 127.0, 'zoomLevel': 3});
      fake.channels['onPolylineTap']!.onMessageReceived(
          JavaScriptMessage(message: payload('polylineId', 'p1')));
      fake.channels['onCircleTap']!.onMessageReceived(
          JavaScriptMessage(message: payload('circleId', 'c1')));
      fake.channels['onRectangleTap']!.onMessageReceived(
          JavaScriptMessage(message: payload('rectangleId', 'r1')));
      fake.channels['onMapLongPress']!.onMessageReceived(
          const JavaScriptMessage(
              message: '{"latitude":37.1,"longitude":127.1}'));
      fake.channels['onMarkerMouseOver']!.onMessageReceived(
          JavaScriptMessage(message: payload('markerId', 'm1')));
      fake.channels['onPolygonMouseMove']!.onMessageReceived(
          JavaScriptMessage(message: payload('polygonId', 'g1')));
      expect(events, [
        'polyline:p1',
        'circle:c1',
        'rect:r1',
        'long:37.1',
        'over:m1',
        'move:g1'
      ]);
    });

    testWidgets('콜백이 없으면 도형 탭·hover·롱프레스 JS 리스너를 등록하지 않는다', (tester) async {
      await tester.pumpWidget(host(KakaoMap()));
      final html = platform.lastController!.lastHtml!;
      expect(html,
          contains("if (false) __attachShapeTap(polyline, onPolylineTap"));
      expect(html, contains("if (false) __attachPolygonHover(polygon)"));
      expect(html, contains("if (false) {\n            // 길게 누르기"));
      expect(html, contains("if (false) {\n            // 마우스 환경 전용"));
    });

    testWidgets('위젯 오버레이는 JS 가 보낸 픽셀 좌표에 anchor 기준으로 놓인다', (tester) async {
      await tester.pumpWidget(host(KakaoMap(
        widgetOverlays: [
          KakaoMapWidgetOverlay(
            id: 'w1',
            position: LatLng(37.5, 127.0),
            anchor: Alignment.bottomCenter,
            offset: const Offset(0, -10),
            child: const SizedBox(key: Key('wo-w1'), width: 40, height: 20),
          ),
        ],
      )));
      await ready(tester);
      final fake = platform.lastController!;
      // 준비되면 추적 좌표를 JS 로 보낸다.
      expect(
          fake.scripts.any((s) => s.startsWith('trackWidgetOverlays(')), isTrue,
          reason: fake.scripts.join('\n'));
      // 좌표가 오기 전에는 그리지 않는다.
      expect(find.byKey(const Key('wo-w1')), findsNothing);

      fake.channels['widgetOverlayPositions']!.onMessageReceived(
          const JavaScriptMessage(message: '{"positions":{"w1":[100,200]}}'));
      await tester.pump();
      expect(find.byKey(const Key('wo-w1')), findsOneWidget);
      // bottomCenter anchor: 왼쪽 = 100 - 20, 위 = 200 - 20, offset(0,-10) 적용
      final topLeft = tester.getTopLeft(find.byKey(const Key('wo-w1')));
      expect(topLeft.dx, closeTo(80, 0.5));
      expect(topLeft.dy, closeTo(170, 0.5));
    });

    testWidgets('supportsHover 는 문자열/불리언 결과를 모두 해석한다', (tester) async {
      KakaoMapController? c;
      await tester.pumpWidget(host(KakaoMap(onMapCreated: (v) => c = v)));
      await ready(tester);
      final fake = platform.lastController!;
      fake.returningResult = 'true';
      expect(await c!.supportsHover(), isTrue);
      fake.returningResult = false;
      expect(await c!.supportsHover(), isFalse);
      fake.returningResult = '"false"';
      expect(await c!.supportsHover(), isFalse);
    });
  });
}
