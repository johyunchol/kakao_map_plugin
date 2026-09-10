import '../basic/constants/kakao_map_library.dart';
import '../repository/auth_repository.dart';

/// 카카오 지도 JavaScript SDK 를 불러오는 HTML 문서를 생성합니다.
///
/// [script]는 `<body>` 안에 삽입될 `<script>` 블록입니다.
/// [libraries]는 함께 불러올 확장 라이브러리 집합이며, 생략하면
/// [AuthRepository.libraries]에 설정된 값(기본값: 전체)을 사용합니다.
///
/// 라이브러리 내부에서 사용하는 함수입니다. 직접 호출할 필요는 없습니다.
String htmlWrapper(String script, {Set<KakaoMapLibrary>? libraries}) {
  final selected = libraries ?? AuthRepository.instance.libraries;
  final librariesValue = KakaoMapLibrary.toQueryValue(selected);
  final librariesParam =
      librariesValue.isEmpty ? '' : '&libraries=$librariesValue';
  final appKey = Uri.encodeQueryComponent(AuthRepository.instance.appKey);

  return '''
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport"
        content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0" />
  <script type="text/javascript"
          src="https://dapi.kakao.com/v2/maps/sdk.js?autoload=false&appkey=$appKey$librariesParam"></script>
  <style>
    /* iOS touch event optimization for CustomOverlay tap */
    .custom-overlay-clickable {
      cursor: pointer;
      -webkit-tap-highlight-color: transparent;
      -webkit-touch-callout: none;
      -webkit-user-select: none;
      user-select: none;
      touch-action: manipulation;
    }
  </style>
</head>

<body style="margin: 0;">
<div id="map" style="width: 100vw; height: 100vh;"></div>

$script

</body>

</html>''';
}
