part of '../../kakao_map_plugin.dart';

/// 모든 서비스 클래스의 기본이 되는 추상 클래스입니다.
///
/// [Completer] 기반의 비동기 처리를 제공하며, 네이티브 플랫폼에서
/// 콜백으로 전달되는 JSON 응답을 처리합니다.
///
/// 타입 매개변수 [T]는 서비스가 반환할 응답 타입을 나타냅니다.
///
/// 사용 예시:
/// ```dart
/// class MyService extends BaseService<MyResponse> {
///   // 서비스 구현
/// }
/// ```
abstract class BaseService<T> {
  late Completer<T> _completer;

  /// 현재 진행 중인 비동기 작업의 [Completer]를 반환합니다.
  ///
  /// 이 completer는 네이티브 플랫폼에서 응답이 도착하면 완료됩니다.
  Completer<T> get completer => _completer;

  /// [BaseService]를 생성합니다.
  ///
  /// 생성 시 새로운 [Completer]를 초기화합니다.
  BaseService() {
    _completer = Completer<T>();
  }

  /// 완료된 completer를 새로운 completer로 초기화합니다.
  ///
  /// 이미 완료된 completer는 재사용할 수 없으므로,
  /// 새로운 요청을 위해 새 completer를 생성합니다.
  ///
  /// completer가 아직 완료되지 않았다면 아무 작업도 수행하지 않습니다.
  void resetCompleter() {
    if (_completer.isCompleted) {
      _completer = Completer<T>();
    }
  }

  /// JSON 문자열을 받아서 [T] 타입의 객체로 변환하여 completer를 완료합니다.
  ///
  /// [message]는 네이티브 플랫폼에서 전달받은 JSON 문자열입니다.
  /// [fromJson]은 JSON 맵을 [T] 타입 객체로 변환하는 함수입니다.
  ///
  /// 사용 예시:
  /// ```dart
  /// completeFromJson(
  ///   jsonString,
  ///   (json) => MyResponse.fromJson(json),
  /// );
  /// ```
  void completeFromJson(
    String message,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final resultData = jsonDecode(message);
    _completer.complete(fromJson(resultData));
  }
}
