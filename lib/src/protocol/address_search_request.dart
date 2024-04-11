part of '../../kakao_map_plugin.dart';

class AddressSearchRequest {
  /// 변환할 주소명, 필수
  final String addr;

  /// 검색할 페이지. 기본값은 1
  final int? page;

  /// 검색할 페이지. 기본값은 10, 1~30 까지 가능
  final int? size;

  /// 검색어 매칭 방식 선택 옵션. SIMILAR 일 경우 입력한 것과 유사한 검색어도 검색결과에 포함시킨다.
  /// EXACT 일 경우 입력한 주소 문자열과 정확하게 매칭되는 주소만을 찾아준다.
  /// 기본값은 SIMILAR
  final AnalyzeType? analyzeType;

  AddressSearchRequest({
    required this.addr,
    this.page,
    this.size,
    this.analyzeType,
  });

  factory AddressSearchRequest.fromJson(Map<String, dynamic> json) =>
      _$AddressSearchRequestFromJson(json);

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
