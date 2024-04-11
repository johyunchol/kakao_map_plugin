part of '../../kakao_map_plugin.dart';

/// kakao app key repository
class AuthRepository {
  static final AuthRepository _instance = AuthRepository();

  /// kakao map javascript app key
  late String appKey;
  String? baseUrl;

  AuthRepository();

  static AuthRepository get instance => _instance;

  factory AuthRepository.initialize({required String appKey, String? baseUrl}) {
    _instance.appKey = appKey;
    _instance.baseUrl = baseUrl;

    return _instance;
  }
}
