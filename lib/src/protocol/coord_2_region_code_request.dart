import '../basic/constants/coords.dart';

/// 좌표를 행정구역 코드로 변환하는 요청 클래스입니다.
///
/// 카카오 로컬 API의 좌표 → 행정구역 정보 변환을 위한 요청 파라미터를 정의합니다.
/// 지정한 좌표의 행정구역 코드와 지역 정보를 얻을 수 있습니다.
///
/// 예시:
/// ```dart
/// final request = Coord2RegionCodeRequest(
///   x: 127.1086228,
///   y: 37.4012191,
///   inputCoord: Coords.WGS84,
///   outputCoord: Coords.WGS84,
/// );
/// ```
class Coord2RegionCodeRequest {
  /// X 좌표입니다. (필수)
  ///
  /// 경위도(WGS84) 좌표계인 경우 경도(longitude)를 의미합니다.
  /// - WGS84: 경도 값
  /// - WCONGNAMUL: X 좌표 값
  /// - CONGNAMUL: X 좌표 값
  /// - WTM: X 좌표 값
  /// - TM: X 좌표 값
  final double x;

  /// Y 좌표입니다. (필수)
  ///
  /// 경위도(WGS84) 좌표계인 경우 위도(latitude)를 의미합니다.
  /// - WGS84: 위도 값
  /// - WCONGNAMUL: Y 좌표 값
  /// - CONGNAMUL: Y 좌표 값
  /// - WTM: Y 좌표 값
  /// - TM: Y 좌표 값
  final double y;

  /// 입력 좌표 체계입니다. (선택)
  ///
  /// 기본값은 WGS84이며, 다음 좌표계를 지원합니다:
  /// - WGS84: 위경도 좌표계 (기본값)
  /// - WCONGNAMUL: 공공데이터포털에서 사용하는 좌표계
  /// - CONGNAMUL: 국가에서 사용하는 좌표계
  /// - WTM: 평면직각좌표계
  /// - TM: 평면직각좌표계
  final Coords? inputCoord;

  /// 출력 좌표 체계입니다. (선택)
  ///
  /// 기본값은 WGS84이며, 응답에 포함될 좌표의 좌표계를 지정합니다.
  /// - WGS84: 위경도 좌표계 (기본값)
  /// - WCONGNAMUL: 공공데이터포털에서 사용하는 좌표계
  /// - CONGNAMUL: 국가에서 사용하는 좌표계
  /// - WTM: 평면직각좌표계
  /// - TM: 평면직각좌표계
  final Coords? outputCoord;

  /// Coord2RegionCodeRequest 생성자입니다.
  ///
  /// [x]와 [y]는 필수 파라미터이며, [inputCoord]와 [outputCoord]는 선택 파라미터입니다.
  Coord2RegionCodeRequest({
    required this.x,
    required this.y,
    this.inputCoord,
    this.outputCoord,
  });

  /// JSON 객체로부터 Coord2RegionCodeRequest 인스턴스를 생성합니다.
  factory Coord2RegionCodeRequest.fromJson(Map<String, dynamic> json) =>
      _$Coord2RegionCodeRequestFromJson(json);

  /// Coord2RegionCodeRequest 인스턴스를 JSON 객체로 변환합니다.
  Map<String, dynamic> toJson() => _$Coord2RegionCodeRequestToJson(this);

  @override
  String toString() {
    return 'Coord2RegionCodeRequest{x: $x, y: $y, inputCoord: $inputCoord, outputCoord: $outputCoord}';
  }
}

Coord2RegionCodeRequest _$Coord2RegionCodeRequestFromJson(
        Map<String, dynamic> json) =>
    Coord2RegionCodeRequest(
      x: json['x'] as double,
      y: json['y'] as double,
      inputCoord: Coords.getByName(json['input_coord'] as String? ?? ''),
      outputCoord: Coords.getByName(json['output_coord'] as String? ?? ''),
    );

Map<String, dynamic> _$Coord2RegionCodeRequestToJson(
        Coord2RegionCodeRequest instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'input_coord': instance.inputCoord?.name,
      'output_coord': instance.outputCoord?.name,
    };
