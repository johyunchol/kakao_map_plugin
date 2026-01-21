/// 지도 컨트롤 위치를 나타내는 열거형입니다.
///
/// 지도 위에 표시되는 컨트롤(줌, 지도 타입 등)의 위치를 정의합니다.
enum ControlPosition {
  /// 왼쪽 상단
  topLeft(0),

  /// 중앙 상단
  top(1),

  /// 오른쪽 상단
  topRight(2),

  /// 왼쪽 하단
  bottomLeft(3),

  /// 중앙 하단
  bottom(4),

  /// 오른쪽 하단
  bottomRight(5),

  /// 왼쪽 중앙
  left(6),

  /// 오른쪽 중앙
  right(7);

  const ControlPosition(this.id);

  /// 컨트롤 위치의 고유 ID
  final int id;

  /// ID로 컨트롤 위치를 찾습니다.
  ///
  /// [controlPositionId] 찾을 컨트롤 위치의 ID
  /// 해당하는 ID가 없으면 [ControlPosition.top]을 반환합니다.
  factory ControlPosition.getById(int controlPositionId) {
    return ControlPosition.values.firstWhere(
        (value) => value.id == controlPositionId,
        orElse: () => ControlPosition.top);
  }
}
