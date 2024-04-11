part of '../../kakao_map_plugin.dart';

class TransCoordRequest {
  /// 변환할 x 좌표
  final double x;

  /// 변환할 y 좌표
  final double y;

  /// 입력 좌표 체계. 기본값은 WGS84
  final Coords inputCoord;

  /// 출력 좌표 체계. 기본값은 WGS84
  final Coords outputCoord;

  TransCoordRequest({
    required this.x,
    required this.y,
    required this.inputCoord,
    required this.outputCoord,
  });

  factory TransCoordRequest.fromJson(Map<String, dynamic> json) =>
      _$TransCoordRequestFromJson(json);

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
