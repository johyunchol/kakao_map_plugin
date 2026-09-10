import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'kakao_map_bridge.dart';

/// Android / iOS 에서 `webview_flutter` 로 구현한 [KakaoMapBridge] 입니다.
class WebViewBridge implements KakaoMapBridge {
  final WebViewController _controller;

  /// loadHtml 에 전달된 baseUrl. 초기 문서 탐색을 허용하는 기준입니다.
  String? _baseUrl;

  /// 이미 만들어진 [WebViewController] 를 감쌉니다.
  ///
  /// `KakaoMapController(WebViewController)` 처럼 사용자가 컨트롤러를 직접
  /// 넘기는 기존 경로를 위해 남겨 둡니다. 이 경우 WebView 설정은 호출자 책임입니다.
  WebViewBridge.fromController(this._controller);

  /// 플랫폼에 맞게 설정한 새 WebView 를 만듭니다.
  ///
  /// [transparentBackground] 가 true 면 배경을 투명하게 둡니다(지도 위젯용).
  factory WebViewBridge({bool transparentBackground = false}) {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewControllerCreationParams();
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // 지도 문서 자체의 확대·축소(페이지 줌)는 앱처럼 보이지 않으므로 끕니다.
      ..enableZoom(false);
    if (transparentBackground) {
      controller.setBackgroundColor(const Color(0x00000000));
    }

    final bridge = WebViewBridge.fromController(controller);
    // 초기 문서 외의 페이지 이동(콘텐츠 안 링크 탭 등)은 지도를 사라지게 하므로 막습니다.
    // 링크 탭은 문서 안 스크립트가 onLinkTap 채널로 따로 알립니다.
    controller.setNavigationDelegate(NavigationDelegate(
      onNavigationRequest: bridge._decideNavigation,
    ));

    if (controller.platform is AndroidWebViewController) {
      if (kDebugMode) {
        AndroidWebViewController.enableDebugging(true);
      }
      final androidController = controller.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
      // 오버스크롤 글로우와 스크롤바는 지도에서 웹페이지처럼 보이는 요소이므로 끕니다.
      androidController.setOverScrollMode(WebViewOverScrollMode.never);
      androidController.setVerticalScrollBarEnabled(false);
      androidController.setHorizontalScrollBarEnabled(false);
      // Flutter 3.27+ 에서 렌더링이 멈추는 문제를 피하기 위한 권한 처리입니다.
      // 주의: 지도 표시에 필요하지 않은 권한 요청까지 승인하므로, 카메라/마이크 등
      // 민감한 권한이 필요한 페이지를 불러오지 않는 한도 내에서만 사용하세요.
      androidController.setOnPlatformPermissionRequest(
          (PlatformWebViewPermissionRequest request) async {
        await request.grant();
      });
    }

    if (controller.platform is WebKitWebViewController) {
      final webKitController = controller.platform as WebKitWebViewController;
      // 바운스와 링크 미리보기(3D Touch/롱프레스)를 끕니다.
      webKitController.setOverScrollMode(WebViewOverScrollMode.never);
      webKitController.setAllowsLinkPreview(false);
    }

    return bridge;
  }

  /// 초기 문서(loadHtml 의 baseUrl)와 about:/data: 문서만 허용하고 나머지 메인 프레임
  /// 이동은 막습니다. iframe 등 서브 프레임은 그대로 둡니다.
  NavigationDecision _decideNavigation(NavigationRequest request) {
    if (!request.isMainFrame) return NavigationDecision.navigate;
    final url = request.url;
    final initial = _baseUrl ?? 'about:blank';
    if (url.startsWith(initial) ||
        url.startsWith('about:') ||
        url.startsWith('data:')) {
      return NavigationDecision.navigate;
    }
    return NavigationDecision.prevent;
  }

  @override
  Future<void> runJavaScript(String script) => _controller.runJavaScript(script);

  @override
  Future<Object?> runJavaScriptReturningResult(String script) =>
      _controller.runJavaScriptReturningResult(script);

  @override
  void addJavaScriptChannel(String name, BridgeMessageHandler onMessage) {
    _controller.addJavaScriptChannel(
      name,
      onMessageReceived: (JavaScriptMessage message) => onMessage(message.message),
    );
  }

  @override
  Future<void> loadHtml(String html, {String? baseUrl}) {
    _baseUrl = baseUrl;
    return _controller.loadHtmlString(html, baseUrl: baseUrl);
  }

  @override
  Future<void> reload() => _controller.reload();

  @override
  Widget buildView({
    Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers =
        const <Factory<OneSequenceGestureRecognizer>>{},
  }) {
    return WebViewWidget(
      controller: _controller,
      gestureRecognizers: gestureRecognizers,
    );
  }

  @override
  WebViewController? get webViewController => _controller;

  @override
  Future<void> dispose() async {
    // WebViewController 는 위젯 트리에서 제거되면 플랫폼 뷰가 함께 정리됩니다.
  }
}
