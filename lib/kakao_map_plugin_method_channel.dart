import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'kakao_map_plugin_platform_interface.dart';

/// An implementation of [KakaoMapPluginPlatform] that uses method channels.
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
