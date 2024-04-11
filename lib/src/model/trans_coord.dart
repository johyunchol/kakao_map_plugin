part of '../../kakao_map_plugin.dart';

class TransCoord {
  final double? x;
  final double? y;

  const TransCoord({
    required this.x,
    required this.y,
  });

  factory TransCoord.fromJson(Map<String, dynamic> json) => TransCoord(
        x: json['x'] as double?,
        y: json['y'] as double?,
      );

  Map<String, dynamic> toJson() => {
        "x": x,
        "y": y,
      };

  @override
  String toString() {
    return 'TransCoord{x: $x, y: $y}';
  }
}
