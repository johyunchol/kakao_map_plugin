part of '../../kakao_map_plugin.dart';

class Coord2Address {
  final RoadAddress? roadAddress;
  final Address? address;

  const Coord2Address({
    required this.roadAddress,
    required this.address,
  });

  factory Coord2Address.fromJson(Map<String, dynamic> json) => Coord2Address(
        roadAddress: json['road_address'] == null
            ? null
            : RoadAddress.fromJson(json['road_address']),
        address:
            json['address'] == null ? null : Address.fromJson(json['address']),
      );

  Map<String, dynamic> toJson() => {
        'road_address': roadAddress?.toJson(),
        'address': address?.toJson(),
      };

  @override
  String toString() {
    return 'Coord2Address{roadAddress: $roadAddress, address: $address}';
  }
}

Coord2Address coord2AddressFromJson(String str) =>
    Coord2Address.fromJson(json.decode(str));

String coord2AddressToJson(Coord2Address data) => json.encode(data.toJson());
