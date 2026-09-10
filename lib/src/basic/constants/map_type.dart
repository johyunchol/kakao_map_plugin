/// 지도 타입을 나타내는 열거형입니다.
///
/// 카카오 지도 API에서 지원하는 다양한 지도 타입을 정의합니다.
enum MapType {
  /// 일반 지도 (기본값)
  normal(1),

  /// 로드맵 (일반 지도와 동일)
  @Deprecated('MapType.normal 과 동일한 값입니다. normal 을 사용하세요.')
  roadMap(1),

  /// 스카이뷰 (위성 지도)
  skyView(2),

  /// 하이브리드 (위성 지도 + 라벨)
  hybrid(3),

  /// 오버레이 (추가 정보 레이어)
  overlay(4),

  /// 로드뷰 (거리뷰)
  roadView(5),

  /// 교통정보 표시
  traffic(6),

  /// 지형도 표시
  terrain(7),

  /// 자전거 도로 표시
  bicycle(8),

  /// 자전거 하이브리드 (자전거 + 위성)
  bicycleHybrid(9),

  /// 지적편집도 표시
  useDistrict(10);

  const MapType(this.id);

  /// 지도 타입의 고유 ID
  final int id;

  /// ID로 지도 타입을 찾습니다.
  ///
  /// [mapTypeId] 찾을 지도 타입의 ID
  /// 해당하는 ID가 없으면 [MapType.normal]을 반환합니다.
  ///
  /// 주의: id 1 은 [MapType.normal] 과 [MapType.roadMap] 이 공유하므로,
  /// id 1 은 항상 [MapType.normal] 로 정규화되어 반환됩니다.
  factory MapType.getById(int mapTypeId) {
    return MapType.values.firstWhere((value) => value.id == mapTypeId,
        orElse: () => MapType.normal);
  }
}
