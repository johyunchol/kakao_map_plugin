import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui_web;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;
import 'package:webview_flutter/webview_flutter.dart' show WebViewController;

import 'kakao_map_bridge.dart';

/// web 에서 iframe 으로 구현한 [KakaoMapBridge] 입니다.
///
/// 모바일과 같은 HTML 을 iframe 에 넣습니다. iframe 은 먼저 플러그인에 포함된
/// 빈 문서(`assets/web/kakao_map_frame.html`)를 같은 origin 의 실제 URL 로
/// 불러온 뒤 `document.write` 로 지도 HTML 을 채웁니다. `srcdoc` 을 쓰지 않는
/// 이유는 그 경우 `location` 이 `about:srcdoc` 이 되어 카카오 SDK 가 로컬 API
/// 호출에 넣는 `KA` 헤더의 origin 을 만들지 못하기 때문입니다(검색 401).
///
/// 문서가 same-origin 이라 Dart 에서 `contentWindow` 로 직접 JS 를 실행할 수
/// 있고, JS → Dart 는 `채널이름.postMessage(...)` 를 부모 창의 전역 함수로
/// 이어 주는 부트스트랩 스크립트를 문서 앞에 끼워 넣어 처리합니다. 덕분에
/// 지도 JS 코드는 모바일과 한 글자도 다르지 않습니다.
///
/// 주의: 카카오 JavaScript 키의 사이트 도메인에 이 페이지의 origin 을 등록해야
/// 지도가 표시됩니다(모바일의 `baseUrl` 우회는 web 에서 동작하지 않습니다).
class IframeBridge implements KakaoMapBridge {
  /// JS → Dart 메시지를 받는 부모 창 전역 함수 이름입니다.
  static const String _dispatchName = '__kakaoMapBridgeDispatch';

  static int _nextId = 0;
  static final Map<int, IframeBridge> _instances = <int, IframeBridge>{};
  static bool _dispatcherInstalled = false;

  final int _id;
  late final String _viewType;
  final web.HTMLIFrameElement _iframe = web.HTMLIFrameElement();
  final Map<String, BridgeMessageHandler> _channels =
      <String, BridgeMessageHandler>{};

  /// 지도 HTML 을 써 넣기 전에 불러오는 빈 문서의 URL 입니다.
  final String _frameUrl;

  Completer<void> _loaded = Completer<void>();
  String? _html;
  bool _disposed = false;

  /// 플러그인에 포함된 빈 문서의 URL 입니다.
  static String defaultFrameUrl() => ui_web.assetManager
      .getAssetUrl('packages/kakao_map_plugin/assets/web/kakao_map_frame.html');

