/// Drawing Library 로 그릴 수 있는 도형의 종류입니다.
///
/// [DrawingOptions.drawingMode] 에 넣어 어떤 도형을 그릴 수 있게 할지 정하고,
/// `KakaoMapController.selectDrawingMode` 로 현재 그릴 도형을 선택합니다.
enum DrawingOverlayType {
  /// 마커
  marker('marker'),

  /// 사각형
  rectangle('rectangle'),

  /// 원
  circle('circle'),

  /// 타원
  ellipse('ellipse'),

  /// 선
  polyline('polyline'),

  /// 다각형
  polygon('polygon'),

  /// 화살표 선
  arrow('arrow');

  /// 카카오 SDK 가 사용하는 값입니다.
  final String value;

  const DrawingOverlayType(this.value);

  /// SDK 값으로부터 [DrawingOverlayType]을 찾습니다.
  ///
  /// 알 수 없는 값이면 null 을 반환합니다.
  static DrawingOverlayType? fromValue(String value) {
    for (final type in DrawingOverlayType.values) {
      if (type.value == value) return type;
    }
    return null;
  }
}
