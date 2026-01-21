part of '../../kakao_map_plugin.dart';

/// 좌표계 변환 결과 정보를 나타내는 클래스입니다.
///
/// 카카오 로컬 API의 좌표계 변환 API 응답 데이터를 담습니다.
/// WGS84, WCONGNAMUL, CONGNAMUL, WTM, TM 등 다양한 좌표계 간 변환 결과를 제공합니다.
///
/// 예시:
/// ```dart
/// // WGS84 좌표계 (위경도)
/// final wgs84 = TransCoord(
///   x: 126.978275,
///   y: 37.566535,
/// );
///
/// // 카카오 좌표계 (Katec)
/// final katec = TransCoord(
///   x: 321286.0,
///   y: 532728.0,
/// );
/// ```
class TransCoord {
  /// X 좌표 값입니다.
  ///
  /// 좌표계에 따라 의미가 다릅니다:
  /// - WGS84: 경도 (Longitude)
  /// - WCONGNAMUL/CONGNAMUL: 카카오 좌표계 X
  /// - WTM/TM: TM 좌표계 X
  ///
  /// 예시:
  /// - WGS84: 126.978275
  /// - Katec: 321286.0
  final double? x;

  /// Y 좌표 값입니다.
  ///
  /// 좌표계에 따라 의미가 다릅니다:
  /// - WGS84: 위도 (Latitude)
  /// - WCONGNAMUL/CONGNAMUL: 카카오 좌표계 Y
  /// - WTM/TM: TM 좌표계 Y
  ///
  /// 예시:
  /// - WGS84: 37.566535
  /// - Katec: 532728.0
  final double? y;

  /// TransCoord 객체를 생성합니다.
  ///
  /// [x]와 [y] 모두 선택사항입니다.
  ///
  /// 예시:
  /// ```dart
  /// final coord = TransCoord(
  ///   x: 126.978275,
  ///   y: 37.566535,
  /// );
  /// ```
  const TransCoord({
    required this.x,
    required this.y,
  });

  /// JSON Map으로부터 TransCoord 객체를 생성합니다.
  ///
  /// 카카오 로컬 API의 응답 데이터를 파싱할 때 사용됩니다.
  ///
  /// 예시:
  /// ```dart
  /// final json = {
  ///   'x': 126.978275,
  ///   'y': 37.566535,
  /// };
  /// final coord = TransCoord.fromJson(json);
  /// ```
  factory TransCoord.fromJson(Map<String, dynamic> json) => TransCoord(
        x: json['x'] as double?,
        y: json['y'] as double?,
      );

  /// TransCoord 객체를 JSON Map으로 변환합니다.
  ///
  /// 반환값은 'x'와 'y' 키를 포함합니다.
  ///
  /// 예시:
  /// ```dart
  /// final coord = TransCoord(x: 126.978275, y: 37.566535);
  /// final json = coord.toJson();
  /// // {"x": 126.978275, "y": 37.566535}
  /// ```
  Map<String, dynamic> toJson() => {
        "x": x,
        "y": y,
      };

  /// TransCoord 객체의 문자열 표현을 반환합니다.
  ///
  /// 디버깅 및 로깅 용도로 사용됩니다.
  @override
  String toString() {
    return 'TransCoord{x: $x, y: $y}';
  }
}