  /// iframe 브릿지를 만듭니다.
  ///
  /// [transparentBackground] 가 true 면 iframe 배경을 투명하게 둡니다.
  /// [frameUrl] 은 테스트 등에서 빈 문서 URL 을 바꿀 때만 지정합니다.
  IframeBridge({bool transparentBackground = false, String? frameUrl})
      : _id = _nextId++,
        _frameUrl = frameUrl ?? defaultFrameUrl() {
    _viewType = 'kakao_map_plugin/iframe/$_id';
    _instances[_id] = this;
    _installDispatcher();

    _iframe
      ..style.border = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.display = 'block'
      ..style.backgroundColor = transparentBackground ? 'transparent' : '#fff';
    if (transparentBackground) {
      _iframe.setAttribute('allowtransparency', 'true');
    }
    _iframe.addEventListener('load', ((web.Event _) => _onFrameLoad()).toJS);

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _iframe,
    );
  }

  /// 부모 창에 JS → Dart 디스패처를 한 번만 설치합니다.
  static void _installDispatcher() {
    if (_dispatcherInstalled) return;
    _dispatcherInstalled = true;
    web.window.setProperty(
      _dispatchName.toJS,
      ((JSNumber id, JSString name, JSString message) {
        _instances[id.toDartInt]?._dispatch(name.toDart, message.toDart);
      }).toJS,
    );
  }

  void _dispatch(String name, String message) {
    if (_disposed) return;
    _channels[name]?.call(message);
  }

  /// 채널 객체를 만들어 주는 JS 조각입니다. 모바일 `JavaScriptChannel` 과 같은 모양입니다.
  String _channelScript(String name) =>
      'window[${jsonEncode(name)}]={postMessage:function(m){'
      'window.parent.$_dispatchName($_id,${jsonEncode(name)},String(m));}};';

  /// 문서의 다른 스크립트보다 먼저 채널 객체가 존재하도록 `<head>` 바로 뒤에 끼워 넣습니다.
  ///
  /// `__kakaoMapPluginFrame` 표식은 load 이벤트가 왔을 때 그 문서가 우리가 써 넣은
  /// 문서인지 구분하는 데 씁니다.
  String _injectBootstrap(String html) {
    // document.write 로 채운 문서에서는 브라우저가 window 의 load 이벤트를 다시
    // 보내지 않습니다(원래 문서에서 이미 한 번 보냈으므로). 지도 스크립트는
    // window.onload 에서 SDK 를 초기화하므로, readyState 가 complete 가 되면
    // 아직 load 가 오지 않았을 때 한 번만 직접 호출해 줍니다.
    const loadShim = '(function(){var fired=false;'
        'window.addEventListener("load",function(){fired=true;});'
        'document.addEventListener("readystatechange",function(){'
        'if(document.readyState!=="complete")return;'
        'setTimeout(function(){if(fired||typeof window.onload!=="function")return;'
        'fired=true;var h=window.onload;window.onload=null;h.call(window,new Event("load"));},0);'
        '});})();';
    final bootstrap = '<script>window.__kakaoMapPluginFrame=$_id;$loadShim'
        '${_channels.keys.map(_channelScript).join()}</script>';
    final idx = html.toLowerCase().indexOf('<head>');
    if (idx < 0) return bootstrap + html;
    final insertAt = idx + '<head>'.length;
    return html.substring(0, insertAt) + bootstrap + html.substring(insertAt);
  }

  Future<web.Window?> _window() async {
    await _loaded.future;
    if (_disposed) return null;
    return _iframe.contentWindow;
  }

  @override
  Future<void> runJavaScript(String script) async {
    final win = await _window();
    if (win == null) return;
    // 다른 realm 의 window.eval 은 그 창의 전역 스코프에서 실행됩니다(간접 eval).
    win.callMethod<JSAny?>('eval'.toJS, script.toJS);
  }

  @override
  Future<Object?> runJavaScriptReturningResult(String script) async {
    final win = await _window();
    if (win == null) {
      throw StateError('지도 iframe 이 이미 정리되었습니다.');
    }
    final result = win.callMethod<JSAny?>('eval'.toJS, script.toJS);
    // Android WebView(evaluateJavascript)와 같은 형식, 즉 항상 JSON 문자열로 돌려줍니다.
    // 문자열은 따옴표로 감싸이고, 객체는 직렬화되며, undefined 는 'null' 이 됩니다.
    final json = web.window
        .getProperty<JSObject>('JSON'.toJS)
        .callMethod<JSAny?>('stringify'.toJS, result);
    if (json.isUndefinedOrNull) return 'null';
    return (json as JSString).toDart;
  }

  @override
  void addJavaScriptChannel(String name, BridgeMessageHandler onMessage) {
    _channels[name] = onMessage;
    // 문서가 이미 떠 있으면 바로 채널 객체를 만들어 줍니다.
    if (_loaded.isCompleted && !_disposed) {
      unawaited(runJavaScript(_channelScript(name)).catchError((_) {}));
    }
  }

  @override
  Future<void> loadHtml(String html, {String? baseUrl}) async {
    // baseUrl 은 web 에서 의미가 없습니다. 도메인 검사는 실제 페이지 origin 으로 이뤄집니다.
    _html = _injectBootstrap(html);
    _reloadDocument();
  }

  @override
  Future<void> reload() async {
    if (_html == null) return;
    _reloadDocument();
  }

  void _reloadDocument() {
    if (_disposed) return;
    if (_loaded.isCompleted) _loaded = Completer<void>();
    // 빈 문서를 (다시) 불러오면 load 이벤트에서 지도 HTML 을 써 넣습니다.
    // 같은 URL 을 다시 대입해도 새로 탐색하므로 reload 에도 그대로 씁니다.
    _iframe.src = _frameUrl;
  }

  /// 빈 문서가 뜨면 지도 HTML 을 써 넣습니다.
  ///
  /// `document.write` 로 채운 문서의 URL 은 호출한 쪽(앱 페이지)의 URL 이 되고
  /// origin 도 앱과 같으므로, 카카오 SDK 의 도메인 검사와 KA 헤더가 앱의 origin
  /// 으로 동작합니다.
  /// 인라인 스크립트는 `close()` 안에서 동기적으로 실행되어, 이 시점부터 지도
  /// 함수들을 호출할 수 있습니다(지도 자체는 SDK 로드 후 onMapCreated 로 알립니다).
  void _onFrameLoad() {
    if (_disposed || _html == null) return;
    final win = _iframe.contentWindow;
    final doc = _iframe.contentDocument;
    if (win == null || doc == null) return;

    // 이미 우리가 써 넣은 문서가 다시 load 를 알린 경우(document.close 이후)입니다.
    final marker = win.getProperty<JSAny?>('__kakaoMapPluginFrame'.toJS);
    if (marker.isDefinedAndNotNull && marker.dartify() == _id) {
      if (!_loaded.isCompleted) _loaded.complete();
      return;
    }

    // iframe 을 문서에 붙일 때 브라우저가 먼저 알리는 초기 about:blank 로드는 건너뜁니다.
    // 여기에 써 넣으면 곧이어 빈 문서 탐색이 시작되면서 지도가 지워집니다.
    if (_frameUrl != 'about:blank' && win.location.href == 'about:blank') return;

    doc.open();
    doc.write(_html!.toJS);
    doc.close();
    if (!_loaded.isCompleted) _loaded.complete();
  }

  @override
  Widget buildView({
    Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers =
        const <Factory<OneSequenceGestureRecognizer>>{},
  }) {
    // iframe 안의 포인터 이벤트는 브라우저가 직접 처리하므로 gestureRecognizers 는 쓰이지 않습니다.
    return HtmlElementView(viewType: _viewType);
  }

  @override
  WebViewController? get webViewController => null;

  /// 테스트에서 iframe 을 문서에 직접 붙이기 위한 접근자입니다.
  @visibleForTesting
  web.HTMLIFrameElement get iframeElement => _iframe;

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _instances.remove(_id);
    _channels.clear();
    _html = null;
    _iframe.removeAttribute('src');
  }
}
