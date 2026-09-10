// 이 파일은 `flutter create --template=plugin` 이 생성한 플랫폼 인터페이스 템플릿 잔재입니다.
// 이 플러그인은 WebView 기반으로 동작하며 이 플랫폼 인터페이스 계층을 사용하지 않고,
// `lib/kakao_map_plugin.dart` 에서도 export 되지 않는 죽은 코드입니다.
// 다만 사용자가 이 파일을 직접 import 했을 가능성을 배려해 삭제하지 않았습니다.
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'kakao_map_plugin_method_channel.dart';

@Deprecated('이 플러그인이 사용하지 않는 템플릿 잔재입니다. 다음 메이저 버전에서 제거됩니다.')
abstract class KakaoMapPluginPlatform extends PlatformInterface {
  /// Constructs a KakaoMapPluginPlatform.
  KakaoMapPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  // ignore: deprecated_member_use_from_same_package
  static KakaoMapPluginPlatform _instance = MethodChannelKakaoMapPlugin();

  /// The default instance of [KakaoMapPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelKakaoMapPlugin].
  static KakaoMapPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [KakaoMapPluginPlatform] when
  /// they register themselves.
  static set instance(KakaoMapPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
