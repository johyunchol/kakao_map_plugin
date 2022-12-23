part of kakao_map_plugin;

class AuthRepository {
  static final AuthRepository _instance = AuthRepository();

  late String appKey;

  AuthRepository();

  static AuthRepository get instance => _instance;

  factory AuthRepository.initialize({required String appKey}) {
    _instance.appKey = appKey;
    return _instance;
  }
}
