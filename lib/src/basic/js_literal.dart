import 'dart:convert';

/// Dart 값을 JavaScript 소스에 안전하게 삽입하기 위한 내부 헬퍼입니다.
///
/// 라이브러리 외부로 export 되지 않습니다.
///
/// 문자열 보간으로 JS 를 조립할 때 따옴표나 줄바꿈이 섞이면 구문이 깨지고
/// 임의 코드가 실행될 수 있습니다. 모든 값은 여기를 거쳐 전달합니다.

/// Dart 문자열을 JS 문자열 리터럴(큰따옴표 포함)로 변환합니다.
///
/// `jsonEncode` 가 따옴표, 백슬래시, 제어 문자를 모두 이스케이프하므로
/// 임의의 사용자 입력이 JS 구문을 깨뜨리지 않습니다. JS 문자열 리터럴에서만
/// 줄바꿈으로 취급되는 U+2028/U+2029 도 추가로 이스케이프합니다.
String jsStringLiteral(String value) {
  return jsonEncode(value)
      .replaceAll('\u2028', r'\u2028')
      .replaceAll('\u2029', r'\u2029');
}

/// 임의의 값을 JSON 으로 직렬화한 뒤 JS 문자열 리터럴로 감쌉니다.
///
/// JS 쪽에서 `JSON.parse` 로 되돌려 사용합니다.
String jsJsonLiteral(Object? value) => jsStringLiteral(jsonEncode(value));

/// 숫자/불리언 등 원시값을 JS 리터럴로 변환합니다.
///
/// null 은 `undefined` 가 되어 JS 기본 파라미터가 적용됩니다.
/// 문자열은 인젝션 위험이 있으므로 [jsStringLiteral] 을 사용해야 합니다.
String jsPrimitiveLiteral(Object? value) {
  if (value == null) return 'undefined';
  if (value is num || value is bool) return value.toString();
  assert(false,
      'jsPrimitiveLiteral 은 숫자/불리언만 허용합니다. 문자열은 jsStringLiteral 을 사용하세요.');
  return jsStringLiteral(value.toString());
}
