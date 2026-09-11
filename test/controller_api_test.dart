import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'fake_webview_platform.dart';

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

  group('setBounds', () {
    test('인자 없이 호출하면 기존과 동일한 무인자 JS 호출을 보낸다 (하위호환)', () async {
      await controller.setBounds();
      expect(fake.scripts.single, 'setBounds();');
    });

    test('bounds 를 주면 좌표와 padding 이 JS 로 전달된다', () async {
      await controller.setBounds(
        LatLngBounds(LatLng(37.4, 126.8), LatLng(37.6, 127.1)),
        10,
        20,
        30,
        40,
      );

      final script = fake.scripts.single;
      final match =
          RegExp(r'^setBounds\((".*"), (\d+), (\d+), (\d+), (\d+)\);$')
              .firstMatch(script);
      expect(match, isNotNull, reason: script);

      final bounds = jsonDecode(jsonDecode(match!.group(1)!) as String);
      expect(bounds['sw'], {'latitude': 37.4, 'longitude': 126.8});
      expect(bounds['ne'], {'latitude': 37.6, 'longitude': 127.1});
      expect(
        [2, 3, 4, 5].map((i) => int.parse(match.group(i)!)).toList(),
        [10, 20, 30, 40],
      );
    });
  });

  group('isDraggable / isZoomable', () {
    test('Android 의 문자열 "true" 와 iOS 의 bool true 를 모두 true 로 정규화한다', () async {
      fake.returningResult = 'true';
      expect(await controller.isDraggable(), isTrue);

      fake.returningResult = true;
      expect(await controller.isZoomable(), isTrue);
    });

    test('false 계열 값은 false 로 정규화한다', () async {
      fake.returningResult = 'false';
      expect(await controller.isDraggable(), isFalse);

      fake.returningResult = false;
      expect(await controller.isZoomable(), isFalse);
    });
  });

  group('getBounds / getLevel', () {
    test('정수로 직렬화된 좌표와 레벨도 파싱한다', () async {
      fake.returningResult = jsonEncode({
        'sw': {'latitude': 37, 'longitude': 126},
        'ne': {'latitude': 38, 'longitude': 127},
      });
      final bounds = await controller.getBounds();
      expect(bounds.sw.latitude, 37.0);
      expect(bounds.ne.longitude, 127.0);

      fake.returningResult = jsonEncode({'level': 3});
      expect(await controller.getLevel(), 3);
    });
  });

  group('좌표 전달', () {
    test('setCenter / panTo 가 숫자 리터럴로 좌표를 보낸다', () async {
      await controller.setCenter(LatLng(37.5, 127.0));
      await controller.panTo(LatLng(37.6, 127.1));

      // web(dart2js)에서는 127.0 이 '127' 로 찍히므로 숫자 값으로 비교한다.
      List<double> numbersOf(String script) => RegExp(r'-?\d+(?:\.\d+)?')
          .allMatches(script)
          .map((m) => double.parse(m.group(0)!))
          .toList();
      expect(fake.scripts[0], startsWith('setCenter('));
      expect(numbersOf(fake.scripts[0]), [37.5, 127.0]);
      expect(fake.scripts[1], startsWith('panTo('));
      expect(numbersOf(fake.scripts[1]), [37.6, 127.1]);
    });
  });
  group('Tileset', () {
    test('addTileset 은 타일셋 정의를 JSON 문자열로 보낸다', () async {
      await controller.addTileset(const Tileset(
        id: 'MY_TILES',
        urlTemplate: 'https://tiles.example.com/{z}/{y}/{x}.png',
        copyright: [TilesetCopyright('© Example', minZoom: 3)],
        minZoom: 1,
        maxZoom: 10,
      ));

      final script = fake.scripts.single;
      final match = RegExp(r'^addTileset\((".*")\);$').firstMatch(script);
      expect(match, isNotNull, reason: script);

      final payload = jsonDecode(jsonDecode(match!.group(1)!) as String);
      expect(payload['id'], 'MY_TILES');
      expect(payload['width'], 256);
      expect(payload['height'], 256);
      expect(
          payload['urlTemplate'], 'https://tiles.example.com/{z}/{y}/{x}.png');
      expect(payload.containsKey('urlFunction'), isFalse);
      expect(payload.containsKey('tileFunction'), isFalse);
      expect(payload['copyright'], [
        {'msg': '© Example', 'shortMsg': '© Example', 'minZoom': 3},
      ]);
      expect(payload['dark'], isFalse);
      expect(payload['minZoom'], 1);
      expect(payload['maxZoom'], 10);
    });

    test('타일 함수 원문은 따옴표가 있어도 그대로 전달된다', () async {
      const fn = "function (x, y, z) { return 'a' + x + \"b\" + `c` + z; }";
      await controller.addTileset(const Tileset(id: 'FN', urlFunction: fn));

      final match =
          RegExp(r'^addTileset\((".*")\);$').firstMatch(fake.scripts.single);
      final payload = jsonDecode(jsonDecode(match!.group(1)!) as String);
      expect(payload['urlFunction'], fn);
    });

    test('규칙에 맞지 않는 ID 는 ArgumentError 를 던지고 JS 를 보내지 않는다', () async {
      for (final bad in [
        '__proto__.x',
        'has space',
        '1STARTS_WITH_DIGIT',
        'a-b',
        '한글'
      ]) {
        await expectLater(
          controller.addTileset(Tileset(id: bad, urlTemplate: 'a')),
          throwsArgumentError,
          reason: bad,
        );
      }
      expect(fake.scripts, isEmpty);

      // 규칙에 맞는 ID 는 통과한다 (__proto__ 자체는 JS 쪽 null-prototype 레지스트리가 처리)
      await controller
          .addTileset(const Tileset(id: '__proto__', urlTemplate: 'a'));
      await controller
          .addTileset(const Tileset(id: 'my_tiles2', urlTemplate: 'a'));
      expect(fake.scripts, hasLength(2));
    });

    test('타일 소스를 둘 이상 지정하면 assert 로 막는다', () {
      expect(
        () => Tileset(id: 'X', urlTemplate: 'a', urlFunction: 'b'),
        throwsA(isA<AssertionError>()),
      );
      expect(() => Tileset(id: 'X'), throwsA(isA<AssertionError>()));
      expect(() => Tileset(id: '', urlTemplate: 'a'),
          throwsA(isA<AssertionError>()));
    });

    test(
        'setTileset / addOverlayTileset / removeOverlayTileset 는 ID 를 문자열 리터럴로 보낸다',
        () async {
      await controller.setTileset('A');
      await controller.addOverlayTileset('B');
      await controller.removeOverlayTileset('C');
      expect(fake.scripts, [
        'setTileset("A");',
        'addOverlayTileset("B");',
        'removeOverlayTileset("C");',
      ]);
    });

    test('getActiveTilesetId 는 Android 객체 결과와 iOS 문자열 결과를 모두 파싱한다', () async {
      fake.returningResult = '{"tilesetId":"MY_TILES"}';
      expect(await controller.getActiveTilesetId(), 'MY_TILES');

      fake.returningResult = '"{\\"tilesetId\\":null}"';
      expect(await controller.getActiveTilesetId(), isNull);
    });

    test('getMapTypeId 는 커스텀 타일셋 상태(숫자가 아닌 값)에서도 예외 없이 normal 을 돌려준다',
        () async {
      fake.returningResult = '{"mapTypeId":"MY_TILES"}';
      expect(await controller.getMapTypeId(), MapType.normal);

      fake.returningResult = '{"mapTypeId":2}';
      expect(await controller.getMapTypeId(), MapType.skyView);
    });
  });
  group('카메라 / 레벨 / 측정', () {
    test('panBy, setMinLevel, setMaxLevel 은 숫자 리터럴로 전달된다', () async {
      await controller.panBy(10, -20);
      await controller.setMinLevel(2);
      await controller.setMaxLevel(12);
      expect(fake.scripts, [
        'panBy(10, -20);',
        'setMinLevel(2);',
        'setMaxLevel(12);',
      ]);
    });

    test('jump 는 animate 옵션을 false / true / {duration} 으로 보낸다', () async {
      await controller.jump(LatLng(37.5, 127.0), 5);
      await controller.jump(LatLng(37.5, 127.0), 5, animate: true);
      await controller.jump(LatLng(37.5, 127.0), 5,
          animate: true, duration: const Duration(milliseconds: 300));
      final opts = fake.scripts
          .map((s) => RegExp(r'jump\(.*, 5, (.*)\);$').firstMatch(s)!.group(1)!)
          .map((s) => jsonDecode(jsonDecode(s) as String))
          .toList();
      expect(opts, [
        false,
        true,
        {'duration': 300}
      ]);
    });

    test('panToBounds 는 sw/ne 와 padding 을 전달한다', () async {
      await controller.panToBounds(
          LatLngBounds(LatLng(37.4, 126.8), LatLng(37.6, 127.1)),
          padding: 16);
      expect(fake.scripts.single, 'panToBounds(37.4, 126.8, 37.6, 127.1, 16);');
    });

    test('fitBounds 는 padding 이 없으면 기존과 같은 호출을 보낸다 (하위호환)', () async {
      await controller.fitBounds([LatLng(37.4, 126.8)]);
      expect(fake.scripts.single, startsWith('fitBounds("'));
      expect(fake.scripts.single, isNot(contains(', ')));
      fake.scripts.clear();
      await controller.fitBounds([LatLng(37.4, 126.8)], padding: 40);
      expect(fake.scripts.single, endsWith(', 40);'));
    });

    test('getPolylineLength / getPolygonArea 는 문자열·숫자 결과를 모두 double 로 돌려준다',
        () async {
      fake.returningResult = '1234.5';
      expect(await controller.getPolylineLength('p1'), 1234.5);
      fake.returningResult = 987;
      expect(await controller.getPolygonArea('g1'), 987.0);
      fake.returningResult = 'null';
      expect(() => controller.getPolygonLength('none'), throwsStateError);
    });
  });
  group('마커 옵션 / 인포윈도우 제어 (3차)', () {
    test(
        'setMarkerPosition / setMarkerVisible / showInfoWindow / hideInfoWindow',
        () async {
      await controller.setMarkerPosition('m1', LatLng(37.5, 127.0));
      await controller.setMarkerVisible('m1', false);
      await controller.showInfoWindow("m'1");
      await controller.hideInfoWindow('m1');
      expect(fake.scripts, [
        'setMarkerPosition("m1", 37.5, 127.0);',
        'setMarkerVisible("m1", false);',
        'showInfoWindow("m\'1");',
        'hideInfoWindow("m1");',
      ]);
    });

    test('마커 추가 옵션은 extra 객체로 묶여 전달되고 hash 에 반영된다', () async {
      final base = Marker(markerId: 'm', latLng: LatLng(37.5, 127.0));
      final styled = Marker(
        markerId: 'm',
        latLng: LatLng(37.5, 127.0),
        opacity: 0.5,
        visible: false,
        clickable: false,
        title: '툴팁',
        spriteOrigin: Point(10, 20),
        spriteWidth: 100,
        spriteHeight: 200,
      );
      await controller.addMarker(markers: [base, styled]);
      final script =
          fake.scripts.firstWhere((s) => s.startsWith('addMarkers('));
      final payload = jsonDecode(jsonDecode(
              RegExp(r'^addMarkers\((".*")\);$').firstMatch(script)!.group(1)!)
          as String) as List;
      expect(payload[0]['extra'], isEmpty);
      expect(payload[1]['extra'], {
        'opacity': 0.5,
        'visible': false,
        'clickable': false,
        'title': '툴팁',
        'spriteOrigin': {'x': 10, 'y': 20},
        'spriteSize': {'width': 100, 'height': 200},
      });
      expect(payload[0]['hash'], isNot(payload[1]['hash']));
    });
  });
}
