// web 플랫폼 진입점입니다.
//
// 지도 자체는 위젯이 `IframeBridge` 로 직접 그리므로 여기서 할 일은 없고,
// pubspec 의 web 플랫폼 등록을 위해 registerWith 만 제공합니다.
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'kakao_map_plugin_platform_interface.dart';

/// web 플랫폼 플러그인 등록 클래스입니다.
///
/// 지도 위젯은 iframe 브릿지로 동작하므로 이 클래스는 플랫폼 등록 외의 기능이 없습니다.
// ignore: deprecated_member_use_from_same_package
class KakaoMapPluginWeb extends KakaoMapPluginPlatform {
  /// Constructs a KakaoMapPluginWeb
  KakaoMapPluginWeb();

  static void registerWith(Registrar registrar) {
    // ignore: deprecated_member_use_from_same_package
    KakaoMapPluginPlatform.instance = KakaoMapPluginWeb();
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = web.window.navigator.userAgent;
    return version;
  }
}
