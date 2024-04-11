part of '../../kakao_map_plugin.dart';

class TransCoordService extends BaseService<TransCoordResponse> {
  static final TransCoordService _instance = TransCoordService._internal();

  factory TransCoordService() => _instance;

  TransCoordService._internal() : super();

  static void transCodeCallback(String message) {
    final resultData = jsonDecode(message);
    _instance.completer.complete(TransCoordResponse.fromJson(resultData));
  }

  static Future<TransCoordResponse> transCodeResult() =>
      _instance.completer.future;
}
