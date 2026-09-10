@TestOn('vm')
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'fake_webview_platform.dart';

/// KakaoMap 위젯이 rebuild 시 어떤 JS 를 보내는지 검증합니다.
void main() {
  late FakeWebViewPlatform platform;

  setUp(() {
    platform = FakeWebViewPlatform();
    WebViewPlatform.instance = platform;
    AuthRepository.initialize(appKey: 'test-key');
  });

  FakePlatformWebViewController fake() => platform.lastController!;

  /// JS 쪽 onMapCreated 를 흉내 내 위젯을 준비 상태로 만듭니다.
  Future<void> mapReady(WidgetTester tester) async {
    fake()
        .channels['onMapCreated']!
        .onMessageReceived(const JavaScriptMessage(message: '{"ready":true}'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    fake().scripts.clear();
  }

  Widget host(KakaoMap map) =>
      MaterialApp(home: SizedBox(width: 400, height: 600, child: map));

  testWidgets('center / currentLevel / minLevel / maxLevel 변경이 JS 로 전달된다',
      (tester) async {
    await tester.pumpWidget(host(KakaoMap(
      center: LatLng(37.5, 127.0),
      currentLevel: 3,
      minLevel: 1,
      maxLevel: 14,
    )));
    await mapReady(tester);

    await tester.pumpWidget(host(KakaoMap(
      center: LatLng(37.6, 127.1),
      currentLevel: 5,
      minLevel: 2,
      maxLevel: 10,
    )));
    await tester.pump();

    final scripts = fake().scripts;
    expect(scripts.any((s) => s.startsWith('setCenter(37.6, 127.1')), isTrue,
        reason: scripts.join('\n'));
    expect(scripts, contains("setLevel('5');"));
    expect(scripts, contains('setMinLevel(2);'));
    expect(scripts, contains('setMaxLevel(10);'));
  });

  testWidgets('값이 그대로면 카메라 관련 JS 를 다시 보내지 않는다', (tester) async {
    Widget build() => host(KakaoMap(
          center: LatLng(37.5, 127.0),
          currentLevel: 3,
          minLevel: 1,
          maxLevel: 14,
        ));
    await tester.pumpWidget(build());
    await mapReady(tester);

    await tester.pumpWidget(build());
    await tester.pump();

    expect(
      fake().scripts.where((s) =>
          s.startsWith('setCenter(') ||
          s.startsWith('setLevel(') ||
          s.startsWith('setMinLevel(') ||
          s.startsWith('setMaxLevel(')),
      isEmpty,
    );
  });

  testWidgets('지도 생성 옵션이 초기 HTML 의 Map 옵션에 들어간다', (tester) async {
    await tester.pumpWidget(host(KakaoMap(
      mapTypeId: MapType.skyView,
      disableDoubleClickZoom: true,
      scrollwheel: false,
    )));
    final html = fake().lastHtml!;
    expect(html, contains('mapTypeId: 2'));
    expect(html, contains('disableDoubleClickZoom: true'));
    expect(html, contains('scrollwheel: false'));
    // 지정하지 않은 옵션은 SDK 기본값을 쓰도록 넣지 않는다.
    expect(html, isNot(contains('keyboardShortcuts')));
    expect(html, isNot(contains('disableDoubleClick:')));
  });

  testWidgets('onLinkTap 채널 메시지가 Uri 로 전달된다', (tester) async {
    Uri? tapped;
    await tester.pumpWidget(host(KakaoMap(onLinkTap: (url) => tapped = url)));
    await mapReady(tester);

    fake().channels['onLinkTap']!.onMessageReceived(JavaScriptMessage(
        message: jsonEncode({'url': 'https://place.map.kakao.com/123'})));
    expect(tapped, Uri.parse('https://place.map.kakao.com/123'));
  });

  testWidgets('onMapTypeChanged 는 숫자 ID 를 MapType 으로, 그 외는 normal 로 전달한다',
      (tester) async {
    final received = <MapType>[];
    await tester.pumpWidget(host(KakaoMap(onMapTypeChanged: received.add)));
    await mapReady(tester);

    final channel = fake().channels['mapTypeChanged']!;
    channel.onMessageReceived(const JavaScriptMessage(message: '{"mapTypeId":2}'));
    channel.onMessageReceived(
        const JavaScriptMessage(message: '{"mapTypeId":"MY_TILES"}'));
    expect(received, [MapType.skyView, MapType.normal]);
    // 콜백이 있을 때만 JS 리스너가 등록된다.
    expect(fake().lastHtml, contains("'maptypeid_changed'"));
  });

  testWidgets('기본 HTML 에 앱 느낌용 스타일과 링크 가로채기 스크립트가 들어간다',
      (tester) async {
    await tester.pumpWidget(host(KakaoMap()));
    final html = fake().lastHtml!;
    expect(html, contains('<html lang="ko">'));
    expect(html, contains('-webkit-tap-highlight-color: transparent'));
    expect(html, contains('user-select: none'));
    expect(html, contains('.kmp-selectable'));
    expect(html, contains("onLinkTap.postMessage"));
    expect(html, contains("'contextmenu'"));
  });

  testWidgets('KakaoStaticMap 은 마커 텍스트의 </script> 를 이스케이프한다',
      (tester) async {
    await tester.pumpWidget(host2(KakaoStaticMap(
      markers: [
        Marker(
          markerId: 'm',
          latLng: LatLng(37.5, 127.0),
          infoWindowContent: '</script><img src=x onerror=alert(1)>',
        ),
      ],
    )));
    final html = platform.lastController!.lastHtml!;
    expect(html, isNot(contains('</script><img')));
    expect(html, contains(r'\u003c/script>\u003cimg'));
  });
}

Widget host2(Widget child) =>
    MaterialApp(home: SizedBox(width: 400, height: 600, child: child));
