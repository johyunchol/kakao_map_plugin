/// 이미지 타입을 나타내는 열거형입니다.
///
/// 마커나 오버레이에 사용할 이미지의 소스 타입을 정의합니다.
enum ImageType {
  /// URL 이미지
  ///
  /// 웹 URL을 통해 제공되는 이미지를 사용합니다.
  url("url"),

  /// 로컬 파일 이미지
  ///
  /// 앱 내부에 저장된 로컬 파일 이미지를 사용합니다.
  file("file");

  const ImageType(this.name);

  /// 이미지 타입 이름
  final String name;

  /// 이름으로 이미지 타입을 찾습니다.
  ///
  /// [imageTypeName] 찾을 이미지 타입의 이름
  /// 해당하는 이름이 없으면 [ImageType.url]을 반환합니다.
  factory ImageType.getByName(String imageTypeName) {
    return ImageType.values.firstWhere((value) => value.name == imageTypeName,
        orElse: () => ImageType.url);
  }
}
