part of '../../kakao_map_plugin.dart';

/// 좌표계를 변환하는 서비스입니다.
///
/// 카카오 로컬 API의 좌표계 변환 기능을 제공합니다.
/// 다양한 좌표계(WGS84, WCONGNAMUL, CONGNAMUL, WTM, TM) 간의 변환을 지원합니다.
/// 싱글톤 패턴으로 구현되어 있으며, [Completer] 기반의 비동기 처리를 사용합니다.
///
/// 사용 예시:
/// ```dart
/// final response = await controller.transCoord(
///   TransCoordRequest(
///     x: '160710.37729270622',
///     y: '-4388.879299157299',
///     inputCoord: CoordType.WTM, // 입력 좌표계
///     outputCoord: CoordType.WGS84, // 출력 좌표계
///   ),
/// );
/// ```
class TransCoordService extends BaseService<TransCoordResponse> {
  static final TransCoordService _instance = TransCoordService._internal();

  /// [TransCoordService]의 싱글톤 인스턴스를 반환합니다.
  factory TransCoordService() => _instance;

  /// private 생성자로 싱글톤 패턴을 구현합니다.
  TransCoordService._internal() : super();

  /// 네이티브 플랫폼에서 좌표계 변환 결과를 받아 처리하는 콜백입니다.
  ///
  /// [message]는 네이티브 플랫폼에서 전달한 JSON 문자열입니다.
  /// 이 메서드는 네이티브 코드에서 직접 호출됩니다.
  static void transCodeCallback(String message) {
    final resultData = jsonDecode(message);
    _instance.completer.complete(TransCoordResponse.fromJson(resultData));
  }

  /// 좌표계 변환 결과를 비동기로 반환합니다.
  ///
  /// 네이티브 플랫폼에서 변환이 완료되면 [TransCoordResponse]를 반환합니다.
  /// 이 Future는 [transCodeCallback]이 호출될 때 완료됩니다.
  static Future<TransCoordResponse> transCodeResult() =>
      _instance.completer.future;
}
