import 'iframe_bridge.dart';
import 'kakao_map_bridge.dart';

/// web 용 브릿지(iframe)를 만듭니다.
KakaoMapBridge createKakaoMapBridge({bool transparentBackground = false}) =>
    IframeBridge(transparentBackground: transparentBackground);
