// 현재 플랫폼에 맞는 KakaoMapBridge 구현을 고릅니다.
// 모바일(dart:io 계열)은 WebView, web(dart:js_interop)은 iframe 구현을 씁니다.
export 'bridge_factory_io.dart'
    if (dart.library.js_interop) 'bridge_factory_web.dart';
