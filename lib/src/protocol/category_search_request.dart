import '../basic/constants/category_type.dart';
import '../basic/constants/sort_by.dart';

/// 카테고리 검색 요청 클래스입니다.
///
/// 카카오 로컬 API의 카테고리 검색을 위한 요청 파라미터를 정의합니다.
/// 특정 카테고리에 속하는 장소들을 검색할 수 있습니다.
///
/// 예시:
/// ```dart
/// final request = CategorySearchRequest(
///   categoryGroupCode: CategoryType.MT1, // 대형마트
///   x: 127.06283102249932,
///   y: 37.514322572335935,
///   radius: 5000,
/// );
/// ```
class CategorySearchRequest {
  /// 검색할 카테고리 그룹 코드입니다. (필수)
  ///
  /// 다음 카테고리 중 하나를 선택해야 합니다:
  /// - MT1: 대형마트
  /// - CS2: 편의점
  /// - PS3: 어린이집, 유치원
  /// - SC4: 학교
  /// - AC5: 학원
  /// - PK6: 주차장
  /// - OL7: 주유소, 충전소
  /// - SW8: 지하철역
  /// - BK9: 은행
  /// - CT1: 문화시설
  /// - AG2: 중개업소
  /// - PO3: 공공기관
  /// - AT4: 관광명소
  /// - AD5: 숙박
  /// - FD6: 음식점
  /// - CE7: 카페
  /// - HP8: 병원
  /// - PM9: 약국
  final CategoryType categoryGroupCode;

  /// 중심 좌표의 X값(경도, longitude)입니다. (선택)
  ///
  /// 특정 지역을 중심으로 검색하려는 경우 위치 좌표와 함께 사용합니다.
  /// y 파라미터와 함께 사용되어야 합니다.
  final double? x;

  /// 중심 좌표의 Y값(위도, latitude)입니다. (선택)
  ///
  /// 특정 지역을 중심으로 검색하려는 경우 위치 좌표와 함께 사용합니다.
  /// x 파라미터와 함께 사용되어야 합니다.
  final double? y;

  /// 중심 좌표로부터의 거리(반경) 필터링 값입니다. (선택)
  ///
  /// 단위는 미터(m)이며, 0~20000 사이의 값을 사용할 수 있습니다.
  /// x, y 파라미터와 함께 사용하여 원형 영역 검색이 가능합니다.
  final int? radius;

  /// 사각형 영역을 나타냅니다. (선택)
  ///
  /// 좌측 하단 좌표와 우측 상단 좌표를 사용하여 사각형 영역을 지정합니다.
  /// 형식: "좌측하단X,좌측하단Y,우측상단X,우측상단Y"
  /// 예: "127.0,37.0,128.0,38.0"
  final String? rect;

  /// 검색할 페이지 번호입니다. (선택)
  ///
  /// 기본값은 1이며, 검색 결과가 많을 경우 페이지를 나눠서 조회할 수 있습니다.
  /// size 파라미터 값에 따라 1~45까지 가능합니다.
  final int? page;

  /// 한 페이지에 보여질 검색 결과 개수입니다. (선택)
  ///
  /// 기본값은 15이며, 1~15 사이의 값을 사용할 수 있습니다.
  final int? size;

  /// 정렬 옵션입니다. (선택)
  ///
  /// - ACCURACY: 정확도순 정렬 (기본값)
  /// - DISTANCE: 거리순 정렬 (x, y 파라미터와 함께 사용 시에만 유효)
  final SortBy? sort;

  /// 지정한 Map 객체의 중심 좌표를 사용할지의 여부입니다. (선택)
  ///
  /// true일 경우 지도의 중심 좌표를 검색 중심으로 사용합니다.
  /// 이 경우 x, y 파라미터는 무시됩니다. 기본값은 false입니다.
  final bool? useMapCenter;

  /// 지정한 Map 객체의 영역을 사용할지의 여부입니다. (선택)
  ///
  /// true일 경우 지도의 영역 정보를 검색 영역으로 사용합니다.
  /// 이 경우 rect 파라미터는 무시됩니다. 기본값은 false입니다.
  final bool? useMapBounds;

  /// CategorySearchRequest 생성자입니다.
  ///
  /// [categoryGroupCode]는 필수 파라미터이며, 나머지는 선택 파라미터입니다.
  CategorySearchRequest({
    required this.categoryGroupCode,
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

  /// JSON 객체로부터 CategorySearchRequest 인스턴스를 생성합니다.
  factory CategorySearchRequest.fromJson(Map<String, dynamic> json) =>
      _$CategorySearchRequestFromJson(json);

  /// CategorySearchRequest 인스턴스를 JSON 객체로 변환합니다.
  Map<String, dynamic> toJson() => _$CategorySearchRequestToJson(this);

  @override
  String toString() {
    return 'CategorySearchRequest{categoryGroupCode: $categoryGroupCode, x: $x, y: $y, radius: $radius, rect: $rect, page: $page, size: $size, sort: $sort}';
  }
}

CategorySearchRequest _$CategorySearchRequestFromJson(
        Map<String, dynamic> json) =>
    CategorySearchRequest(
      categoryGroupCode:
          CategoryType.getByName(json['category_group_code'] as String),
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

Map<String, dynamic> _$CategorySearchRequestToJson(
        CategorySearchRequest instance) =>
    <String, dynamic>{
      'categoryGroupCode': instance.categoryGroupCode.name,
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
