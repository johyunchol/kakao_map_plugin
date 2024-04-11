part of '../../kakao_map_plugin.dart';

class AddressSearchResponse {
  List<SearchAddress> list = [];

  AddressSearchResponse({
    required this.list,
  });

  AddressSearchResponse.fromJson(List<dynamic> json) {
    list = json.map((e) => SearchAddress.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['list'] = list.map((v) => v.toJson()).toList();
    return data;
  }

  @override
  String toString() {
    return 'AddressSearchResponse{list: $list}';
  }
}
