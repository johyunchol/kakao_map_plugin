part of '../../../kakao_map_plugin.dart';

/// 장소 카테고리 타입을 나타내는 열거형입니다.
///
/// 카카오 지도 API의 장소 검색에서 사용하는 카테고리 코드를 정의합니다.
enum CategoryType {
  /// 대형마트
  mt1('MT1'),

  /// 편의점
  cs2('CS2'),

  /// 어린이집, 유치원
  ps3('PS3'),

  /// 학교
  sc4('SC4'),

  /// 학원
  ac5('AC5'),

  /// 주차장
  pk6('PK6'),

  /// 주유소, 충전소
  ol7('OL7'),

  /// 지하철역
  sw8('SW8'),

  /// 은행
  bk9('BK9'),

  /// 문화시설
  ct1('CT1'),

  /// 중개업소
  ag2('AG2'),

  /// 공공기관
  po3('PO3'),

  /// 관광명소
  at4('AT4'),

  /// 숙박
  ad5('AD5'),

  /// 음식점
  fd6('FD6'),

  /// 카페
  ce7('CE7'),

  /// 병원
  hp8('HP8'),

  /// 약국
  pm9('PM9');

  const CategoryType(this.name);

  /// 카테고리 코드 이름
  final String name;

  /// 이름으로 카테고리 타입을 찾습니다.
  ///
  /// [styleName] 찾을 카테고리의 코드 이름
  /// 해당하는 이름이 없으면 [CategoryType.mt1]을 반환합니다.
  factory CategoryType.getByName(String styleName) {
    return CategoryType.values.firstWhere((value) => value.name == styleName,
        orElse: () => CategoryType.mt1);
  }
}
