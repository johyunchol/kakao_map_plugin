/// 지도상의 픽셀 좌표를 나타내는 포인트 클래스입니다.
///
/// 화면상의 위치를 픽셀 단위로 표현하며, 지도의 중심점 이동이나
/// 오버레이 객체의 위치 지정 등에 사용됩니다.
///
/// 예시:
/// ```dart
/// // 화면 중앙에서 100픽셀 오른쪽, 50픽셀 아래
/// final offset = Point(100, 50);
/// print('X: ${offset.x}, Y: ${offset.y}');
///
/// // JSON으로 변환
/// final json = offset.toJson();
/// // {"x": 100, "y": 50}
/// ```
class Point {
  /// X 좌표 값입니다 (가로 위치, 픽셀 단위).
  ///
  /// 화면의 왼쪽이 0이며, 오른쪽으로 갈수록 값이 증가합니다.
  double x;

  /// Y 좌표 값입니다 (세로 위치, 픽셀 단위).
  ///
  /// 화면의 위쪽이 0이며, 아래쪽으로 갈수록 값이 증가합니다.
  double y;

  /// [x]와 [y] 픽셀 좌표를 받아 Point 객체를 생성합니다.
  ///
  /// 예시:
  /// ```dart
  /// final point = Point(100, 50);
  /// ```
  Point(this.x, this.y);

  /// JSON Map으로부터 Point 객체를 생성합니다.
  ///
  /// [json]은 'x'와 'y' 키를 포함해야 합니다.
  ///
  /// 예시:
  /// ```dart
  /// final json = {'x': 100, 'y': 50};
  /// final point = Point.fromJson(json);
  /// ```
  factory Point.fromJson(Map<String, dynamic> json) => _$PointFromJson(json);

  /// Point 객체를 JSON Map으로 변환합니다.
  ///
  /// 반환값은 'x'와 'y' 키를 포함합니다.
  ///
  /// 예시:
  /// ```dart
  /// final point = Point(100, 50);
  /// final json = point.toJson();
  /// // {"x": 100, "y": 50}
  /// ```
  Map<String, dynamic> toJson() => _$PointToJson(this);

  /// Point 객체의 문자열 표현을 반환합니다.
  ///
  /// 디버깅 및 로깅 용도로 사용됩니다.
  @override
  String toString() {
    return 'Point{x: $x, y: $y}';
  }
}

Point _$PointFromJson(Map<String, dynamic> json) => Point(
      (json['x'] as num).toDouble(),
      (json['y'] as num).toDouble(),
    );

Map<String, dynamic> _$PointToJson(Point instance) => <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
    };
