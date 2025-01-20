part of '../../../kakao_map_plugin.dart';

enum ImageType {
  url("url"),
  file("file");

  const ImageType(this.name);

  final String name;

  factory ImageType.getByName(String imageTypeName) {
    return ImageType.values.firstWhere((value) => value.name == imageTypeName,
        orElse: () => ImageType.url);
  }
}
