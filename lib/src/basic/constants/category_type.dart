part of '../../../kakao_map_plugin.dart';

enum CategoryType {
  /// 대형마트
  mt1('MT1'), // 대형마트
  cs2('CS2'), // 편의점
  ps3('PS3'), // 어린이집, 유치원
  sc4('SC4'), // 학교
  ac5('AC5'), // 학원
  pk6('PK6'), // 주차장
  ol7('OL7'), // 주유소, 충전소
  sw8('SW8'), // 지하철역
  bk9('BK9'), // 은행
  ct1('CT1'), // 문화시설
  ag2('AG2'), // 중개업소
  po3('PO3'), // 공공기관
  at4('AT4'), // 관광명소
  ad5('AD5'), // 숙박
  fd6('FD6'), // 음식점
  ce7('CE7'), // 카페
  hp8('HP8'), // 병원
  pm9('PM9'), // 약국
  ;

  const CategoryType(this.name);

  final String name;

  factory CategoryType.getByName(String styleName) {
    return CategoryType.values.firstWhere((value) => value.name == styleName,
        orElse: () => CategoryType.mt1);
  }
}
