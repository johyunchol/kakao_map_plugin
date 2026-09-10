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

/// 지도와 로드뷰를 한 문서 안에 나란히 두는 HTML 을 생성합니다.
///
/// 지도와 로드뷰를 서로 연동하려면(지도 클릭으로 로드뷰 이동, 동동이 표시 등)
/// 두 객체가 같은 JavaScript 컨텍스트에 있어야 합니다. WebView 를 두 개
/// 띄우면 카카오 SDK 인스턴스가 분리되어 서로를 참조할 수 없으므로,
/// 하나의 WebView 안에 `#map` 과 `#roadview` 를 두고 Flutter 는 표시 비율만
/// 제어합니다.
///
/// [script]는 `<body>` 안에 삽입될 `<script>` 블록입니다.
/// [libraries]는 함께 불러올 확장 라이브러리 집합입니다.
///
/// 라이브러리 내부에서 사용하는 함수입니다. 직접 호출할 필요는 없습니다.
String htmlWrapperWithRoadview(String script,
    {Set<KakaoMapLibrary>? libraries}) {
  final selected = libraries ?? AuthRepository.instance.libraries;
  final librariesValue = KakaoMapLibrary.toQueryValue(selected);
  final librariesParam =
      librariesValue.isEmpty ? '' : '&libraries=$librariesValue';
  final appKey = Uri.encodeQueryComponent(AuthRepository.instance.appKey);

  return """
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport"
        content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0" />
  <script type="text/javascript"
          src="https://dapi.kakao.com/v2/maps/sdk.js?autoload=false&appkey=$appKey$librariesParam"></script>
  <style>
    html, body { margin: 0; padding: 0; width: 100%; height: 100%; }

    /* 지도와 로드뷰를 나란히 배치합니다. 방향과 비율은 JS 로 제어합니다. */
    #container { position: relative; width: 100vw; height: 100vh; overflow: hidden; }
    #mapWrapper { position: absolute; left: 0; top: 0; width: 100%; height: 100%; }
    #map { width: 100%; height: 100%; }
    #roadview { position: absolute; left: 0; top: 0; width: 100%; height: 100%; display: none; }

    /* iOS touch event optimization for CustomOverlay tap */
    .custom-overlay-clickable {
      cursor: pointer;
      -webkit-tap-highlight-color: transparent;
      -webkit-touch-callout: none;
      -webkit-user-select: none;
      user-select: none;
      touch-action: manipulation;
    }

    /* 동동이(MapWalker) 스프라이트.
       pan 값을 22.5도 단위로 16분할해 m0~m15 클래스를 갈아끼웁니다. */
    .MapWalker {
      position: absolute; width: 26px; height: 46px;
      margin: -46px 0 0 -13px;
    }
    .MapWalker .figure, .MapWalker .face {
      position: absolute; left: 0; top: 0;
      background: url(https://t1.daumcdn.net/localimg/localimages/07/2018/pc/roadview_minimap_wk_2018.png) no-repeat;
    }
    .MapWalker .figure { width: 26px; height: 46px; background-position: -50px -55px; }
    .MapWalker .face { width: 26px; height: 46px; }
    .MapWalker.m0 .face { background-position: -1px -1px; }
    .MapWalker.m1 .face { background-position: -34px -1px; }
    .MapWalker.m2 .face { background-position: -67px -1px; }
    .MapWalker.m3 .face { background-position: -100px -1px; }
    .MapWalker.m4 .face { background-position: -133px -1px; }
    .MapWalker.m5 .face { background-position: -166px -1px; }
    .MapWalker.m6 .face { background-position: -199px -1px; }
    .MapWalker.m7 .face { background-position: -232px -1px; }
    .MapWalker.m8 .face { background-position: -265px -1px; }
    .MapWalker.m9 .face { background-position: -298px -1px; }
    .MapWalker.m10 .face { background-position: -331px -1px; }
    .MapWalker.m11 .face { background-position: -364px -1px; }
    .MapWalker.m12 .face { background-position: -397px -1px; }
    .MapWalker.m13 .face { background-position: -430px -1px; }
    .MapWalker.m14 .face { background-position: -463px -1px; }
    .MapWalker.m15 .face { background-position: -496px -1px; }
  </style>
</head>

<body>
<div id="container">
  <div id="mapWrapper"><div id="map"></div></div>
  <div id="roadview"></div>
</div>

$script

</body>

</html>""";
}
