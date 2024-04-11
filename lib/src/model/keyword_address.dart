part of '../../kakao_map_plugin.dart';

class KeywordAddress {
  String? addressName;
  String? categoryGroupCode;
  String? categoryGroupName;
  String? categoryName;
  String? distance;
  String? id;
  String? phone;
  String? placeName;
  String? placeUrl;
  String? roadAddressName;
  String? x;
  String? y;

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

  @override
  String toString() {
    return 'KeywordAddress{addressName: $addressName, categoryGroupCode: $categoryGroupCode, categoryGroupName: $categoryGroupName, categoryName: $categoryName, distance: $distance, id: $id, phone: $phone, placeName: $placeName, placeUrl: $placeUrl, roadAddressName: $roadAddressName, x: $x, y: $y}';
  }
}
