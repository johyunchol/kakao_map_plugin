part of '../../../kakao_map_plugin.dart';

enum SortBy {
  accuracy('accuracy'),
  distance('distance');

  const SortBy(this.name);

  final String name;

  factory SortBy.getByName(String styleName) {
    return SortBy.values.firstWhere((value) => value.name == styleName,
        orElse: () => SortBy.accuracy);
  }
}
