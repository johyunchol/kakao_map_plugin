part of '../../kakao_map_plugin.dart';

class Address {
  final String addressName;
  final String region1DepthName;
  final String region2DepthName;
  final String region3DepthName;
  final String mountainYn;
  final String mainAddressNo;
  final String subAddressNo;
  final String? zipCode;

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

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        addressName: json['address_name'],
        region1DepthName: json['region_1depth_name'],
        region2DepthName: json['region_2depth_name'],
        region3DepthName: json['region_3depth_name'],
        mountainYn: json['mountain_yn'],
        mainAddressNo: json['main_address_no'],
        subAddressNo: json['sub_address_no'],
        zipCode: json['zip_code'],
      );

  Map<String, dynamic> toJson() => {
        'address_name': addressName,
        'region_1depth_name': region1DepthName,
        'region_2depth_name': region2DepthName,
        'region_3depth_name': region3DepthName,
        'mountain_yn': mountainYn,
        'main_address_no': mainAddressNo,
        'sub_address_no': subAddressNo,
        'zip_code': zipCode,
      };

  @override
  String toString() {
    return 'Address{addressName: $addressName, region1DepthName: $region1DepthName, region2DepthName: $region2DepthName, region3DepthName: $region3DepthName, mountainYn: $mountainYn, mainAddressNo: $mainAddressNo, subAddressNo: $subAddressNo, zipCode: $zipCode}';
  }
}
