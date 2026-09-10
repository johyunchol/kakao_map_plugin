// 이 파일은 `flutter create --template=plugin` 이 생성한 메서드 채널 템플릿 잔재입니다.
// 이 플러그인은 WebView 기반으로 동작하며 이 메서드 채널을 사용하지 않고,
// `lib/kakao_map_plugin.dart` 에서도 export 되지 않는 죽은 코드입니다.
// 다만 사용자가 이 파일을 직접 import 했을 가능성을 배려해 삭제하지 않았습니다.
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'kakao_map_plugin_platform_interface.dart';

/// An implementation of [KakaoMapPluginPlatform] that uses method channels.
// ignore: deprecated_member_use_from_same_package
@Deprecated('이 플러그인이 사용하지 않는 템플릿 잔재입니다. 다음 메이저 버전에서 제거됩니다.')
class MethodChannelKakaoMapPlugin extends KakaoMapPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('kakao_map_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
