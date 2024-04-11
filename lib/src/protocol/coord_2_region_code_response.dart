part of '../../kakao_map_plugin.dart';

class Coord2RegionCodeResponse {
  List<Coord2RegionCode> list = [];

  Coord2RegionCodeResponse({
    required this.list,
  });

  Coord2RegionCodeResponse.fromJson(List<dynamic> json) {
    list = json.map((e) => Coord2RegionCode.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['list'] = list.map((v) => v.toJson()).toList();
    return data;
  }

  @override
  String toString() {
    return 'Coord2RegionCodeResponse{list: $list}';
  }
}
