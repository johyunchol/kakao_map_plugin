part of '../../kakao_map_plugin.dart';

class MarkerIcon {
  final String imageSrc;
  ImageType? imageType = ImageType.file;

  MarkerIcon._(this.imageSrc, {this.imageType});

  /// Create a MarkerIcon from an asset image
  static Future<MarkerIcon> fromAsset(String assetName) async {
    ByteData data = await rootBundle.load(assetName);
    List<int> bytes = data.buffer.asUint8List();
    String base64String = base64Encode(bytes);
    return MarkerIcon._(base64String, imageType: ImageType.file);
  }

  /// Create a MarkerIcon from a network image
  static Future<MarkerIcon> fromNetwork(String url) {
    return Future.value(MarkerIcon._(url, imageType: ImageType.url));
  }
}
