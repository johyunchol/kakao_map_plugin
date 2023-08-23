part of kakao_map_plugin;

enum ControlPosition {
  topLeft(0),
  top(1),
  topRight(2),
  bottomLeft(3),
  bottom(4),
  bottomRight(5),
  left(6),
  right(7);

  const ControlPosition(this.id);

  final int id;

  factory ControlPosition.getById(int controlPositionId) {
    return ControlPosition.values.firstWhere(
        (value) => value.id == controlPositionId,
        orElse: () => ControlPosition.top);
  }
}
