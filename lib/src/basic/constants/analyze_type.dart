part of '../../../kakao_map_plugin.dart';

/// 주소 검색 분석 타입을 나타내는 열거형입니다.
///
/// 주소 검색 시 매칭 정확도를 정의합니다.
enum AnalyzeType {
  /// 유사 매칭 모드
  ///
  /// 건물명이 일부 매칭될 경우에도 검색 결과에 포함합니다.
  similar('SIMILAR'),

  /// 정확 매칭 모드
  ///
  /// 정확한 주소 패턴일 경우에만 검색 결과에 포함합니다.
  exact('EXACT');

  const AnalyzeType(this.name);

  /// 분석 타입 이름
  final String name;

  /// 이름으로 분석 타입을 찾습니다.
  ///
  /// [styleName] 찾을 분석 타입의 이름
  /// 해당하는 이름이 없으면 [AnalyzeType.similar]를 반환합니다.
  factory AnalyzeType.getByName(String styleName) {
    return AnalyzeType.values.firstWhere((value) => value.name == styleName,
        orElse: () => AnalyzeType.similar);
  }
}
