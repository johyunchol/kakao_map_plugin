// 이 파일은 `flutter create --template=plugin` 이 생성한 웹 플랫폼 템플릿 잔재입니다.
// 이 플러그인은 WebView 기반으로 동작하며 web 플랫폼을 지원하지 않고
// (pubspec.yaml 의 `flutter.plugin.platforms` 에도 web 이 등록되어 있지 않음),
// `lib/kakao_map_plugin.dart` 에서도 export 되지 않는 죽은 코드입니다.
// 다만 사용자가 이 파일을 직접 import 했을 가능성을 배려해 삭제하지 않았습니다.
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'kakao_map_plugin_platform_interface.dart';

/// A web implementation of the KakaoMapPluginPlatform of the KakaoMapPlugin plugin.
@Deprecated('이 플러그인이 사용하지 않는 템플릿 잔재입니다. 다음 메이저 버전에서 제거됩니다.')
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
