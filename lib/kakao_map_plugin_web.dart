import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'kakao_map_plugin_platform_interface.dart';

/// A web implementation of the KakaoMapPluginPlatform of the KakaoMapPlugin plugin.
class KakaoMapPluginWeb extends KakaoMapPluginPlatform {
  /// Constructs a KakaoMapPluginWeb
  KakaoMapPluginWeb();

  static void registerWith(Registrar registrar) {
    KakaoMapPluginPlatform.instance = KakaoMapPluginWeb();
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = web.window.navigator.userAgent;
    return version;
  }
}
