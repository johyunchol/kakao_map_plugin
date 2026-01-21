import 'dart:convert';

import 'package:flutter/services.dart';

import 'constants/image_type.dart';

/// 마커에 사용할 커스텀 아이콘을 나타내는 클래스입니다.
///
/// 마커 아이콘은 에셋 이미지 또는 네트워크 URL로부터 생성할 수 있습니다.
/// 에셋 이미지는 base64로 인코딩되어 저장되며, 네트워크 이미지는 URL이 저장됩니다.
///
/// 예시:
/// ```dart
/// // 에셋 이미지 사용
/// final assetIcon = await MarkerIcon.fromAsset('assets/marker.png');
///
/// // 네트워크 이미지 사용
/// final networkIcon = await MarkerIcon.fromNetwork('https://example.com/marker.png');
/// ```
class MarkerIcon {
  /// 이미지 소스입니다.
  ///
  /// 에셋 이미지의 경우 base64로 인코딩된 문자열이며,
  /// 네트워크 이미지의 경우 URL 문자열입니다.
  final String imageSrc;

  /// 이미지 타입입니다.
  ///
  /// [ImageType.file]은 에셋 이미지를, [ImageType.url]은 네트워크 이미지를 나타냅니다.
  /// 기본값은 [ImageType.file]입니다.
  ImageType? imageType = ImageType.file;

  /// 마커 아이콘의 내부 생성자입니다.
  ///
  /// 이 생성자는 직접 호출하지 않고, [fromAsset] 또는 [fromNetwork] 팩토리 메서드를 사용하세요.
  MarkerIcon._(this.imageSrc, {this.imageType});

  /// 에셋 이미지로부터 마커 아이콘을 생성합니다.
  ///
  /// [assetName]은 pubspec.yaml에 정의된 에셋 경로여야 합니다.
  /// 이미지는 base64로 인코딩되어 저장됩니다.
  ///
  /// 예시:
  /// ```dart
  /// final icon = await MarkerIcon.fromAsset('assets/images/marker.png');
  ///
  /// final marker = Marker(
  ///   markerId: 'marker_1',
  ///   latLng: LatLng(37.5665, 126.9780),
  ///   icon: icon,
  /// );
  /// ```
  ///
  /// Returns: base64로 인코딩된 이미지를 포함하는 [MarkerIcon] 인스턴스
  static Future<MarkerIcon> fromAsset(String assetName) async {
    ByteData data = await rootBundle.load(assetName);
    List<int> bytes = data.buffer.asUint8List();
    String base64String = base64Encode(bytes);
    return MarkerIcon._(base64String, imageType: ImageType.file);
  }

  /// 네트워크 URL로부터 마커 아이콘을 생성합니다.
  ///
  /// [url]은 인터넷에서 접근 가능한 이미지 URL이어야 합니다.
  /// 이미지는 런타임에 로드됩니다.
  ///
  /// 예시:
  /// ```dart
  /// final icon = await MarkerIcon.fromNetwork(
  ///   'https://example.com/images/marker.png',
  /// );
  ///
  /// final marker = Marker(
  ///   markerId: 'marker_1',
  ///   latLng: LatLng(37.5665, 126.9780),
  ///   icon: icon,
  /// );
  /// ```
  ///
  /// Returns: URL을 포함하는 [MarkerIcon] 인스턴스
  static Future<MarkerIcon> fromNetwork(String url) {
    return Future.value(MarkerIcon._(url, imageType: ImageType.url));
  }
}
