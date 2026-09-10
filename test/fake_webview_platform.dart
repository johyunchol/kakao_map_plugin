import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

/// 테스트용 WebView 플랫폼. 실행된 JavaScript 문자열을 기록만 합니다.
class FakeWebViewPlatform extends WebViewPlatform {
  FakePlatformWebViewController? lastController;

  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    return lastController = FakePlatformWebViewController(params);
  }
}

/// 실행된 스크립트를 [scripts] 에 순서대로 쌓는 가짜 컨트롤러입니다.
class FakePlatformWebViewController extends PlatformWebViewController {
  FakePlatformWebViewController(super.params) : super.implementation();

  final List<String> scripts = [];

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
  Future<void> addJavaScriptChannel(
      JavaScriptChannelParams javaScriptChannelParams) async {}

  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) async {}
}
