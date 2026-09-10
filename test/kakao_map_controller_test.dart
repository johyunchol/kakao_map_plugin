import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'fake_webview_platform.dart';

/// `fn("<escaped json>");` 형태의 스크립트에서 payload 를 두 번 디코드해 돌려줍니다.
dynamic decodePayload(String script, String fn) {
  final match = RegExp('^$fn\\((.*)\\);\$', dotAll: true).firstMatch(script);
  expect(match, isNotNull, reason: '스크립트 형식이 예상과 다릅니다: $script');
  final jsStringLiteral = match!.group(1)!;
  final json = jsonDecode(jsStringLiteral) as String; // JS 문자열 리터럴 → JSON 문자열
  return jsonDecode(json); // JSON 문자열 → Dart 객체
}

void main() {
  late FakeWebViewPlatform platform;
  late FakePlatformWebViewController fake;
  late KakaoMapController controller;

  setUp(() {
    platform = FakeWebViewPlatform();
    WebViewPlatform.instance = platform;
    final webViewController = WebViewController();
    fake = platform.lastController!;
    controller = KakaoMapController(webViewController);
  });

  group('addMarker 배치 전송', () {
    test('마커 N개가 clear 1회 + addMarkers 1회로 전송된다', () async {
      final markers = List.generate(
        3,
        (i) => Marker(
          markerId: 'm$i',
          latLng: LatLng(37.5 + i, 127.0 + i),
          zIndex: i,
        ),
      );

      await controller.addMarker(markers: markers);

      expect(fake.scripts, hasLength(2));
      expect(fake.scripts[0], 'clearMarker("[\\"m0\\",\\"m1\\",\\"m2\\"]");');

      final payload = decodePayload(fake.scripts[1], 'addMarkers') as List;
      expect(payload, hasLength(3));
      expect(payload[0]['markerId'], 'm0');
      expect(payload[0]['latLng'], {'latitude': 37.5, 'longitude': 127.0});
      expect(payload[0]['hash'], isA<int>());
      expect(payload[2]['zIndex'], 2);
    });

    test('null 은 무시하고, 빈 리스트는 일반 마커를 전부 제거한다', () async {
      await controller.addMarker(markers: null);
      expect(fake.scripts, isEmpty);
      await controller.addMarker(markers: []);
      expect(fake.scripts, ['clearMarker("[]");']);
    });

    test('같은 base64 아이콘은 registerImages 로 1회만 전송되고 payload 는 참조만 담는다',
        () async {
      final base64 = 'A' * 5000;
      final icon = MarkerIcon.fromBase64(base64);
      final markers = List.generate(
        5,
        (i) => Marker(markerId: 'm$i', latLng: LatLng(1, 2), icon: icon),
      );

      await controller.addMarker(markers: markers);
      await controller.addMarker(markers: markers); // 두 번째는 재등록하지 않는다

      final registers =
          fake.scripts.where((s) => s.startsWith('registerImages(')).toList();
      expect(registers, hasLength(1));
      final registered = decodePayload(registers.single, 'registerImages') as Map;
      expect(registered.values.single, base64);

      final batch = decodePayload(
          fake.scripts.firstWhere((s) => s.startsWith('addMarkers(')),
          'addMarkers') as List;
      for (final m in batch) {
        expect(m['imageSrc'], '@${registered.keys.single}');
        expect(m['imageType'], 'file');
      }
      // 배치 스크립트에 base64 원문이 들어 있으면 안 된다
      expect(fake.scripts.where((s) => s.startsWith('addMarkers(')).any((s) => s.contains(base64)), isFalse);
    });

    test('500개 마커는 200개 단위로 나뉘어 전송된다', () async {
      final markers = List.generate(
        500,
        (i) => Marker(markerId: 'm$i', latLng: LatLng(37, 127)),
      );

      await controller.addMarker(markers: markers);

      final batches =
          fake.scripts.where((s) => s.startsWith('addMarkers(')).toList();
      expect(batches, hasLength(3));
      expect((decodePayload(batches[0], 'addMarkers') as List).length, 200);
      expect((decodePayload(batches[2], 'addMarkers') as List).length, 100);
    });

    test('같은 내용의 마커는 같은 hash, 내용이 바뀌면 다른 hash', () async {
      await controller.addMarker(markers: [
        Marker(markerId: 'a', latLng: LatLng(1, 2), infoWindowContent: 'x'),
      ]);
      await controller.addMarker(markers: [
        Marker(markerId: 'a', latLng: LatLng(1, 2), infoWindowContent: 'x'),
      ]);
      await controller.addMarker(markers: [
        Marker(markerId: 'a', latLng: LatLng(1, 3), infoWindowContent: 'x'),
      ]);

      final batches =
          fake.scripts.where((s) => s.startsWith('addMarkers(')).toList();
      final h0 = decodePayload(batches[0], 'addMarkers')[0]['hash'];
      final h1 = decodePayload(batches[1], 'addMarkers')[0]['hash'];
      final h2 = decodePayload(batches[2], 'addMarkers')[0]['hash'];
      expect(h0, h1);
      expect(h0, isNot(h2));
    });
  });

  group('JS 인젝션 방지', () {
    test('따옴표/줄바꿈/백슬래시/script 태그가 포함된 콘텐츠가 원형 그대로 왕복한다',
        () async {
      const content =
          '<div onclick="x()">He said "hi" & \'bye\'\n\\path\t</script>\u2028</div>';

      await controller.addMarker(markers: [
        Marker(
          markerId: "id'with\"quotes",
          latLng: LatLng(1, 2),
          infoWindowContent: content,
        ),
      ]);
      await controller.addCustomOverlay(customOverlays: [
        CustomOverlay(customOverlayId: 'c1', latLng: LatLng(1, 2), content: content),
      ]);

      final markerPayload = decodePayload(
          fake.scripts.firstWhere((s) => s.startsWith('addMarkers(')),
          'addMarkers') as List;
      expect(markerPayload[0]['markerId'], "id'with\"quotes");
      expect(markerPayload[0]['infoWindowContent'], content);

      final overlayPayload = decodePayload(
          fake.scripts.firstWhere((s) => s.startsWith('addCustomOverlays(')),
          'addCustomOverlays') as List;
      expect(overlayPayload[0]['content'], content);

      // 스크립트 안에 이스케이프되지 않은 U+2028 이 남아 있으면 안 된다.
      for (final s in fake.scripts) {
        expect(s.contains('\u2028'), isFalse);
      }
    });

    test('검색어에 작은따옴표가 있어도 JS 문자열 리터럴이 깨지지 않는다', () async {
      // 응답은 오지 않으므로 Future 는 대기 상태로 둔다.
      // ignore: unawaited_futures
      controller.keywordSearch(KeywordSearchRequest(keyword: "Dunkin' Donuts"));
      await Future<void>.delayed(Duration.zero);

      final script = fake.scripts.single;
      final match =
          RegExp(r'^keywordSearch\((".*"), (\d+)\);$').firstMatch(script);
      expect(match, isNotNull, reason: script);
      final request = jsonDecode(jsonDecode(match!.group(1)!) as String);
      expect(request['keyword'], "Dunkin' Donuts");
      expect(int.parse(match.group(2)!), greaterThan(0));
    });

    test('keywordSearch 는 레거시 completer 를 초기화해 xxxResult() 경로도 살아 있다', () async {
      // 이전 요청이 완료된 상태를 만든다.
      KeywordSearchService().resetCompleter();
      KeywordSearchService.keywordSearchCallback('[]');
      expect(KeywordSearchService().completer.isCompleted, isTrue);

      // ignore: unawaited_futures
      controller.keywordSearch(KeywordSearchRequest(keyword: '카페'));
      await Future<void>.delayed(Duration.zero);

      // 새 요청 시작 시 레거시 completer 가 새로 만들어져 대기 상태여야 한다.
      expect(KeywordSearchService().completer.isCompleted, isFalse);
    });

    test('setMarkerDraggable 의 markerId 가 이스케이프된다', () async {
      await controller.setMarkerDraggable("a'b", true);
      expect(fake.scripts.single, 'setMarkerDraggable("a\'b", true);');
    });
  });

  group('도형 배치 전송', () {
    test('polyline / circle / rectangle / polygon / customOverlay 가 각각 1회 배치로 전송된다',
        () async {
      await controller.addPolyline(polylines: [
        Polyline(
          polylineId: 'p1',
          points: [LatLng(1, 2), LatLng(3, 4)],
          strokeColor: Colors.red,
          strokeStyle: StrokeStyle.dash,
          endArrow: true,
        ),
      ]);
      await controller.addCircle(circles: [
        Circle(circleId: 'c1', center: LatLng(1, 2), radius: 100),
      ]);
      await controller.addRectangle(rectangles: [
        Rectangle(
          rectangleId: 'r1',
          rectangleBounds: LatLngBounds(LatLng(1, 2), LatLng(3, 4)),
        ),
      ]);
      await controller.addPolygon(polygons: [
        Polygon(
          polygonId: 'g1',
          points: [LatLng(1, 2), LatLng(3, 4), LatLng(5, 6)],
          holes: [
            [LatLng(2, 3), LatLng(2.5, 3.5), LatLng(3, 3)]
          ],
        ),
      ]);

      final fns = fake.scripts.map((s) => s.split('(').first).toList();
      expect(fns, [
        'clearPolyline',
        'addPolylines',
        'clearCircle',
        'addCircles',
        'clearRectangle',
        'addRectangles',
        'clearPolygon',
        'addPolygons',
      ]);

      final polyline = decodePayload(fake.scripts[1], 'addPolylines')[0];
      expect(polyline['strokeColor'], startsWith('#'));
      expect(polyline['strokeStyle'], 'dash');
      expect(polyline['endArrow'], true);
      expect(polyline['points'], hasLength(2));

      final polygon = decodePayload(fake.scripts[7], 'addPolygons')[0];
      expect(polygon['holes'], hasLength(1));
      expect(polygon['holes'][0], hasLength(3));

      // strokeColor 가 null 이면 'null' 문자열이 아니라 JSON null 로 전달된다.
      final circle = decodePayload(fake.scripts[3], 'addCircles')[0];
      expect(circle['strokeColor'], isNull);
      expect(circle['fillColor'], isNull);
    });
  });

  group('클러스터러', () {
    test('null 옵션은 undefined 로 전달되어 JS 기본값이 적용된다', () async {
      await controller.addMarkerClusterer(
        clusterer: Clusterer(
          markers: [Marker(markerId: 'a', latLng: LatLng(1, 2))],
          gridSize: null,
          averageCenter: null,
          minLevel: 5,
        ),
      );

      final script = fake.scripts.single;
      expect(script, startsWith('addMarkerClusterer('));
      expect(script, contains(', undefined, undefined, true, 5, 2, '));
    });
  });
}
