part of '../../kakao_map_plugin.dart';

class TransCoordResponse {
  List<TransCoord> list = [];

  TransCoordResponse({
    required this.list,
  });

  TransCoordResponse.fromJson(List<dynamic> json) {
    list = json.map((e) => TransCoord.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['list'] = list.map((v) => v.toJson()).toList();
    return data;
  }

  @override
  String toString() {
    return 'TransCoordResponse{list: $list}';
  }
}
