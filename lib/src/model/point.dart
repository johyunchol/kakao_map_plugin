part of '../../kakao_map_plugin.dart';

/// Represents a point in pixel coordinates on the map
class Point {
  /// x coordinate (horizontal position in pixels)
  double x;

  /// y coordinate (vertical position in pixels)
  double y;

  Point(this.x, this.y);

  factory Point.fromJson(Map<String, dynamic> json) => _$PointFromJson(json);

  Map<String, dynamic> toJson() => _$PointToJson(this);

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
