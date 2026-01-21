part of '../../kakao_map_plugin.dart';

/// 지도 위에 그려지는 도형의 기본 스타일을 정의하는 클래스입니다.
///
/// 선(Polyline), 다각형(Polygon), 원(Circle) 등 모든 도형 객체의
/// 공통 스타일 속성을 관리합니다.
class BaseDraw {
  /// 선의 두께 (픽셀 단위)
  ///
  /// null이면 기본값 사용
  int? strokeWidth;

  /// 선의 색상
  ///
  /// null이면 기본 색상 사용
  Color? strokeColor;

  /// 선의 불투명도
  ///
  /// 0.0 (완전 투명) ~ 1.0 (완전 불투명)
  /// null이면 기본값 사용
  double? strokeOpacity;

  /// 선의 스타일 (실선, 점선, 대시선 등)
  ///
  /// null이면 [StrokeStyle.solid] (실선) 사용
  StrokeStyle? strokeStyle = StrokeStyle.solid;

  /// 도형 내부 채우기 색상
  ///
  /// null이면 채우기 없음
  Color? fillColor;

  /// 도형 내부 채우기 불투명도
  ///
  /// 0.0 (완전 투명) ~ 1.0 (완전 불투명)
  /// null이면 기본값 사용
  double? fillOpacity;

  /// 도형의 Z-Index (겹침 순서)
  ///
  /// 값이 클수록 위에 표시됩니다.
  int zIndex = 0;

  /// BaseDraw 생성자
  ///
  /// [strokeWidth] 선의 두께
  /// [strokeColor] 선의 색상
  /// [strokeOpacity] 선의 불투명도
  /// [strokeStyle] 선의 스타일
  /// [fillColor] 채우기 색상
  /// [fillOpacity] 채우기 불투명도
  /// [zIndex] 겹침 순서 (기본값: 0)
  BaseDraw({
    this.strokeWidth,
    this.strokeColor,
    this.strokeOpacity,
    this.strokeStyle,
    this.fillColor,
    this.fillOpacity,
    this.zIndex = 0,
  });
}
