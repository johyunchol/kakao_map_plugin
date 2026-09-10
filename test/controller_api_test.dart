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
    test('Android 의 문자열 "true" 와 iOS 의 bool true 를 모두 true 로 정규화한다',
        () async {
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

      expect(fake.scripts[0], 'setCenter(37.5, 127.0);');
      expect(fake.scripts[1], 'panTo(37.6, 127.1);');
    });
  });
}
