part of '../../kakao_map_plugin.dart';

class Coord2AddressRequest {
  /// x 좌표, 경위도인 경우 longitude
  final double x;

  /// y 좌표, 경위도인 경우 latitude
  final double y;

  /// 입력 좌표 체계. 기본값은 WGS84
  final Coords? inputCoord;

  Coord2AddressRequest({
    required this.x,
    required this.y,
    this.inputCoord,
  });

  factory Coord2AddressRequest.fromJson(Map<String, dynamic> json) =>
      _$Coord2AddressRequestFromJson(json);

  Map<String, dynamic> toJson() => _$Coord2AddressRequestToJson(this);

  @override
  String toString() {
    return 'Coord2AddressRequest{x: $x, y: $y, inputCoord: $inputCoord}';
  }
}

Coord2AddressRequest _$Coord2AddressRequestFromJson(
        Map<String, dynamic> json) =>
    Coord2AddressRequest(
      x: json['x'] as double,
      y: json['y'] as double,
      inputCoord: Coords.getByName(json['input_coord'] as String? ?? ''),
    );

Map<String, dynamic> _$Coord2AddressRequestToJson(
        Coord2AddressRequest instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'input_coord': instance.inputCoord?.name,
    };
