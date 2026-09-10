/// 카카오 지도 JavaScript SDK 와 함께 불러올 확장 라이브러리를 나타냅니다.
///
/// SDK 는 `libraries` 파라미터에 나열된 확장만 내려받습니다. 사용하지 않는 확장을
/// 제외하면 지도 생성 시 다운로드/파싱 비용을 줄일 수 있습니다.
/// (참고: `drawing` 번들은 압축 전 약 99KB 로 지도 본체와 맞먹습니다.)
///
/// 기본값은 **모든 라이브러리를 포함**하므로, 별도로 지정하지 않으면 기존과 동일하게
/// 동작합니다.
///
/// 예시:
/// ```dart
/// // 앱 전역 기본값: 검색만 사용
/// AuthRepository.initialize(
///   appKey: 'your_key',
///   libraries: {KakaoMapLibrary.services},
/// );
///
/// // 특정 화면에서만 클러스터러 추가
/// KakaoMap(
///   libraries: {KakaoMapLibrary.services, KakaoMapLibrary.clusterer},
///   clusterer: myClusterer,
/// )
/// ```
enum KakaoMapLibrary {
  /// 장소 검색, 주소 변환 등 로컬 API 를 제공합니다.
  ///
  /// [KakaoMapController]의 `keywordSearch`, `categorySearch`, `addressSearch`,
  /// `coord2Address`, `coord2RegionCode`, `transCoord` 사용 시 필요합니다.
  services('services'),

  /// 마커 클러스터러를 제공합니다.
  ///
  /// [Clusterer]를 사용할 때 필요합니다. `KakaoMap(clusterer: ...)`를 지정하면
  /// 목록에 없어도 자동으로 포함됩니다.
  clusterer('clusterer'),

  /// 도형 그리기 도구를 제공합니다.
  drawing('drawing');

  /// SDK URL 의 `libraries` 파라미터에 사용되는 이름입니다.
  final String value;

  const KakaoMapLibrary(this.value);

  /// 모든 라이브러리를 포함하는 기본 집합입니다.
  static const Set<KakaoMapLibrary> all = {
    KakaoMapLibrary.services,
    KakaoMapLibrary.clusterer,
    KakaoMapLibrary.drawing,
  };

  /// [libraries]를 SDK URL 의 `libraries` 파라미터 문자열로 변환합니다.
  ///
  /// 열거형 선언 순서(services, clusterer, drawing)로 정렬해 동일한 집합이 항상
  /// 같은 URL 을 만들도록 보장합니다. 비어 있으면 빈 문자열을 반환합니다.
  static String toQueryValue(Set<KakaoMapLibrary> libraries) {
    final ordered = KakaoMapLibrary.values
        .where(libraries.contains)
        .map((e) => e.value)
        .toList(growable: false);
    return ordered.join(',');
  }
}
