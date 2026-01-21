part of '../../../kakao_map_plugin.dart';

/// 좌표계 타입을 나타내는 열거형입니다.
///
/// 카카오 지도 API에서 지원하는 다양한 좌표계를 정의합니다.
enum Coords {
  /// WGS84 좌표계 (GPS 좌표계)
  ///
  /// 세계 측지 좌표계로, GPS에서 사용하는 국제 표준 좌표계입니다.
  wgs84('WGS84'),

  /// Wcongnamul 좌표계
  ///
  /// 카카오에서 사용하는 웹 메르카토르 투영법 기반 좌표계입니다.
  wcongnamul('WCONGNAMUL'),

  /// Congnamul 좌표계
  ///
  /// 카카오 로컬 API에서 사용하는 좌표계입니다.
  congnamul('CONGNAMUL'),

  /// WTM 좌표계 (Web Transverse Mercator)
  ///
  /// 웹 환경에서 사용하는 횡단 메르카토르 투영법 기반 좌표계입니다.
  wtm('WTM'),

  /// TM 좌표계 (Transverse Mercator)
  ///
  /// 횡단 메르카토르 투영법 기반 좌표계입니다.
  tm('TM');

  const Coords(this.name);

  /// 좌표계 이름
  final String name;

  /// 이름으로 좌표계를 찾습니다.
  ///
  /// [styleName] 찾을 좌표계의 이름
  /// 해당하는 이름이 없으면 [Coords.wgs84]를 반환합니다.
  factory Coords.getByName(String styleName) {
    return Coords.values.firstWhere((value) => value.name == styleName,
        orElse: () => Coords.wgs84);
  }
}
