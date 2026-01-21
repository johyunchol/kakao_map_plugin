import '../model/trans_coord.dart';

/// 좌표계 변환 응답 클래스입니다.
///
/// 카카오 로컬 API의 좌표계 변환 결과를 담는 응답 객체입니다.
/// 변환된 좌표 정보 목록을 포함합니다.
///
/// 예시:
/// ```dart
/// final response = await kakaoMapService.transCoord(request);
/// for (var coord in response.list) {
///   print('변환된 X 좌표: ${coord.x}');
///   print('변환된 Y 좌표: ${coord.y}');
/// }
/// ```
class TransCoordResponse {
  /// 변환된 좌표 정보 목록입니다.
  ///
  /// 각 항목은 [TransCoord] 타입으로, 지정한 출력 좌표계로
  /// 변환된 X, Y 좌표 값을 포함합니다.
  /// 일반적으로 하나의 좌표에 대해 하나의 결과가 반환됩니다.
  List<TransCoord> list = [];

  /// TransCoordResponse 생성자입니다.
  ///
  /// [list] 변환 결과 목록을 초기화합니다.
  TransCoordResponse({
    required this.list,
  });

  /// JSON 배열로부터 TransCoordResponse 인스턴스를 생성합니다.
  ///
  /// API 응답의 documents 배열을 파싱하여 [TransCoord] 목록으로 변환합니다.
  TransCoordResponse.fromJson(List<dynamic> json) {
    list = json.map((e) => TransCoord.fromJson(e)).toList();
  }

  /// TransCoordResponse 인스턴스를 JSON 객체로 변환합니다.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['list'] = list.map((v) => v.toJson()).toList();
    return data;
  }

  @override
  String toString() {
    return 'TransCoordResponse{list: $list}';
  }
}
