part of '../../kakao_map_plugin.dart';

class Coord2RegionCode {
  final String? regionType;
  final String? addressName;
  final String? region1DepthName;
  final String? region2DepthName;
  final String? region3DepthName;
  final String? region4DepthName;
  final String? code;
  final double? x;
  final double? y;

  const Coord2RegionCode({
    required this.regionType,
    required this.addressName,
    required this.region1DepthName,
    required this.region2DepthName,
    required this.region3DepthName,
    required this.region4DepthName,
    required this.code,
    required this.x,
    required this.y,
  });

  factory Coord2RegionCode.fromJson(Map<String, dynamic> json) =>
      Coord2RegionCode(
        regionType: json['region_type'] as String?,
        addressName: json['address_name'] as String?,
        region1DepthName: json['region_1depth_name'] as String?,
        region2DepthName: json['region_2depth_name'] as String?,
        region3DepthName: json['region_3depth_name'] as String?,
        region4DepthName: json['region_4depth_name'] as String?,
        code: json['code'] as String?,
        x: json['x'] as double?,
        y: json['y'] as double?,
      );

  Map<String, dynamic> toJson() => {
        'region_type': regionType,
        'address_name': addressName,
        'region_1depth_name': region1DepthName,
        'region_2depth_name': region2DepthName,
        'region_3depth_name': region3DepthName,
        'region_4depth_name': region4DepthName,
        'code': code,
        'x': x,
        'y': y,
      };

  @override
  String toString() {
    return 'Coord2RegionCode{regionType: $regionType, addressName: $addressName, region1DepthName: $region1DepthName, region2DepthName: $region2DepthName, region3DepthName: $region3DepthName, region4DepthName: $region4DepthName, code: $code, x: $x, y: $y}';
  }
}
