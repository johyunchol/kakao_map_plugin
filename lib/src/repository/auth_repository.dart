/// 카카오 API 인증 정보를 관리하는 저장소입니다.
///
/// 카카오 지도 및 로컬 API를 사용하기 위한 인증 정보를 저장하고 관리합니다.
/// 싱글톤 패턴으로 구현되어 있어 앱 전체에서 동일한 인증 정보를 사용합니다.
///
/// 사용 예시:
/// ```dart
/// AuthRepository.initialize(
///   appKey: 'your_javascript_app_key',
///   baseUrl: 'https://custom-base-url.com', // 선택사항
/// );
/// ```
class AuthRepository {
  static final AuthRepository _instance = AuthRepository();

  /// 카카오 지도 JavaScript 앱 키입니다.
  ///
  /// 카카오 디벨로퍼스에서 발급받은 JavaScript 키를 설정합니다.
  late String appKey;

  /// 카카오 API의 기본 URL입니다.
  ///
  /// 기본값은 카카오의 공식 API URL이며, 필요에 따라 커스텀 URL을 설정할 수 있습니다.
  String? baseUrl;

  /// private 생성자로 싱글톤 패턴을 구현합니다.
  AuthRepository();

  /// [AuthRepository]의 싱글톤 인스턴스를 반환합니다.
  static AuthRepository get instance => _instance;

  /// [AuthRepository]를 초기화합니다.
  ///
  /// [appKey]는 필수이며, 카카오 디벨로퍼스에서 발급받은 JavaScript 키를 입력합니다.
  /// [baseUrl]은 선택사항이며, 커스텀 API URL이 필요한 경우 설정합니다.
  ///
  /// 앱 시작 시 한 번만 호출해야 합니다.
  ///
  /// 사용 예시:
  /// ```dart
  /// void main() {
  ///   AuthRepository.initialize(
  ///     appKey: 'your_javascript_app_key',
  ///   );
  ///   runApp(MyApp());
  /// }
  /// ```
  factory AuthRepository.initialize({required String appKey, String? baseUrl}) {
    _instance.appKey = appKey;
    _instance.baseUrl = baseUrl;

    return _instance;
  }
}
