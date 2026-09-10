import 'package:flutter/foundation.dart';

/// JS 가 결과를 `JSON.stringify` 로 감싸서 돌려줘야 하는 플랫폼인지 여부입니다.
///
/// iOS(WKWebView)는 객체를 그대로 돌려주면 Dart 에서 읽을 수 없어 문자열로
/// 감싸야 합니다. Android WebView 는 스스로 JSON 문자열로 바꿔 주고, web 의
/// iframe 브릿지도 같은 형식으로 정규화하므로 둘 다 false 입니다.
bool get isIOSWebView => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
