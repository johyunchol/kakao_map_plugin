import 'dart:async';
import 'dart:convert';

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

  /// 요청 ID별로 관리되는 대기 중인 [Completer] 목록입니다.
  ///
  /// 동시에 여러 요청이 발생해도 응답이 서로 뒤섞이지 않도록,
  /// 요청마다 고유한 ID를 발급하여 개별적으로 완료 처리합니다.
  final Map<int, Completer<T>> _pending = {};

  /// 다음에 발급할 요청 ID입니다.
  int _nextRequestId = 0;

  /// [BaseService]를 생성합니다.
  ///
  /// 생성 시 새로운 [Completer]를 초기화합니다.
  BaseService() {
    _completer = Completer<T>();
  }

  /// completer를 새로운 completer로 초기화합니다.
  ///
  /// 이미 완료된 completer는 재사용할 수 없으므로,
  /// 새로운 요청을 위해 새 completer를 생성합니다.
  ///
  /// 동시 요청 시 경쟁 조건을 방지하기 위해 항상 새 completer를 생성합니다.
  ///
  /// 이전 completer가 아직 완료되지 않은 상태였다면(예: 이전 요청의 응답을 기다리던 중
  /// 새 요청이 시작된 경우), 그 completer를 [StateError]로 종료하여 무기한 대기를 방지합니다.
  /// (동작 변경: 과거에는 이런 경우 이전 completer가 영구히 대기 상태로 남았습니다.)
  void resetCompleter() {
    if (!_completer.isCompleted) {
      // 대기 중인 리스너가 없을 수도 있으므로 unhandled error 로 보고되지 않게 한다.
      _completer.future.ignore();
      _completer.completeError(StateError('새 요청으로 대체되었습니다.'));
    }
    _completer = Completer<T>();
  }

  /// JSON 문자열을 받아서 [T] 타입의 객체로 변환하여 completer를 완료합니다.
  ///
  /// [message]는 네이티브 플랫폼에서 전달받은 JSON 문자열입니다.
  /// [fromJson]은 JSON 맵을 [T] 타입 객체로 변환하는 함수입니다.
  ///
  /// JSON 파싱 또는 변환 중 오류가 발생하면 completer를 에러로 완료합니다.
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
    try {
      final resultData = jsonDecode(message);
      _completer.complete(fromJson(resultData));
    } catch (e) {
      if (!_completer.isCompleted) {
        // 대기 중인 리스너가 없을 수도 있으므로 unhandled error 로 보고되지 않게 한다.
        _completer.future.ignore();
        _completer.completeError(e);
      }
    }
  }

  /// 새 요청을 등록하고 요청 ID를 반환합니다. (동시 요청 시 응답 혼선 방지)
  ///
  /// 반환된 ID는 [requestFuture]로 응답을 기다리거나,
  /// [failRequest]로 강제 종료할 때 사용합니다.
  int createRequest() {
    final id = ++_nextRequestId;
    _pending[id] = Completer<T>();
    return id;
  }

  /// [requestId]에 해당하는 응답 [Future]를 반환합니다.
  ///
  /// [createRequest]로 발급되지 않은 ID가 전달되면 [StateError]가 발생합니다.
   /// [requestId] 에 해당하는 응답 Future 를 반환합니다.
  ///
  /// [timeout] 안에 응답이 오지 않으면 대기 항목을 정리하고 [TimeoutException] 으로
  /// 완료합니다(WebView 파괴, 네트워크 단절 등으로 콜백이 영영 오지 않는 경우 대비).
  /// null 이면 제한 없이 대기합니다.
  ///
  /// 존재하지 않는 ID 면 [StateError] 를 던집니다.
  Future<T> requestFuture(
    int requestId, {
    Duration? timeout = const Duration(seconds: 60),
  }) {
    final completer = _pending[requestId];
    if (completer == null) {
      throw StateError('요청 ID $requestId 에 해당하는 요청을 찾을 수 없습니다.');
    }
    if (timeout == null) return completer.future;
    return completer.future.timeout(timeout, onTimeout: () {
      _pending.remove(requestId);
      final error = TimeoutException(
          '요청 $requestId 의 응답이 ${timeout.inSeconds}초 안에 도착하지 않았습니다.');
      // 늦게 도착하는 JS 콜백이 handleMessage 에서 completer==null 로 무시되면서
      // 레거시 xxxResult() 대기가 영원히 끝나지 않는 것을 막기 위해 레거시 경로도 종료한다.
      _mirrorErrorToLegacy(error);
      throw error;
    });
  }

  /// [requestId] 요청을 에러로 종료합니다.
  ///
  /// 해당 [requestId]가 이미 존재하지 않으면 아무 동작도 하지 않습니다.
  void failRequest(int requestId, Object error, [StackTrace? stackTrace]) {
    final completer = _pending.remove(requestId);
    if (completer != null && !completer.isCompleted) {
      completer.completeError(error, stackTrace);
    }
  }

  /// 요청 ID 경로의 결과를 레거시 [completer] 에도 반영합니다.
  ///
  /// `controller.keywordSearch()` 호출 후 `KeywordSearchService.keywordSearchResult()` 를
  /// 별도로 기다리던 기존 코드가 계속 동작하도록 하기 위한 하위호환 처리입니다.
  void _mirrorResultToLegacy(T result) {
    if (!_completer.isCompleted) {
      _completer.complete(result);
    }
  }

  void _mirrorErrorToLegacy(Object error, [StackTrace? stackTrace]) {
    if (!_completer.isCompleted) {
      // 대기 중인 리스너가 없을 수도 있으므로 unhandled error 로 보고되지 않게 한다.
      _completer.future.ignore();
      _completer.completeError(error, stackTrace);
    }
  }

  /// JS 채널을 통해 전달된 메시지를 처리합니다.
  ///
  /// 요청 ID가 포함된 신규 형태의 메시지는 해당 요청의 completer로 라우팅되고,
  /// 요청 ID가 없는 레거시 형태의 메시지는 기존 [completer]로 처리됩니다.
  ///
  /// 지원하는 메시지 형태:
  /// - `{"requestId": 3, "result": [...]}`: 요청 ID 3에 해당하는 요청을 성공으로 완료
  /// - `{"requestId": 3, "error": "ZERO_RESULT"}`: 요청 ID 3에 해당하는 요청을 에러로 완료
  /// - 그 외 (레거시): 완료되지 않은 [completer]가 있으면 완료, 이미 완료된 경우 무시
  ///
  /// JSON 파싱이나 [fromJson] 변환 중 예외가 발생해도 해당 completer를
  /// 에러로 종료할 뿐, 예외를 밖으로 전파하지 않습니다.
  void handleMessage(String message, T Function(dynamic json) fromJson) {
    dynamic decoded;
    try {
      decoded = jsonDecode(message);
    } catch (e, stackTrace) {
      if (!_completer.isCompleted) {
        // 대기 중인 리스너가 없을 수도 있으므로 unhandled error 로 보고되지 않게 한다.
        _completer.future.ignore();
        _completer.completeError(e, stackTrace);
      }
      return;
    }

    if (decoded is Map && decoded.containsKey('requestId')) {
      final requestId = (decoded['requestId'] as num).toInt();
      final completer = _pending.remove(requestId);
      if (completer == null) {
        // 이미 timeout 등으로 제거된 요청입니다. 신규 completer 는 없지만, 레거시
        // xxxResult() 경로가 이 응답을 여전히 기다리고 있을 수 있으므로 반영합니다.
        if (decoded.containsKey('error')) {
          _mirrorErrorToLegacy(StateError(decoded['error'].toString()));
        } else {
          try {
            _mirrorResultToLegacy(fromJson(decoded['result']));
          } catch (e, stackTrace) {
            _mirrorErrorToLegacy(e, stackTrace);
          }
        }
        return;
      }
      if (decoded.containsKey('error')) {
        final error = StateError(decoded['error'].toString());
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
        _mirrorErrorToLegacy(error);
        return;
      }
      try {
        final result = fromJson(decoded['result']);
        if (!completer.isCompleted) {
          completer.complete(result);
        }
        _mirrorResultToLegacy(result);
      } catch (e, stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(e, stackTrace);
        }
        _mirrorErrorToLegacy(e, stackTrace);
      }
      return;
    }

    // 레거시 메시지 처리: 요청 ID 없이 단일 completer로 처리합니다.
    if (_completer.isCompleted) {
      return;
    }
    try {
      final result = fromJson(decoded);
      _completer.complete(result);
    } catch (e, stackTrace) {
      if (!_completer.isCompleted) {
        // 대기 중인 리스너가 없을 수도 있으므로 unhandled error 로 보고되지 않게 한다.
        _completer.future.ignore();
        _completer.completeError(e, stackTrace);
      }
    }
  }
}
