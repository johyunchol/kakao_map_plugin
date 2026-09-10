/// 로드뷰에서 바라보는 시점(방향과 확대 수준)을 나타냅니다.
///
/// 로드뷰는 파노라마 이미지를 보여주므로, 같은 위치라도 어느 방향을 어느 정도
/// 확대해 보는지에 따라 화면이 달라집니다.
///
/// 예시:
/// ```dart
/// // 북쪽을 정면으로 바라보기
/// final viewpoint = Viewpoint(pan: 0, tilt: 0, zoom: 0);
///
/// await controller.setViewpoint(viewpoint);
/// ```
class Viewpoint {
  /// 수평 회전 각도입니다. 단위는 도(degree)이며 범위는 0 ~ 360 입니다.
  ///
  /// 0 이 북쪽이고 시계 방향으로 증가합니다. (90 이 동쪽)
  final double pan;

  /// 수직 회전 각도입니다. 단위는 도(degree)이며 범위는 -90 ~ 90 입니다.
  ///
  /// 양수는 위쪽, 음수는 아래쪽을 바라봅니다.
  final double tilt;

  /// 확대 수준입니다. 범위는 -3 ~ 3 이며 값이 클수록 확대됩니다.
  final double zoom;

  /// 시점을 생성합니다.
  ///
  /// 모든 값은 생략 가능하며 기본값은 정면(0, 0, 0)입니다.
  const Viewpoint({
    this.pan = 0,
    this.tilt = 0,
    this.zoom = 0,
  });

  /// JSON Map 으로부터 [Viewpoint]를 생성합니다.
  ///
  /// [json]은 'pan', 'tilt', 'zoom' 키를 포함해야 합니다.
  factory Viewpoint.fromJson(Map<String, dynamic> json) => Viewpoint(
        pan: (json['pan'] as num?)?.toDouble() ?? 0,
        tilt: (json['tilt'] as num?)?.toDouble() ?? 0,
        zoom: (json['zoom'] as num?)?.toDouble() ?? 0,
      );

  /// [Viewpoint]를 JSON Map 으로 변환합니다.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'pan': pan,
        'tilt': tilt,
        'zoom': zoom,
      };

  /// 일부 값만 바꾼 새 [Viewpoint]를 만듭니다.
  Viewpoint copyWith({double? pan, double? tilt, double? zoom}) => Viewpoint(
        pan: pan ?? this.pan,
        tilt: tilt ?? this.tilt,
        zoom: zoom ?? this.zoom,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Viewpoint &&
          pan == other.pan &&
          tilt == other.tilt &&
          zoom == other.zoom;

  @override
  int get hashCode => Object.hash(pan, tilt, zoom);

  @override
  String toString() => 'Viewpoint{pan: $pan, tilt: $tilt, zoom: $zoom}';
}
