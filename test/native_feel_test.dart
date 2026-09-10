@TestOn('vm')
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin/src/basic/overlay_payload.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'fake_webview_platform.dart';

void main() {
  group('InfoWindowStyle', () {
    test('toJson 은 JS 가 기대하는 키와 CSS 값으로 변환한다', () {
      const style = InfoWindowStyle(
        backgroundColor: Color(0xFF112233),
        textColor: Color(0xFFFFFFFF),
        borderColor: Color(0xFFAABBCC),
        borderRadius: 10,
        padding: EdgeInsets.fromLTRB(1, 2, 3, 4),
        fontSize: 13,
        maxWidth: 200,
        shadow: false,
        showArrow: false,
      );
      final json = style.toJson();
      expect(json['backgroundColor'], '#112233');
      expect(json['textColor'], '#ffffff');
      expect(json['borderColor'], '#aabbcc');
      expect(json['borderRadius'], 10);
      expect(json['padding'], '2.0px 3.0px 4.0px 1.0px');
      expect(json['fontSize'], 13);
      expect(json['maxWidth'], 200);
      expect(json['shadow'], isFalse);
      expect(json['showArrow'], isFalse);
    });

    test('프리셋은 const 이고 값이 같으면 동등하다', () {
      expect(const InfoWindowStyle.material(), const InfoWindowStyle.material());
      expect(const InfoWindowStyle.material(),
          isNot(equals(const InfoWindowStyle.dark())));
      expect(const InfoWindowStyle.cupertino().borderColor, isNotNull);
    });

    test('마커 payload 와 hash 에 스타일이 반영된다', () {
      final plain = Marker(markerId: 'm', latLng: LatLng(37.5, 127.0), infoWindowContent: 'x');
      final styled = Marker(
        markerId: 'm',
        latLng: LatLng(37.5, 127.0),
        infoWindowContent: 'x',
        infoWindowStyle: const InfoWindowStyle.material(),
      );
      expect(OverlayPayload.marker(plain)['infoWindowStyle'], isNull);
      expect(OverlayPayload.marker(styled)['infoWindowStyle'], isA<Map>());
      expect(OverlayPayload.markerHash(plain), isNot(OverlayPayload.markerHash(styled)));
    });
  });

  group('ClustererStyle', () {
    test('material 프리셋은 원형 + 테두리 + 그림자 CSS 를 만든다', () {
      final json = ClustererStyle.material(const Color(0xFF3366FF), size: 48).toJson();
      expect(json['width'], '48px');
      expect(json['height'], '48px');
      expect(json['borderRadius'], '24px');
      expect(json['fontWeight'], '600');
      expect(json['border'], contains('solid'));
      expect(json['boxShadow'], contains('rgba'));
      expect(json['fontSize'], '14px');
    });

    test('반투명 배경은 CSS 가 이해하는 rgba() 로 나간다', () {
      final json = ClustererStyle(background: const Color(0x803366FF)).toJson();
      expect(json['background'], 'rgba(51, 102, 255, 0.502)');
      expect(ClustererStyle(background: const Color(0xFF3366FF)).toJson()['background'], '#3366ff');
    });

    test('새 필드는 지정했을 때만 JSON 에 들어간다 (하위호환)', () {
      final json = ClustererStyle(width: 30, height: 30).toJson();
      expect(json.keys, containsAll(['width', 'height', 'borderRadius']));
      expect(json.keys, isNot(contains('fontSize')));
      expect(json.keys, isNot(contains('opacity')));
    });
  });

  group('MarkerIcon', () {
    test('pin 은 SVG data URI 를 만들고 색을 반영한다', () {
      final icon = MarkerIcon.pin(color: const Color(0xFFFF0000), size: 40);
      expect(icon.imageType, ImageType.url);
      expect(icon.imageSrc, startsWith('data:image/svg+xml;charset=utf-8,'));
      final svg = Uri.decodeComponent(icon.imageSrc.split(',')[1]);
      expect(svg, contains('fill="#ff0000"'));
      expect(svg, contains('width="28" height="40"'));
    });

    testWidgets('fromWidget 은 위젯을 PNG 로 렌더링해 base64 아이콘을 만든다',
        (tester) async {
      final icon = (await tester.runAsync(() => MarkerIcon.fromWidget(
            Container(color: const Color(0xFF00FF00)),
            logicalSize: const Size(20, 10),
            pixelRatio: 2,
          )))!;
      expect(icon.imageType, ImageType.file);
      final bytes = base64Decode(icon.imageSrc);
      // PNG 시그니처
      expect(bytes.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
      // IHDR 의 너비 = 20 * 2
      final width = (bytes[16] << 24) | (bytes[17] << 16) | (bytes[18] << 8) | bytes[19];
      expect(width, 40);
    });
  });

  group('KakaoMapTheme / 위젯 연동', () {
    late FakeWebViewPlatform platform;

    setUp(() {
      platform = FakeWebViewPlatform();
      WebViewPlatform.instance = platform;
      AuthRepository.initialize(appKey: 'test-key');
    });

    tearDown(() => AuthRepository.instance.theme = null);

    Widget host(Widget child) =>
        MaterialApp(home: SizedBox(width: 400, height: 600, child: child));

    testWidgets('테마의 글꼴·배경·기본 인포윈도우 스타일이 문서에 들어간다', (tester) async {
      await tester.pumpWidget(host(KakaoMap(
        theme: const KakaoMapTheme(
          fontFamily: 'MyFont',
          backgroundColor: Color(0xFF112233),
          infoWindowStyle: InfoWindowStyle.dark(),
          customCss: '.my { color: red; }',
        ),
        copyrightPosition: CopyrightPosition.bottomLeft,
        copyrightReversed: true,
      )));
      final html = platform.lastController!.lastHtml!;
      expect(html, contains('body { font-family: MyFont; }'));
      expect(html, contains('#map { background: #112233 !important; }'));
      expect(html, contains('.my { color: red; }'));
      expect(html, contains('const __defaultInfoWindowStyle = {"backgroundColor":"#1c1c1e"'));
      expect(html, contains('CopyrightPosition.BOTTOMLEFT, true'));
    });

    testWidgets('전역 테마는 위젯 테마가 없을 때 적용된다', (tester) async {
      AuthRepository.initialize(
        appKey: 'test-key',
        theme: const KakaoMapTheme(fontFamily: 'GlobalFont'),
      );
      await tester.pumpWidget(host(KakaoMap(key: UniqueKey())));
      expect(platform.lastController!.lastHtml, contains('GlobalFont'));

      await tester.pumpWidget(host(KakaoMap(
          key: UniqueKey(), theme: const KakaoMapTheme(fontFamily: 'Local'))));
      final html = platform.lastController!.lastHtml!;
      expect(html, contains('body { font-family: Local; }'));
      expect(html, isNot(contains('GlobalFont')));
    });

    testWidgets('테마가 없으면 기본 문서는 이전과 같다 (SDK 기본 인포윈도우)', (tester) async {
      await tester.pumpWidget(host(KakaoMap()));
      final html = platform.lastController!.lastHtml!;
      expect(html, contains('const __defaultInfoWindowStyle = null'));
      expect(html, isNot(contains('!important')));
    });

    testWidgets('KakaoMapControls 의 확대 버튼은 getLevel 후 setLevel 을 보낸다',
        (tester) async {
      KakaoMapController? controller;
      await tester.pumpWidget(host(Stack(children: [
        KakaoMap(onMapCreated: (c) => controller = c),
      ])));
      final fake = platform.lastController!;
      fake.channels['onMapCreated']!.onMessageReceived(
          const JavaScriptMessage(message: '{"ready":true}'));
      await tester.pump();
      expect(controller, isNotNull);

      await tester.pumpWidget(host(Stack(children: [
        KakaoMap(onMapCreated: (c) => controller = c),
        KakaoMapControls(controller: controller!, showMapType: true),
      ])));
      await tester.pump();
      fake.scripts.clear();
      fake.returningResult = '{"level":5}';

      await tester.tap(find.byTooltip('확대'));
      await tester.pump();
      expect(fake.scripts.first, 'getLevel();');
      expect(fake.scripts.last, startsWith("setLevel('4'"));

      fake.scripts.clear();
      fake.returningResult = '{"mapTypeId":1}';
      await tester.tap(find.byTooltip('지도 타입'));
      await tester.pump();
      expect(fake.scripts, contains("setMapTypeId('2');"));
    });

    testWidgets('KakaoRoadMap(disableZoomControl:) 은 Roadview 옵션에 들어간다',
        (tester) async {
      await tester.pumpWidget(host(KakaoRoadMap(disableZoomControl: true)));
      expect(platform.lastController!.lastHtml, contains('disableZoomControl: true'));
    });
  });
}
