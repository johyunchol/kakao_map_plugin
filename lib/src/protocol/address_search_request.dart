import '../basic/constants/analyze_type.dart';

/// 주소 검색 요청 클래스입니다.
///
/// 카카오 로컬 API의 주소 검색을 위한 요청 파라미터를 정의합니다.
/// 지번 주소와 도로명 주소를 검색하여 좌표로 변환할 수 있습니다.
///
/// 예시:
/// ```dart
/// final request = AddressSearchRequest(
///   addr: '전북 삼성군 운수면 예당리 233-1',
///   analyzeType: AnalyzeType.EXACT,
/// );
/// ```
class AddressSearchRequest {
  /// 검색할 주소입니다. (필수)
  ///
  /// 지번 주소 또는 도로명 주소를 입력할 수 있습니다.
  /// 최대 80자까지 입력 가능합니다.
  final String addr;

  /// 검색할 페이지 번호입니다. (선택)
  ///
  /// 기본값은 1이며, 검색 결과가 많을 경우 페이지를 나눠서 조회할 수 있습니다.
  /// 1~45까지 가능합니다.
  final int? page;

  /// 한 페이지에 보여질 검색 결과 개수입니다. (선택)
  ///
  /// 기본값은 10이며, 1~30 사이의 값을 사용할 수 있습니다.
  final int? size;

  /// 검색어 매칭 방식 선택 옵션입니다. (선택)
  ///
  /// - SIMILAR: 입력한 것과 유사한 검색어도 검색 결과에 포함 (기본값)
  /// - EXACT: 입력한 주소 문자열과 정확하게 매칭되는 주소만 검색
  ///
  /// 예: "삼성동 2" 검색 시
  /// - SIMILAR: "삼성동 2", "삼성동 20", "삼성동 21" 등 모두 포함
  /// - EXACT: "삼성동 2"만 검색
  final AnalyzeType? analyzeType;

  /// AddressSearchRequest 생성자입니다.
  ///
  /// [addr]는 필수 파라미터이며, 나머지는 선택 파라미터입니다.
  AddressSearchRequest({
    required this.addr,
    this.page,
    this.size,
    this.analyzeType,
  });

  /// JSON 객체로부터 AddressSearchRequest 인스턴스를 생성합니다.
  factory AddressSearchRequest.fromJson(Map<String, dynamic> json) =>
      _$AddressSearchRequestFromJson(json);

  /// AddressSearchRequest 인스턴스를 JSON 객체로 변환합니다.
  Map<String, dynamic> toJson() => _$AddressSearchRequestToJson(this);

  @override
  String toString() {
    return 'AddressSearchRequest{addr: $addr, page: $page, size: $size, analyzeType: $analyzeType}';
  }
}

AddressSearchRequest _$AddressSearchRequestFromJson(
        Map<String, dynamic> json) =>
    AddressSearchRequest(
      addr: json['addr'] as String,
      page: json['page'] as int?,
      size: json['size'] as int?,
      analyzeType: AnalyzeType.getByName(json['analyzeType'] as String? ?? ''),
    );

Map<String, dynamic> _$AddressSearchRequestToJson(
        AddressSearchRequest instance) =>
    <String, dynamic>{
      'addr': instance.addr,
      'page': instance.page,
      'size': instance.size,
      'analyzeType': instance.analyzeType?.name,
    };
