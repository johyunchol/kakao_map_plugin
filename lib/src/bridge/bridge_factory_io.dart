import 'kakao_map_bridge.dart';
import 'webview_bridge.dart';

/// 모바일용 브릿지를 만듭니다.
KakaoMapBridge createKakaoMapBridge({bool transparentBackground = false}) =>
    WebViewBridge(transparentBackground: transparentBackground);
