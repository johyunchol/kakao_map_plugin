part of kakao_map_plugin;

/// kakao app key repository
class AuthRepository {
  static final AuthRepository _instance = AuthRepository();

  /// kakao map javascript app key
  late String appKey;
  late String baseUrl;

  AuthRepository();

  static AuthRepository get instance => _instance;

  factory AuthRepository.initialize({required String appKey,required String baseUrl}) {
    _instance.appKey = appKey;
    _instance.baseUrl = baseUrl;

    return _instance;
  }
}
