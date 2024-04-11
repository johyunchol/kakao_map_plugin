part of '../../kakao_map_plugin.dart';

class Coord2RegionCodeRequest {
  /// x 좌표, 경위도인 경우 longitude
  final double x;

  /// y 좌표, 경위도인 경우 latitude
  final double y;

  /// 입력 좌표 체계. 기본값은 WGS84
  final Coords? inputCoord;

  /// 출력 좌표 체계. 기본값은 WGS84
  final Coords? outputCoord;

  Coord2RegionCodeRequest({
    required this.x,
    required this.y,
    this.inputCoord,
    this.outputCoord,
  });

  factory Coord2RegionCodeRequest.fromJson(Map<String, dynamic> json) =>
      _$Coord2RegionCodeRequestFromJson(json);

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
