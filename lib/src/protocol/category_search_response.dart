part of '../../kakao_map_plugin.dart';

class CategorySearchResponse {
  List<KeywordAddress> list = [];

  CategorySearchResponse({
    required this.list,
  });

  CategorySearchResponse.fromJson(List<dynamic> json) {
    list = json.map((e) => KeywordAddress.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['list'] = list.map((v) => v.toJson()).toList();
    return data;
  }

  @override
  String toString() {
    return 'CategorySearchResponse{list: $list}';
  }
}
