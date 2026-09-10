import '../basic/constants/kakao_map_library.dart';

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
  // ignore: deprecated_member_use_from_same_package
  static final AuthRepository _instance = AuthRepository();

  /// 내부 앱 키 저장소입니다.
  String? _appKey;

  /// 카카오 지도 JavaScript 앱 키입니다.
  ///
  /// 카카오 디벨로퍼스에서 발급받은 JavaScript 키를 설정합니다.
  /// [initialize]를 호출하기 전에 접근하면 [StateError]가 발생합니다.
  String get appKey {
    if (_appKey == null) {
      throw StateError(
        'AuthRepository가 초기화되지 않았습니다. '
        'AuthRepository.initialize(appKey: "your_key")를 먼저 호출하세요.',
      );
    }
    return _appKey!;
  }

  /// 앱 키를 직접 설정합니다. [AuthRepository.initialize] 사용을 권장합니다.
  set appKey(String value) => _appKey = value;

  /// 카카오 API의 기본 URL입니다.
  ///
  /// 기본값은 카카오의 공식 API URL이며, 필요에 따라 커스텀 URL을 설정할 수 있습니다.
  String? baseUrl;

  /// 내부 라이브러리 집합 저장소입니다.
  Set<KakaoMapLibrary>? _libraries;

  /// 지도와 함께 불러올 확장 라이브러리 집합입니다.
  ///
  /// 설정하지 않으면 [KakaoMapLibrary.all](전체)을 사용하므로 기존과 동일하게 동작합니다.
  /// 사용하지 않는 라이브러리를 제외하면 지도 생성 시 다운로드/파싱 비용이 줄어듭니다.
  ///
  /// 개별 지도에서 다르게 지정하려면 `KakaoMap(libraries: ...)` 을 사용하세요.
  Set<KakaoMapLibrary> get libraries => _libraries ?? KakaoMapLibrary.all;

  /// 지도와 함께 불러올 확장 라이브러리 집합을 설정합니다.
  ///
  /// null 을 넣으면 기본값(전체)으로 되돌아갑니다.
  set libraries(Set<KakaoMapLibrary>? value) => _libraries = value;

  /// public 기본 생성자입니다.
  ///
  /// 이 생성자로 직접 인스턴스를 생성해도 싱글톤이 되지 않으며,
  /// 라이브러리는 해당 인스턴스를 전혀 참조하지 않습니다(즉, [instance] 와 상태가 다릅니다).
  /// 싱글톤 접근은 [instance] 또는 [initialize] 를 사용하세요.
  @Deprecated(
    'AuthRepository.instance 또는 AuthRepository.initialize() 를 사용하세요. '
    '직접 생성한 인스턴스는 라이브러리가 참조하지 않습니다.',
  )
  AuthRepository();

  /// [AuthRepository]의 싱글톤 인스턴스를 반환합니다.
  static AuthRepository get instance => _instance;

  /// 초기화 여부를 확인합니다.
  ///
  /// Returns: 초기화되었으면 true, 아니면 false
  static bool get isInitialized => _instance._appKey != null;

  /// [AuthRepository]를 초기화합니다.
  ///
  /// [appKey]는 필수이며, 카카오 디벨로퍼스에서 발급받은 JavaScript 키를 입력합니다.
  /// [baseUrl]은 선택사항이며, 커스텀 API URL이 필요한 경우 설정합니다.
  /// [libraries]는 선택사항이며, 지도와 함께 불러올 확장 라이브러리를 지정합니다.
  /// 생략하면 기존과 동일하게 전체([KakaoMapLibrary.all])를 불러옵니다.
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
  factory AuthRepository.initialize({
    required String appKey,
    String? baseUrl,
    Set<KakaoMapLibrary>? libraries,
  }) {
    _instance._appKey = appKey;
    _instance.baseUrl = baseUrl;
    _instance._libraries = libraries;

    return _instance;
  }
}
