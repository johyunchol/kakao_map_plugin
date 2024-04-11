part of '../../kakao_map_plugin.dart';

class RoadAddress {
  final String addressName;
  final String region1DepthName;
  final String region2DepthName;
  final String region3DepthName;
  final String roadName;
  final String undergroundYn;
  final String mainBuildingNo;
  final String subBuildingNo;
  final String buildingName;
  final String zoneNo;

  RoadAddress({
    required this.addressName,
    required this.region1DepthName,
    required this.region2DepthName,
    required this.region3DepthName,
    required this.roadName,
    required this.undergroundYn,
    required this.mainBuildingNo,
    required this.subBuildingNo,
    required this.buildingName,
    required this.zoneNo,
  });

  factory RoadAddress.fromJson(Map<String, dynamic> json) => RoadAddress(
        addressName: json['address_name'],
        region1DepthName: json['region_1depth_name'],
        region2DepthName: json['region_2depth_name'],
        region3DepthName: json['region_3depth_name'],
        roadName: json['road_name'],
        undergroundYn: json['underground_yn'],
        mainBuildingNo: json['main_building_no'],
        subBuildingNo: json['sub_building_no'],
        buildingName: json['building_name'],
        zoneNo: json['zone_no'],
      );

  Map<String, dynamic> toJson() => {
        'address_name': addressName,
        'region_1depth_name': region1DepthName,
        'region_2depth_name': region2DepthName,
        'region_3depth_name': region3DepthName,
        'road_name': roadName,
        'underground_yn': undergroundYn,
        'main_building_no': mainBuildingNo,
        'sub_building_no': subBuildingNo,
        'building_name': buildingName,
        'zone_no': zoneNo,
      };
  @override
  String toString() {
    return 'RoadAddress{addressName: $addressName, region1DepthName: $region1DepthName, region2DepthName: $region2DepthName, region3DepthName: $region3DepthName, roadName: $roadName, undergroundYn: $undergroundYn, mainBuildingNo: $mainBuildingNo, subBuildingNo: $subBuildingNo, buildingName: $buildingName, zoneNo: $zoneNo}';
  }
}
