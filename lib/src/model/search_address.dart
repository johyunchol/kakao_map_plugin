part of '../../kakao_map_plugin.dart';

SearchAddress searchAddressFromJson(String str) =>
    SearchAddress.fromJson(json.decode(str));

String searchAddressToJson(SearchAddress data) => json.encode(data.toJson());

class SearchAddress {
  final String? id;
  final String? addressName;
  final String? addressType;
  final String? x;
  final String? y;
  final RoadAddress? roadAddress;
  final Address? address;

  const SearchAddress({
    required this.id,
    required this.addressName,
    required this.addressType,
    required this.x,
    required this.y,
    required this.roadAddress,
    required this.address,
  });

  factory SearchAddress.fromJson(Map<String, dynamic> json) => SearchAddress(
        id: json['id'],
        addressName: json['address_name'],
        addressType: json['address_type'],
        x: json['x'],
        y: json['y'],
        roadAddress: json['road_address'] == null
            ? null
            : RoadAddress.fromJson(json['road_address']),
        address:
            json['address'] == null ? null : Address.fromJson(json['address']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'address_name': addressName,
        'address_type': addressType,
        'x': x,
        'y': y,
        'road_address': roadAddress?.toJson(),
        'address': address?.toJson(),
      };

  @override
  String toString() {
    return 'SearchAddress{id: $id, addressName: $addressName, addressType: $addressType, x: $x, y: $y, roadAddress: $roadAddress, address: $address}';
  }
}
