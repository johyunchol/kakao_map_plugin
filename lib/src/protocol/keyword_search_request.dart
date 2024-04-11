part of '../../kakao_map_plugin.dart';

class KeywordSearchRequest {
  /// 검색할 키워드, 필수
  final String keyword;

  ///  키워드 필터링을 위한 카테고리 코드
  final CategoryType? categoryGroupCode;

  /// x 좌표, longitude, location 값이 있으면 무시된다.
  final double? x;

  /// y 좌표, latitude, location 값이 있으면 무시된다.
  final double? y;

  /// 중심 좌표로부터의 거리(반경) 필터링 값.
  final int? radius;

  /// 사각 영역. 좌x,좌y,우x,우y 형태를 가짐. bounds 값이 있으면 무시된다.
  final String? rect;

  /// 검색할 페이지. 기본값은 1, size 값에 따라 1~45까지 가능
  final int? page;

  /// 한 페이지에 보여질 목록 개수. 기본값은 15, 1~15까지 가능
  final int? size;

  /// 정렬 옵션. DISTANCE 일 경우 지정한 좌표값에 기반하여 동작함. 기본값은 ACCURACY (정확도 순)
  final SortBy? sort;

  /// 지정한 Map 객체의 중심 좌표를 사용할지의 여부. 참일 경우, location 속성은 무시된다. 기본값은 false
  final bool? useMapCenter;

  /// 지정한 Map 객체의 영역을 사용할지의 여부. 참일 경우, bounds 속성은 무시된다. 기본값은 false
  final bool? useMapBounds;

  KeywordSearchRequest({
    required this.keyword,
    this.categoryGroupCode,
    this.x,
    this.y,
    this.radius,
    this.rect,
    this.page,
    this.size,
    this.sort,
    this.useMapCenter,
    this.useMapBounds,
  });

  factory KeywordSearchRequest.fromJson(Map<String, dynamic> json) =>
      _$KeywordSearchRequestFromJson(json);

  Map<String, dynamic> toJson() => _$KeywordSearchRequestToJson(this);

  @override
  String toString() {
    return 'KeywordSearchRequest{keyword: $keyword, category_group_code: $categoryGroupCode, x: $x, y: $y, radius: $radius, rect: $rect, page: $page, size: $size, sort: $sort}';
  }
}

KeywordSearchRequest _$KeywordSearchRequestFromJson(
        Map<String, dynamic> json) =>
    KeywordSearchRequest(
      keyword: json['keyword'] as String,
      categoryGroupCode:
          CategoryType.getByName(json['category_group_code'] as String? ?? ''),
      x: json['x'] as double?,
      y: json['y'] as double?,
      radius: json['radius'] as int?,
      rect: json['rect'] as String?,
      page: json['page'] as int?,
      size: json['size'] as int?,
      sort: SortBy.getByName(json['sort']),
      useMapCenter: json['useMapCenter'] as bool?,
      useMapBounds: json['useMapBounds'] as bool?,
    );

Map<String, dynamic> _$KeywordSearchRequestToJson(
        KeywordSearchRequest instance) =>
    <String, dynamic>{
      'keyword': instance.keyword,
      'categoryGroupCode': instance.categoryGroupCode?.name,
      'x': instance.x,
      'y': instance.y,
      'radius': instance.radius,
      'rect': instance.rect,
      'page': instance.page,
      'size': instance.size,
      'sort': instance.sort?.name,
      'useMapCenter': instance.useMapCenter,
      'useMapBounds': instance.useMapBounds,
    };
