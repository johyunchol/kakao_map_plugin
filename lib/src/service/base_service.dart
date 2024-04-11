part of '../../kakao_map_plugin.dart';

abstract class BaseService<T> {
  late Completer<T> _completer;

  Completer<T> get completer => _completer;

  BaseService() {
    _completer = Completer<T>();
  }

  void resetCompleter() {
    if (_completer.isCompleted) {
      _completer = Completer<T>();
    }
  }

  // JSON 문자열을 받아서 T 타입의 객체로 변환하여 completer를 완료합니다.
  void completeFromJson(
    String message,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final resultData = jsonDecode(message);
    _completer.complete(fromJson(resultData));
  }
}
