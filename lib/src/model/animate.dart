part of '../../kakao_map_plugin.dart';

class Animate {
  /// 애니메이션 효과 지속 시간 (단위: ms)
  final int duration;

  Animate({
    required this.duration,
  });

  factory Animate.fromJson(Map<String, dynamic> json) =>
      _$AnimateFromJson(json);

  Map<String, dynamic> toJson() => _$AnimateToJson(this);

  @override
  String toString() {
    return 'Animate{duration: $duration}';
  }
}

Animate _$AnimateFromJson(Map<String, dynamic> json) => Animate(
      duration: json['duration'] as int,
    );

Map<String, dynamic> _$AnimateToJson(Animate instance) => <String, dynamic>{
      'duration': instance.duration,
    };
