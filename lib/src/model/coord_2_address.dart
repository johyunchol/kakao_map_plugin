part of kakao_map_plugin;

Coord2Address coord2AddressFromJson(String str) =>
    Coord2Address.fromJson(json.decode(str));

String coord2AddressToJson(Coord2Address data) => json.encode(data.toJson());

class Coord2Address {
  final RoadAddress? roadAddress;
  final Address? address;

  const Coord2Address({
    required this.roadAddress,
    required this.address,
  });

  Coord2Address copyWith({
    RoadAddress? roadAddress,
    Address? address,
  }) =>
      Coord2Address(
        roadAddress: roadAddress ?? this.roadAddress,
        address: address ?? this.address,
      );

  factory Coord2Address.fromJson(Map<String, dynamic> json) => Coord2Address(
        roadAddress: json["road_address"] == null
            ? null
            : RoadAddress.fromJson(json["road_address"]),
        address: json["address"] == null
            ? null
            : Address.fromJson(json["address"]),
      );

  Map<String, dynamic> toJson() => {
        "road_address": roadAddress == null ? 'null' : roadAddress?.toJson(),
        "address": address == null ? 'null' : address?.toJson(),
      };
  @override
  String toString() {
    return 'Coord2Address{roadAddress: $roadAddress, address: $address}';
  }
}

class Address {
  final String addressName;
  final String region1DepthName;
  final String region2DepthName;
  final String region3DepthName;
  final String mountainYn;
  final String mainAddressNo;
  final String subAddressNo;
  final String zipCode;

  Address({
    required this.addressName,
    required this.region1DepthName,
    required this.region2DepthName,
    required this.region3DepthName,
    required this.mountainYn,
    required this.mainAddressNo,
    required this.subAddressNo,
    required this.zipCode,
  });

  Address copyWith({
    String? addressName,
    String? region1DepthName,
    String? region2DepthName,
    String? region3DepthName,
    String? mountainYn,
    String? mainAddressNo,
    String? subAddressNo,
    String? zipCode,
  }) =>
      Address(
        addressName: addressName ?? this.addressName,
        region1DepthName: region1DepthName ?? this.region1DepthName,
        region2DepthName: region2DepthName ?? this.region2DepthName,
        region3DepthName: region3DepthName ?? this.region3DepthName,
        mountainYn: mountainYn ?? this.mountainYn,
        mainAddressNo: mainAddressNo ?? this.mainAddressNo,
        subAddressNo: subAddressNo ?? this.subAddressNo,
        zipCode: zipCode ?? this.zipCode,
      );

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        addressName: json["address_name"],
        region1DepthName: json["region_1depth_name"],
        region2DepthName: json["region_2depth_name"],
        region3DepthName: json["region_3depth_name"],
        mountainYn: json["mountain_yn"],
        mainAddressNo: json["main_address_no"],
        subAddressNo: json["sub_address_no"],
        zipCode: json["zip_code"],
      );

  Map<String, dynamic> toJson() => {
        "address_name": addressName,
        "region_1depth_name": region1DepthName,
        "region_2depth_name": region2DepthName,
        "region_3depth_name": region3DepthName,
        "mountain_yn": mountainYn,
        "main_address_no": mainAddressNo,
        "sub_address_no": subAddressNo,
        "zip_code": zipCode,
      };
  @override
  String toString() {
    return 'Address{addressName: $addressName, region1DepthName: $region1DepthName, region2DepthName: $region2DepthName, region3DepthName: $region3DepthName, mountainYn: $mountainYn, mainAddressNo: $mainAddressNo, subAddressNo: $subAddressNo, zipCode: $zipCode}';
  }
}

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

  RoadAddress copyWith({
    String? addressName,
    String? region1DepthName,
    String? region2DepthName,
    String? region3DepthName,
    String? roadName,
    String? undergroundYn,
    String? mainBuildingNo,
    String? subBuildingNo,
    String? buildingName,
    String? zoneNo,
  }) =>
      RoadAddress(
        addressName: addressName ?? this.addressName,
        region1DepthName: region1DepthName ?? this.region1DepthName,
        region2DepthName: region2DepthName ?? this.region2DepthName,
        region3DepthName: region3DepthName ?? this.region3DepthName,
        roadName: roadName ?? this.roadName,
        undergroundYn: undergroundYn ?? this.undergroundYn,
        mainBuildingNo: mainBuildingNo ?? this.mainBuildingNo,
        subBuildingNo: subBuildingNo ?? this.subBuildingNo,
        buildingName: buildingName ?? this.buildingName,
        zoneNo: zoneNo ?? this.zoneNo,
      );

  factory RoadAddress.fromJson(Map<String, dynamic> json) => RoadAddress(
        addressName: json["address_name"],
        region1DepthName: json["region_1depth_name"],
        region2DepthName: json["region_2depth_name"],
        region3DepthName: json["region_3depth_name"],
        roadName: json["road_name"],
        undergroundYn: json["underground_yn"],
        mainBuildingNo: json["main_building_no"],
        subBuildingNo: json["sub_building_no"],
        buildingName: json["building_name"],
        zoneNo: json["zone_no"],
      );

  Map<String, dynamic> toJson() => {
        "address_name": addressName,
        "region_1depth_name": region1DepthName,
        "region_2depth_name": region2DepthName,
        "region_3depth_name": region3DepthName,
        "road_name": roadName,
        "underground_yn": undergroundYn,
        "main_building_no": mainBuildingNo,
        "sub_building_no": subBuildingNo,
        "building_name": buildingName,
        "zone_no": zoneNo,
      };
  @override
  String toString() {
    return 'RoadAddress{addressName: $addressName, region1DepthName: $region1DepthName, region2DepthName: $region2DepthName, region3DepthName: $region3DepthName, roadName: $roadName, undergroundYn: $undergroundYn, mainBuildingNo: $mainBuildingNo, subBuildingNo: $subBuildingNo, buildingName: $buildingName, zoneNo: $zoneNo}';
  }
}

class Coord2AddressService {
  late Completer<Coord2Address> completer;
  static final Coord2AddressService _instance =
      Coord2AddressService._internal();
  Completer<Coord2Address> getCompleter() {
    return completer;
  }

  factory Coord2AddressService() {
    return _instance;
  }

  Coord2AddressService._internal() {
    completer = Completer<Coord2Address>();
  }

  void resetCompleter() {
    completer = Completer<Coord2Address>();
  }
}
