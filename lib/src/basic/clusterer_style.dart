part of '../../kakao_map_plugin.dart';

/// 클러스터의 시각적 스타일을 정의하는 클래스입니다.
///
/// 클러스터러의 각 크기 구간에 적용할 스타일을 지정합니다.
/// 너비, 높이, 배경색, 텍스트 색상 등을 커스터마이징할 수 있습니다.
///
/// 예시:
/// ```dart
/// final style = ClustererStyle(
///   width: 50,
///   height: 50,
///   background: Colors.blue,
///   borderRadius: 25,
///   color: Colors.white,
///   textAlign: 'center',
///   lineHeight: 50,
/// );
/// ```
class ClustererStyle {
  /// 클러스터의 너비입니다 (픽셀 단위).
  ///
  /// 클러스터 원이나 사각형의 가로 크기를 지정합니다.
  int? width;

  /// 클러스터의 높이입니다 (픽셀 단위).
  ///
  /// 클러스터 원이나 사각형의 세로 크기를 지정합니다.
  /// 원형 클러스터를 만들려면 [width]와 같은 값으로 설정하세요.
  int? height;

  /// 클러스터의 배경색입니다.
  ///
  /// 클러스터 마커의 배경 색상을 지정합니다.
  /// 투명도(alpha)도 지원됩니다.
  ///
  /// 예시:
  /// ```dart
  /// background: Colors.blue,
  /// background: Color(0xFF1E88E5),
  /// background: Colors.red.withOpacity(0.8),
  /// ```
  Color? background;

  /// 클러스터의 테두리 반경입니다 (픽셀 단위).
  ///
  /// 값이 클수록 더 둥근 모서리가 됩니다.
  /// [width]와 [height]가 같고 borderRadius를 width/2로 설정하면 완전한 원이 됩니다.
  /// 기본값은 0(사각형)입니다.
  ///
  /// 예시:
  /// ```dart
  /// borderRadius: 0,  // 사각형
  /// borderRadius: 5,  // 약간 둥근 모서리
  /// borderRadius: 25, // 완전한 원 (width=50, height=50일 때)
  /// ```
  int? borderRadius;

  /// 클러스터 내부 텍스트의 색상입니다.
  ///
  /// 클러스터에 표시되는 마커 개수나 커스텀 텍스트의 색상을 지정합니다.
  ///
  /// 예시:
  /// ```dart
  /// color: Colors.white,
  /// color: Colors.black,
  /// color: Color(0xFFFFFFFF),
  /// ```
  Color? color;

  /// 클러스터 내부 텍스트의 정렬 방식입니다.
  ///
  /// CSS text-align 속성과 동일하게 동작합니다.
  ///
  /// 가능한 값:
  /// - 'left': 왼쪽 정렬
  /// - 'center': 중앙 정렬 (기본값)
  /// - 'right': 오른쪽 정렬
  String? textAlign;

  /// 클러스터 내부 텍스트의 줄 높이입니다 (픽셀 단위).
  ///
  /// 텍스트의 수직 정렬을 조정하는 데 사용됩니다.
  /// 일반적으로 [height]와 같은 값으로 설정하면 텍스트가 수직 중앙에 배치됩니다.
  ///
  /// 예시:
  /// ```dart
  /// height: 50,
  /// lineHeight: 50, // 텍스트가 수직 중앙에 배치됨
  /// ```
  int? lineHeight;

  /// 클러스터 스타일 인스턴스를 생성합니다.
  ///
  /// 모든 파라미터는 선택 사항입니다.
  ///
  /// 예시:
  /// ```dart
  /// // 작은 클러스터용 스타일
  /// final smallStyle = ClustererStyle(
  ///   width: 40,
  ///   height: 40,
  ///   background: Colors.blue,
  ///   borderRadius: 20,
  ///   color: Colors.white,
  ///   textAlign: 'center',
  ///   lineHeight: 40,
  /// );
  ///
  /// // 큰 클러스터용 스타일
  /// final largeStyle = ClustererStyle(
  ///   width: 60,
  ///   height: 60,
  ///   background: Colors.red,
  ///   borderRadius: 30,
  ///   color: Colors.white,
  ///   textAlign: 'center',
  ///   lineHeight: 60,
  /// );
  /// ```
  ClustererStyle({
    this.width,
    this.height,
    this.background,
    this.borderRadius = 0,
    this.color,
    this.textAlign,
    this.lineHeight,
  });

  /// 클러스터 스타일 정보를 JSON 형식으로 변환합니다.
  ///
  /// 플랫폼 채널을 통해 네이티브 코드로 스타일 정보를 전달할 때 사용됩니다.
  /// CSS 형식의 스타일 문자열로 변환됩니다.
  Map<String, dynamic> toJson() {
    return {
      'width': '${width}px',
      'height': '${height}px',
      'background': background?.toHexColorWithAlpha(),
      'borderRadius': '${borderRadius}px',
      'color': color?.toHexColor(),
      'textAlign': textAlign,
      'lineHeight': '${lineHeight}px',
    };
  }
}
