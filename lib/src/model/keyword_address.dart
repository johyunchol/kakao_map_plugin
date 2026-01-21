part of '../../kakao_map_plugin.dart';

/// 키워드 검색 결과 정보를 나타내는 클래스입니다.
///
/// 카카오 로컬 API의 키워드 장소 검색 API 응답 데이터를 담습니다.
/// 장소의 이름, 주소, 카테고리, 연락처, 좌표 등의 상세 정보를 포함합니다.
///
/// 예시:
/// ```dart
/// final keyword = KeywordAddress(
///   id: '12345',
///   placeName: '카카오 판교오피스',
///   addressName: '경기 성남시 분당구 판교역로 235',
///   roadAddressName: '경기 성남시 분당구 판교역로 235',
///   categoryName: '비즈니스,산업 > 인터넷,IT > 포털',
///   categoryGroupCode: '',
///   categoryGroupName: '',
///   phone: '1577-3321',
///   placeUrl: 'http://place.map.kakao.com/12345',
///   x: '127.110769',
///   y: '37.395225',
///   distance: '123',
/// );
/// ```
class KeywordAddress {
  /// 장소명, 업체명입니다.
  ///
  /// 예시: "카카오 판교오피스", "스타벅스 강남역점"
  String? placeName;

  /// 전체 지번 주소입니다.
  ///
  /// 예시: "경기 성남시 분당구 삼평동 681"
  String? addressName;

  /// 전체 도로명 주소입니다.
  ///
  /// 예시: "경기 성남시 분당구 판교역로 235"
  String? roadAddressName;

  /// 장소 ID입니다.
  ///
  /// 검색 결과의 고유 식별자입니다.
  String? id;

  /// 전화번호입니다.
  ///
  /// 전화번호가 없는 경우 빈 문자열입니다.
  /// 예시: "1577-3321", "02-1234-5678"
  String? phone;

  /// 카테고리 그룹 코드입니다.
  ///
  /// 대표 카테고리 그룹 코드입니다.
  /// - "MT1": 대형마트
  /// - "CS2": 편의점
  /// - "PS3": 어린이집, 유치원
  /// - "SC4": 학교
  /// - "AC5": 학원
  /// - "PK6": 주차장
  /// - "OL7": 주유소, 충전소
  /// - "SW8": 지하철역
  /// - "BK9": 은행
  /// - "CT1": 문화시설
  /// - "AG2": 중개업소
  /// - "PO3": 공공기관
  /// - "AT4": 관광명소
  /// - "AD5": 숙박
  /// - "FD6": 음식점
  /// - "CE7": 카페
  /// - "HP8": 병원
  /// - "PM9": 약국
  String? categoryGroupCode;

  /// 카테고리 그룹명입니다.
  ///
  /// 대표 카테고리 그룹명입니다.
  /// 예시: "음식점", "카페", "병원"
  String? categoryGroupName;

  /// 중요 카테고리만 그룹핑한 카테고리 그룹 코드입니다.
  ///
  /// 상세 카테고리 정보입니다.
  /// 예시: "비즈니스,산업 > 인터넷,IT > 포털"
  String? categoryName;

  /// 중심좌표까지의 거리입니다 (단위: meter).
  ///
  /// 검색 시 지정한 중심 좌표로부터의 거리입니다.
  /// x, y 파라미터를 지정한 경우에만 유효합니다.
  /// 예시: "123", "456"
  String? distance;

  /// 장소 상세페이지 URL입니다.
  ///
  /// 카카오맵 웹사이트의 상세 페이지 링크입니다.
  /// 예시: "http://place.map.kakao.com/12345"
  String? placeUrl;

  /// X 좌표 값 (경도, Longitude)입니다.
  ///
  /// WGS84 좌표계를 사용하며, 문자열 형태로 제공됩니다.
  /// 예시: "127.110769"
  String? x;

  /// Y 좌표 값 (위도, Latitude)입니다.
  ///
  /// WGS84 좌표계를 사용하며, 문자열 형태로 제공됩니다.
  /// 예시: "37.395225"
  String? y;

  /// KeywordAddress 객체를 생성합니다.
  ///
  /// 모든 필드는 선택사항입니다.
  KeywordAddress({
    this.addressName,
    this.categoryGroupCode,
    this.categoryGroupName,
    this.categoryName,
    this.distance,
    this.id,
    this.phone,
    this.placeName,
    this.placeUrl,
    this.roadAddressName,
    this.x,
    this.y,
  });

  /// JSON Map으로부터 KeywordAddress 객체를 생성합니다.
  ///
  /// 카카오 로컬 API의 응답 데이터를 파싱할 때 사용됩니다.
  ///
  /// 예시:
  /// ```dart
  /// final json = {
  ///   'place_name': '카카오 판교오피스',
  ///   'address_name': '경기 성남시 분당구 삼평동 681',
  ///   'road_address_name': '경기 성남시 분당구 판교역로 235',
  ///   'id': '12345',
  ///   'phone': '1577-3321',
  ///   'category_group_code': '',
  ///   'category_group_name': '',
  ///   'category_name': '비즈니스,산업 > 인터넷,IT > 포털',
  ///   'distance': '123',
  ///   'place_url': 'http://place.map.kakao.com/12345',
  ///   'x': '127.110769',
  ///   'y': '37.395225',
  /// };
  /// final keyword = KeywordAddress.fromJson(json);
  /// ```
  KeywordAddress.fromJson(Map<String, dynamic> json) {
    addressName = json['address_name'];
    categoryGroupCode = json['category_group_code'];
    categoryGroupName = json['category_group_name'];
    categoryName = json['category_name'];
    distance = json['distance'];
    id = json['id'];
    phone = json['phone'];
    placeName = json['place_name'];
    placeUrl = json['place_url'];
    roadAddressName = json['road_address_name'];
    x = json['x'];
    y = json['y'];
  }

  /// KeywordAddress 객체를 JSON Map으로 변환합니다.
  ///
  /// 모든 필드가 포함된 JSON Map을 반환합니다.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address_name'] = addressName;
    data['category_group_code'] = categoryGroupCode;
    data['category_group_name'] = categoryGroupName;
    data['category_name'] = categoryName;
    data['distance'] = distance;
    data['id'] = id;
    data['phone'] = phone;
    data['place_name'] = placeName;
    data['place_url'] = placeUrl;
    data['road_address_name'] = roadAddressName;
    data['x'] = x;
    data['y'] = y;
    return data;
  }

  /// KeywordAddress 객체의 문자열 표현을 반환합니다.
  ///
  /// 디버깅 및 로깅 용도로 사용됩니다.
  @override
  String toString() {
    return 'KeywordAddress{addressName: $addressName, categoryGroupCode: $categoryGroupCode, categoryGroupName: $categoryGroupName, categoryName: $categoryName, distance: $distance, id: $id, phone: $phone, placeName: $placeName, placeUrl: $placeUrl, roadAddressName: $roadAddressName, x: $x, y: $y}';
  }
}
