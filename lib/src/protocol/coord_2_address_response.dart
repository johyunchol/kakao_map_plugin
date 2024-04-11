part of '../../kakao_map_plugin.dart';

class Coord2AddressResponse {
  List<Coord2Address> list = [];

  Coord2AddressResponse({
    required this.list,
  });

  Coord2AddressResponse.fromJson(List<dynamic> json) {
    list = json.map((e) => Coord2Address.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['list'] = list.map((v) => v.toJson()).toList();
    return data;
  }

  @override
  String toString() {
    return 'Coord2AddressResponse{list: $list}';
  }
}
