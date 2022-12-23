part of kakao_map_plugin;

enum ControlPosition {
  TOPLEFT(0),
  TOP(1),
  TOPRIGHT(2),
  BOTTOMLEFT(3),
  BOTTOM(4),
  BOTTOMRIGHT(5),
  LEFT(6),
  RIGHT(7);

  const ControlPosition(this.id);

  final int id;

  factory ControlPosition.getById(int controlPositionId) {
    return ControlPosition.values
        .firstWhere((value) => value.id == controlPositionId, orElse: () => ControlPosition.TOP);
  }
}
