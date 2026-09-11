@TestOn('browser')
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kakao_map_plugin/src/bridge/iframe_bridge.dart';
import 'package:web/web.dart' as web;

/// 채널 부트스트랩이 문서의 스크립트보다 먼저 실행되는지 확인하기 위해,
/// 문서 본문에서 곧바로 postMessage 를 호출하는 HTML 입니다.
String html(String body) => '<!DOCTYPE html><html><head><meta charset="utf-8">'
    '</head><body><script>$body</script></body></html>';

void main() {
  late IframeBridge bridge;

  setUp(() {
    bridge = IframeBridge(frameUrl: 'about:blank');
    web.document.body!.appendChild(bridge.iframeElement);
  });

  tearDown(() async {
    await bridge.dispose();
    bridge.iframeElement.remove();
  });

  test('문서 스크립트가 등록한 채널로 보낸 메시지가 Dart 콜백에 도착한다', () async {
    final received = Completer<String>();
    bridge.addJavaScriptChannel('ping', received.complete);

    await bridge.loadHtml(html('ping.postMessage("hi"); window.answer = 42;'));

    expect(await received.future.timeout(const Duration(seconds: 5)), 'hi');
    // 채널 객체 모양이 모바일 JavaScriptChannel 과 같다.
    expect(await bridge.runJavaScriptReturningResult('typeof ping.postMessage'),
        '"function"');
  });

  test('runJavaScriptReturningResult 는 Android WebView 처럼 항상 JSON 문자열을 돌려준다',
      () async {
    await bridge.loadHtml(html('window.obj = {a: 1, b: "x"};'));

    expect(await bridge.runJavaScriptReturningResult('42'), '42');
    expect(await bridge.runJavaScriptReturningResult('"s"'), '"s"');
    expect(await bridge.runJavaScriptReturningResult('obj'), '{"a":1,"b":"x"}');
    expect(await bridge.runJavaScriptReturningResult('null'), 'null');
    expect(await bridge.runJavaScriptReturningResult('undefined'), 'null');
    expect(await bridge.runJavaScriptReturningResult('[1,2]'), '[1,2]');
  });

  test('runJavaScript 는 iframe 전역 스코프에서 실행된다', () async {
    await bridge
        .loadHtml(html('window.count = 0; function inc() { count++; }'));

    await bridge.runJavaScript('inc(); inc();');
    expect(await bridge.runJavaScriptReturningResult('count'), '2');
  });

  test('reload 하면 문서가 처음부터 다시 실행되어 채널이 다시 발화한다', () async {
    var hits = 0;
    bridge.addJavaScriptChannel('boot', (_) => hits++);
    await bridge.loadHtml(html('boot.postMessage("1");'));
    await bridge.runJavaScript(''); // 첫 로드 대기
    expect(hits, 1);

    await bridge.reload();
    await bridge.runJavaScript(''); // 재로드 대기
    expect(hits, 2);
  });

  test('로드 후 등록한 채널도 바로 사용할 수 있다', () async {
    await bridge.loadHtml(html(''));
    await bridge.runJavaScript('');

    final received = Completer<String>();
    bridge.addJavaScriptChannel('late', received.complete);
    await bridge.runJavaScript('late.postMessage("ok")');
    expect(await received.future.timeout(const Duration(seconds: 5)), 'ok');
  });

  test('dispose 뒤에는 메시지가 전달되지 않고 JS 실행도 조용히 무시된다', () async {
    var hits = 0;
    bridge.addJavaScriptChannel('c', (_) => hits++);
    await bridge.loadHtml(html('window.c2 = c;'));
    await bridge.runJavaScript('');

    await bridge.dispose();
    await bridge.runJavaScript('c2.postMessage("x")'); // 무시
    expect(hits, 0);
    expect(() => bridge.runJavaScriptReturningResult('1'), throwsStateError);
  });

  test('브릿지 여러 개가 각자 자기 채널만 받는다', () async {
    final other = IframeBridge(frameUrl: 'about:blank');
    web.document.body!.appendChild(other.iframeElement);
    addTearDown(() async {
      await other.dispose();
      other.iframeElement.remove();
    });

    final a = <String>[];
    final b = <String>[];
    bridge.addJavaScriptChannel('msg', a.add);
    other.addJavaScriptChannel('msg', b.add);
    await bridge.loadHtml(html('msg.postMessage("A");'));
    await other.loadHtml(html('msg.postMessage("B");'));
    await bridge.runJavaScript('');
    await other.runJavaScript('');

    expect(a, ['A']);
    expect(b, ['B']);
  });
}
