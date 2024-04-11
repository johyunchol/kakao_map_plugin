part of '../../../kakao_map_plugin.dart';

enum AnalyzeType {
  /// 건물명이 일부 매칭될 경우에도 검색 결과를 사용
  similar('SIMILAR'),

  /// 정확한 주소 패턴일 경우에만 검색 결과를 사용
  exact('EXACT'),
  ;

  const AnalyzeType(this.name);

  final String name;

  factory AnalyzeType.getByName(String styleName) {
    return AnalyzeType.values.firstWhere((value) => value.name == styleName,
        orElse: () => AnalyzeType.similar);
  }
}
