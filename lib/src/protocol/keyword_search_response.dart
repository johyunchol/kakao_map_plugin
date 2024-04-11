part of '../../kakao_map_plugin.dart';

class KeywordSearchResponse {
  List<KeywordAddress> list = [];

  KeywordSearchResponse({
    required this.list,
  });

  KeywordSearchResponse.fromJson(List<dynamic> json) {
    list = json.map((e) => KeywordAddress.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['list'] = list.map((v) => v.toJson()).toList();
    return data;
  }

  @override
  String toString() {
    return 'KeywordSearchResponse{list: $list}';
  }
}
