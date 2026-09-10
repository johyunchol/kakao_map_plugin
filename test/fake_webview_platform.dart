import 'package:flutter/widgets.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

/// 테스트용 WebView 플랫폼. 실행된 JavaScript 문자열을 기록만 합니다.
///
/// 위젯 테스트에서 `KakaoMap` 을 pump 할 수 있도록 뷰 위젯과 네비게이션 델리게이트도
/// 빈 구현으로 제공합니다.
class FakeWebViewPlatform extends WebViewPlatform {
  FakePlatformWebViewController? lastController;

  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    return lastController = FakePlatformWebViewController(params);
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) {
    return FakePlatformWebViewWidget(params);
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) {
    return FakePlatformNavigationDelegate(params);
  }
}

/// 실행된 스크립트를 [scripts] 에 순서대로 쌓는 가짜 컨트롤러입니다.
class FakePlatformWebViewController extends PlatformWebViewController {
  FakePlatformWebViewController(super.params) : super.implementation();

  final List<String> scripts = [];

  /// 등록된 JS 채널. 테스트에서 `channels['onMapCreated']!.onMessageReceived(...)`
  /// 로 JS → Dart 메시지를 흉내 냅니다.
  final Map<String, JavaScriptChannelParams> channels = {};

  /// 마지막으로 불러온 HTML 문서입니다.
  String? lastHtml;

  /// `runJavaScriptReturningResult` 가 돌려줄 값입니다.
  Object returningResult = '{}';

  @override
  Future<void> runJavaScript(String javaScript) async {
    scripts.add(javaScript);
  }

  @override
  Future<Object> runJavaScriptReturningResult(String javaScript) async {
    scripts.add(javaScript);
    return returningResult;
  }

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {}

  @override
  Future<void> setBackgroundColor(color) async {}

  @override
  Future<void> enableZoom(bool enabled) async {}

  @override
  Future<void> setPlatformNavigationDelegate(
      PlatformNavigationDelegate handler) async {}

  @override
  Future<void> addJavaScriptChannel(
      JavaScriptChannelParams javaScriptChannelParams) async {
    channels[javaScriptChannelParams.name] = javaScriptChannelParams;
  }

  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) async {
    lastHtml = html;
  }

  @override
  Future<void> reload() async {
    scripts.add('__reload__');
  }
}

/// 아무것도 그리지 않는 가짜 뷰 위젯입니다.
class FakePlatformWebViewWidget extends PlatformWebViewWidget {
  FakePlatformWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

/// 콜백을 받기만 하는 가짜 네비게이션 델리게이트입니다.
class FakePlatformNavigationDelegate extends PlatformNavigationDelegate {
  FakePlatformNavigationDelegate(super.params) : super.implementation();

  NavigationRequestCallback? onNavigationRequest;

  @override
  Future<void> setOnNavigationRequest(
      NavigationRequestCallback onNavigationRequest) async {
    this.onNavigationRequest = onNavigationRequest;
  }

  @override
  Future<void> setOnPageStarted(PageEventCallback onPageStarted) async {}

  @override
  Future<void> setOnPageFinished(PageEventCallback onPageFinished) async {}

  @override
  Future<void> setOnProgress(ProgressCallback onProgress) async {}

  @override
  Future<void> setOnWebResourceError(
      WebResourceErrorCallback onWebResourceError) async {}

  @override
  Future<void> setOnUrlChange(UrlChangeCallback onUrlChange) async {}

  @override
  Future<void> setOnHttpAuthRequest(
      HttpAuthRequestCallback onHttpAuthRequest) async {}

  @override
  Future<void> setOnHttpError(HttpResponseErrorCallback onHttpError) async {}
}
