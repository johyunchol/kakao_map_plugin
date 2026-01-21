import '../basic/constants/coords.dart';

/// 좌표계 변환 요청 클래스입니다.
///
/// 카카오 로컬 API의 좌표계 변환을 위한 요청 파라미터를 정의합니다.
/// 서로 다른 좌표계 간의 좌표 변환이 가능합니다.
///
/// 예시:
/// ```dart
/// final request = TransCoordRequest(
///   x: 160710.37729270255,
///   y: -4388.879299157299,
///   inputCoord: Coords.WTM,
///   outputCoord: Coords.WGS84,
/// );
/// ```
class TransCoordRequest {
  /// 변환할 X 좌표입니다. (필수)
  ///
  /// 입력 좌표계에 따라 의미가 달라집니다:
  /// - WGS84: 경도(longitude)
  /// - WCONGNAMUL, CONGNAMUL, WTM, TM: X 좌표 값
  final double x;

  /// 변환할 Y 좌표입니다. (필수)
  ///
  /// 입력 좌표계에 따라 의미가 달라집니다:
  /// - WGS84: 위도(latitude)
  /// - WCONGNAMUL, CONGNAMUL, WTM, TM: Y 좌표 값
  final double y;

  /// 입력 좌표 체계입니다. (필수)
  ///
  /// 변환하려는 원본 좌표의 좌표계를 지정합니다:
  /// - WGS84: 위경도 좌표계
  /// - WCONGNAMUL: 공공데이터포털에서 사용하는 좌표계
  /// - CONGNAMUL: 국가에서 사용하는 좌표계
  /// - WTM: 평면직각좌표계
  /// - TM: 평면직각좌표계
  final Coords inputCoord;

  /// 출력 좌표 체계입니다. (필수)
  ///
  /// 변환할 대상 좌표계를 지정합니다:
  /// - WGS84: 위경도 좌표계
  /// - WCONGNAMUL: 공공데이터포털에서 사용하는 좌표계
  /// - CONGNAMUL: 국가에서 사용하는 좌표계
  /// - WTM: 평면직각좌표계
  /// - TM: 평면직각좌표계
  final Coords outputCoord;

  /// TransCoordRequest 생성자입니다.
  ///
  /// 모든 파라미터가 필수입니다.
  /// [x]와 [y]는 변환할 좌표, [inputCoord]는 입력 좌표계,
  /// [outputCoord]는 출력 좌표계를 지정합니다.
  TransCoordRequest({
    required this.x,
    required this.y,
    required this.inputCoord,
    required this.outputCoord,
  });

  /// JSON 객체로부터 TransCoordRequest 인스턴스를 생성합니다.
  factory TransCoordRequest.fromJson(Map<String, dynamic> json) =>
      _$TransCoordRequestFromJson(json);

  /// TransCoordRequest 인스턴스를 JSON 객체로 변환합니다.
  Map<String, dynamic> toJson() => _$TransCoordRequestToJson(this);

  @override
  String toString() {
    return 'TransCoordRequest{x: $x, y: $y, inputCoord: $inputCoord, outputCoord: $outputCoord}';
  }
}

TransCoordRequest _$TransCoordRequestFromJson(Map<String, dynamic> json) =>
    TransCoordRequest(
      x: json['x'] as double,
      y: json['y'] as double,
      inputCoord: Coords.getByName(json['input_coord'] as String),
      outputCoord: Coords.getByName(json['output_coord'] as String),
    );

Map<String, dynamic> _$TransCoordRequestToJson(TransCoordRequest instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'input_coord': instance.inputCoord.name,
      'output_coord': instance.outputCoord.name,
    };
