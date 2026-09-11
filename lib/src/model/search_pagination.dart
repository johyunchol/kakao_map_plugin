/// 장소·주소 검색 결과의 페이지 정보입니다.
///
/// 카카오 검색은 한 번에 최대 15건(`size`)을 돌려주며, [hasNextPage] 가 true 면
/// 같은 요청에 `page: current + 1` 을 지정해 다음 페이지를 받을 수 있습니다.
///
/// 예시:
/// ```dart
/// var page = 1;
/// final first = await controller.keywordSearch(KeywordSearchRequest(keyword: '카페', page: page));
/// if (first.pagination?.hasNextPage == true) {
///   final next = await controller.keywordSearch(KeywordSearchRequest(keyword: '카페', page: ++page));
/// }
/// ```
class SearchPagination {
  /// 검색된 전체 문서 수입니다. (카카오는 최대 45건까지만 페이지로 제공합니다)
  final int totalCount;

  /// 현재 페이지 번호(1부터)입니다.
  final int current;

  /// 다음 페이지가 있는지 여부입니다.
  final bool hasNextPage;

  /// 이전 페이지가 있는지 여부입니다.
  final bool hasPrevPage;

  /// 페이지 정보를 만듭니다.
  const SearchPagination({
    required this.totalCount,
    required this.current,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  /// JS 에서 전달된 Map 으로부터 만듭니다. 값이 없으면 안전한 기본값을 씁니다.
  factory SearchPagination.fromJson(Map<String, dynamic> json) =>
      SearchPagination(
        totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
        current: (json['current'] as num?)?.toInt() ?? 1,
        hasNextPage: json['hasNextPage'] == true,
        hasPrevPage: json['hasPrevPage'] == true,
      );

  @override
  String toString() =>
      'SearchPagination{totalCount: $totalCount, current: $current, hasNextPage: $hasNextPage, hasPrevPage: $hasPrevPage}';
}

/// 페이지 정보를 가질 수 있는 검색 응답입니다. 라이브러리 내부에서 값을 채웁니다.
mixin SearchPaginationHolder {
  /// 페이지 정보입니다. 페이지 개념이 없는 응답(좌표 변환 등)이나 레거시 경로에서는 null 입니다.
  SearchPagination? pagination;
}
