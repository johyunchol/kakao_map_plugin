/// 검색 결과 정렬 기준을 나타내는 열거형입니다.
///
/// 장소 검색 시 결과를 정렬하는 기준을 정의합니다.
enum SortBy {
  /// 정확도순 정렬 (기본값)
  ///
  /// 검색어와의 관련성이 높은 순서로 정렬합니다.
  accuracy('accuracy'),

  /// 거리순 정렬
  ///
  /// 기준 위치로부터 가까운 순서로 정렬합니다.
  distance('distance');

  const SortBy(this.name);

  /// 정렬 기준 이름
  final String name;

  /// 이름으로 정렬 기준을 찾습니다.
  ///
  /// [styleName] 찾을 정렬 기준의 이름
  /// 해당하는 이름이 없으면 [SortBy.accuracy]를 반환합니다.
  factory SortBy.getByName(String styleName) {
    return SortBy.values.firstWhere((value) => value.name == styleName,
        orElse: () => SortBy.accuracy);
  }
}
