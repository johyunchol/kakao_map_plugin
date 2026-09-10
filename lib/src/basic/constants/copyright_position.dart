/// 지도 하단 저작권·로고 표시 위치입니다.
enum CopyrightPosition {
  /// 왼쪽 아래
  bottomLeft('BOTTOMLEFT'),

  /// 오른쪽 아래 (플러그인 기본값)
  bottomRight('BOTTOMRIGHT');

  /// 카카오 SDK 상수 이름입니다.
  final String sdkName;

  const CopyrightPosition(this.sdkName);
}
