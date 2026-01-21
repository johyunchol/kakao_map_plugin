import 'dart:convert';

import 'package:kakao_map_plugin/src/protocol/coord_2_region_code_response.dart';
import 'package:kakao_map_plugin/src/service/base_service.dart';

/// 좌표를 행정구역 정보로 변환하는 서비스입니다.
///
/// 카카오 로컬 API의 좌표-행정구역 변환 기능을 제공합니다.
/// WGS84 좌표계의 경위도 좌표를 입력하면 해당 위치의 행정구역 정보를 반환합니다.
/// 시/도, 시/군/구, 읍/면/동 등의 행정구역 코드와 명칭을 제공합니다.
/// 싱글톤 패턴으로 구현되어 있으며, [Completer] 기반의 비동기 처리를 사용합니다.
///
/// 사용 예시:
/// ```dart
/// final response = await controller.coord2RegionCode(
///   Coord2RegionCodeRequest(
///     x: '127.06283102249932',
///     y: '37.514322572335935',
///   ),
/// );
/// ```
class Coord2RegionCodeService extends BaseService<Coord2RegionCodeResponse> {
  static final Coord2RegionCodeService _instance =
      Coord2RegionCodeService._internal();

  /// [Coord2RegionCodeService]의 싱글톤 인스턴스를 반환합니다.
  factory Coord2RegionCodeService() => _instance;

  /// private 생성자로 싱글톤 패턴을 구현합니다.
  Coord2RegionCodeService._internal() : super();

  /// 네이티브 플랫폼에서 좌표-행정구역 변환 결과를 받아 처리하는 콜백입니다.
  ///
  /// [message]는 네이티브 플랫폼에서 전달한 JSON 문자열입니다.
  /// 이 메서드는 네이티브 코드에서 직접 호출됩니다.
  static void coord2RegionCodeCallback(String message) {
    final resultData = jsonDecode(message);
    _instance.completer.complete(Coord2RegionCodeResponse.fromJson(resultData));
  }

  /// 좌표-행정구역 변환 결과를 비동기로 반환합니다.
  ///
  /// 네이티브 플랫폼에서 변환이 완료되면 [Coord2RegionCodeResponse]를 반환합니다.
  /// 이 Future는 [coord2RegionCodeCallback]이 호출될 때 완료됩니다.
  static Future<Coord2RegionCodeResponse> coord2RegionCodeResult() =>
      _instance.completer.future;
}
