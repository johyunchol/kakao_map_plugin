import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// JS 채널로 들어온 메시지를 받는 콜백입니다.
typedef BridgeMessageHandler = void Function(String message);

/// Dart 와 카카오 지도 JavaScript 사이의 통신 계층입니다.
///
/// 이 플러그인의 JS 코드는 두 가지 규약만 사용합니다.
///
/// - Dart → JS: 함수 호출 문자열을 실행 ([runJavaScript], [runJavaScriptReturningResult])
/// - JS → Dart: `채널이름.postMessage(JSON 문자열)` ([addJavaScriptChannel])
///
/// 모바일은 WebView 로, web 은 iframe 으로 이 규약을 구현합니다. 위젯과
/// 컨트롤러는 이 인터페이스만 사용하므로 플랫폼별 구현을 알 필요가 없습니다.
abstract class KakaoMapBridge {
  /// JS 를 실행합니다. 반환값은 버립니다.
  Future<void> runJavaScript(String script);

  /// JS 를 실행하고 결과를 돌려줍니다.
  ///
  /// 결과 형식은 플랫폼마다 다릅니다(Android 는 JSON 문자열, iOS 는 원시 값
  /// 또는 JS 쪽에서 `JSON.stringify` 한 문자열). 호출 측에서 이중 디코드로
  /// 정규화합니다.
  Future<Object?> runJavaScriptReturningResult(String script);

  /// JS 에서 `name.postMessage(message)` 로 호출할 수 있는 채널을 등록합니다.
  ///
  /// HTML 을 불러오기 전에 등록해야 합니다.
  void addJavaScriptChannel(String name, BridgeMessageHandler onMessage);

  /// HTML 문서를 불러옵니다. [baseUrl] 은 카카오 앱키 도메인 검사에 쓰입니다.
  Future<void> loadHtml(String html, {String? baseUrl});

  /// 문서를 다시 불러옵니다.
  Future<void> reload();

  /// 지도를 그릴 위젯을 만듭니다.
  Widget buildView({
    Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers =
        const <Factory<OneSequenceGestureRecognizer>>{},
  });

  /// 모바일 WebView 컨트롤러입니다. WebView 를 쓰지 않는 플랫폼(web)에서는 null 입니다.
  WebViewController? get webViewController;

  /// 브릿지가 잡고 있는 자원을 정리합니다. 위젯이 dispose 될 때 호출합니다.
  Future<void> dispose();
}
