part of kakao_map_plugin;

/// kakao app key repository
class AuthRepository {
  static final AuthRepository _instance = AuthRepository();

  /// kakao map javascript app key
  late String appKey;

  AuthRepository();

  static AuthRepository get instance => _instance;

  factory AuthRepository.initialize({required String appKey}) {
    _instance.appKey = appKey;
    return _instance;
  }
}
