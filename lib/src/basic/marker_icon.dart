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
/// final networkIcon = MarkerIcon.network('https://example.com/marker.png');
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

  /// 에셋 이미지의 base64 인코딩 결과를 캐싱하는 저장소입니다.
  ///
  /// 동일한 [assetName]에 대해 [fromAsset]이 반복 호출되어도
  /// 매번 이미지를 다시 읽고 인코딩하지 않도록 합니다.
  static final Map<String, String> _assetCache = {};

  /// 마커 아이콘의 내부 생성자입니다.
  ///
  /// 이 생성자는 직접 호출하지 않고, [fromAsset] 또는 [network] 팩토리 메서드를 사용하세요.
  MarkerIcon._(this.imageSrc, {this.imageType});

  /// 에셋 이미지로부터 마커 아이콘을 생성합니다.
  ///
  /// [assetName]은 pubspec.yaml에 정의된 에셋 경로여야 합니다.
  /// 이미지는 base64로 인코딩되어 저장됩니다.
  ///
  /// 동일한 [assetName]으로 다시 호출하면 캐시된 결과를 반환하여
  /// 불필요한 파일 읽기 및 인코딩을 방지합니다.
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
    // base64 문자열만 캐시하고 인스턴스는 매번 새로 만듭니다.
    // (imageType 이 가변 필드이므로 인스턴스 공유 시 호출자 간 간섭이 생길 수 있음)
    var base64String = _assetCache[assetName];
    if (base64String == null) {
      final ByteData data = await rootBundle.load(assetName);
      base64String = base64Encode(data.buffer.asUint8List());
      _assetCache[assetName] = base64String;
    }
    return MarkerIcon._(base64String, imageType: ImageType.file);
  }

  /// 이미지 바이트(PNG 등)로부터 마커 아이콘을 생성합니다.
  ///
  /// 네트워크나 파일에서 직접 읽은 바이트를 사용할 때 유용합니다.
  ///
  /// 예시:
  /// ```dart
  /// final bytes = await File('marker.png').readAsBytes();
  /// final icon = MarkerIcon.fromBytes(bytes);
  /// ```
  static MarkerIcon fromBytes(List<int> bytes) =>
      MarkerIcon._(base64Encode(bytes), imageType: ImageType.file);

  /// base64 로 인코딩된 이미지 문자열로부터 마커 아이콘을 생성합니다.
  ///
  /// [base64]는 data URL 접두사(`data:image/png;base64,`) 없이 순수 base64 문자열이어야 합니다.
  static MarkerIcon fromBase64(String base64) =>
      MarkerIcon._(base64, imageType: ImageType.file);

  /// 네트워크 URL로부터 마커 아이콘을 동기적으로 생성합니다. (권장)
  ///
  /// [url]은 인터넷에서 접근 가능한 이미지 URL이어야 합니다.
  /// 이미지는 런타임에 로드됩니다.
  ///
  /// 예시:
  /// ```dart
  /// final icon = MarkerIcon.network(
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
  static MarkerIcon network(String url) {
    return MarkerIcon._(url, imageType: ImageType.url);
  }

  /// 네트워크 URL로부터 마커 아이콘을 생성합니다.
  ///
  /// 네트워크 요청이 발생하지 않으므로 동기 버전인 [network]를 사용하는 것을 권장합니다.
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
  static Future<MarkerIcon> fromNetwork(String url) => Future.value(network(url));
}
