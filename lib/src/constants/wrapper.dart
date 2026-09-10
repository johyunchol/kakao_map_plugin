import '../basic/constants/kakao_map_library.dart';
import '../basic/kakao_map_theme.dart';
import '../repository/auth_repository.dart';

/// 두 래퍼가 공유하는 기본 스타일입니다.
const String _baseStyles = '''
    /* 앱처럼 보이도록 하는 기본 스타일: 시스템 글꼴, 탭 하이라이트·텍스트 선택·롱프레스 콜아웃 제거,
       오버스크롤/스크롤바/포커스 링 제거. 선택 가능해야 하는 요소는 .kmp-selectable 을 주세요. */
    html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; overscroll-behavior: none; }
    html { -webkit-text-size-adjust: 100%; text-size-adjust: 100%; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Apple SD Gothic Neo", Roboto, "Noto Sans KR", "Malgun Gothic", sans-serif;
      -webkit-tap-highlight-color: transparent;
      -webkit-touch-callout: none;
      -webkit-user-select: none;
      user-select: none;
      word-break: keep-all;
    }
    input, textarea, [contenteditable], .kmp-selectable { -webkit-user-select: text; user-select: text; }
    img { -webkit-touch-callout: none; -webkit-user-drag: none; }
    button, a { -webkit-tap-highlight-color: transparent; }
    :focus:not(:focus-visible) { outline: none; }
''';

/// 두 래퍼가 공유하는 기본 스크립트입니다.
const String _baseScript = '''
  <script>
    (function () {
      // 페이지 자체의 핀치 줌(iOS)과 롱프레스/우클릭 메뉴를 막아 앱처럼 보이게 합니다.
      document.addEventListener('gesturestart', function (e) { e.preventDefault(); });
      document.addEventListener('contextmenu', function (e) { e.preventDefault(); });
      // 콘텐츠 안의 링크를 탭하면 WebView 가 그 주소로 이동해 지도가 사라지므로,
      // 이동을 막고 Flutter(onLinkTap)에 알립니다.
      document.addEventListener('click', function (e) {
        var el = e.target;
        while (el && el !== document && !(el.tagName === 'A' && el.getAttribute('href'))) el = el.parentNode;
        if (!el || el === document) return;
        var href = el.getAttribute('href');
        if (!href || href.charAt(0) === '#' || href.indexOf('javascript:') === 0) return;
        e.preventDefault();
        if (typeof onLinkTap !== 'undefined' && onLinkTap && onLinkTap.postMessage) {
          onLinkTap.postMessage(JSON.stringify({ url: el.href }));
        }
      }, true);
    })();
  </script>
''';

/// 카카오 지도 JavaScript SDK 를 불러오는 HTML 문서를 생성합니다.
///
/// [script]는 `<body>` 안에 삽입될 `<script>` 블록입니다.
/// [libraries]는 함께 불러올 확장 라이브러리 집합이며, 생략하면
/// [AuthRepository.libraries]에 설정된 값(기본값: 전체)을 사용합니다.
///
/// 라이브러리 내부에서 사용하는 함수입니다. 직접 호출할 필요는 없습니다.
String htmlWrapper(String script,
    {Set<KakaoMapLibrary>? libraries, KakaoMapTheme? theme}) {
  final selected = libraries ?? AuthRepository.instance.libraries;
  final themeCss = (theme ?? AuthRepository.instance.theme)?.toCss() ?? '';
  final librariesValue = KakaoMapLibrary.toQueryValue(selected);
  final librariesParam =
      librariesValue.isEmpty ? '' : '&libraries=$librariesValue';
  final appKey = Uri.encodeQueryComponent(AuthRepository.instance.appKey);

  return '''
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport"
        content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0" />
  <script type="text/javascript"
          src="https://dapi.kakao.com/v2/maps/sdk.js?autoload=false&appkey=$appKey$librariesParam"></script>
  <style>
$_baseStyles
    /* iOS touch event optimization for CustomOverlay tap */
    .custom-overlay-clickable {
      cursor: pointer;
      -webkit-tap-highlight-color: transparent;
      -webkit-touch-callout: none;
      -webkit-user-select: none;
      user-select: none;
      touch-action: manipulation;
    }
$themeCss
  </style>
$_baseScript
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
    {Set<KakaoMapLibrary>? libraries, KakaoMapTheme? theme}) {
  final themeCss = (theme ?? AuthRepository.instance.theme)?.toCss() ?? '';
  final selected = libraries ?? AuthRepository.instance.libraries;
  final librariesValue = KakaoMapLibrary.toQueryValue(selected);
  final librariesParam =
      librariesValue.isEmpty ? '' : '&libraries=$librariesValue';
  final appKey = Uri.encodeQueryComponent(AuthRepository.instance.appKey);

  return """
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport"
        content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0" />
  <script type="text/javascript"
          src="https://dapi.kakao.com/v2/maps/sdk.js?autoload=false&appkey=$appKey$librariesParam"></script>
  <style>
$_baseStyles
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

    /* 동동이(MapWalker) 스프라이트. 카카오 공식 샘플(moveRoadview)의 좌표를 그대로 사용합니다.
       pan 값을 22.5도 단위로 16분할해 m0~m15 클래스를 갈아끼웁니다.
       angleBack 은 바라보는 방향의 시야각(부채꼴), figure 는 사람 아이콘입니다. */
    .MapWalker { position: absolute; margin: -26px 0 0 -51px; }
    .MapWalker .figure {
      position: absolute; width: 25px; height: 39px; left: 38px; top: -2px;
      background: url(https://t1.daumcdn.net/localimg/localimages/07/2018/pc/roadview_minimap_wk_2018.png) -298px -114px no-repeat;
    }
    .MapWalker .angleBack {
      width: 102px; height: 52px;
      background: url(https://t1.daumcdn.net/localimg/localimages/07/2018/pc/roadview_minimap_wk_2018.png) -834px -2px no-repeat;
    }
    .MapWalker.m0 .figure { background-position: -298px -114px; }
    .MapWalker.m1 .figure { background-position: -335px -114px; }
    .MapWalker.m2 .figure { background-position: -372px -114px; }
    .MapWalker.m3 .figure { background-position: -409px -114px; }
    .MapWalker.m4 .figure { background-position: -446px -114px; }
    .MapWalker.m5 .figure { background-position: -483px -114px; }
    .MapWalker.m6 .figure { background-position: -520px -114px; }
    .MapWalker.m7 .figure { background-position: -557px -114px; }
    .MapWalker.m8 .figure { background-position: -2px -114px; }
    .MapWalker.m9 .figure { background-position: -39px -114px; }
    .MapWalker.m10 .figure { background-position: -76px -114px; }
    .MapWalker.m11 .figure { background-position: -113px -114px; }
    .MapWalker.m12 .figure { background-position: -150px -114px; }
    .MapWalker.m13 .figure { background-position: -187px -114px; }
    .MapWalker.m14 .figure { background-position: -224px -114px; }
    .MapWalker.m15 .figure { background-position: -261px -114px; }
    .MapWalker.m0 .angleBack { background-position: -834px -2px; }
    .MapWalker.m1 .angleBack { background-position: -938px -2px; }
    .MapWalker.m2 .angleBack { background-position: -1042px -2px; }
    .MapWalker.m3 .angleBack { background-position: -1146px -2px; }
    .MapWalker.m4 .angleBack { background-position: -1250px -2px; }
    .MapWalker.m5 .angleBack { background-position: -1354px -2px; }
    .MapWalker.m6 .angleBack { background-position: -1458px -2px; }
    .MapWalker.m7 .angleBack { background-position: -1562px -2px; }
    .MapWalker.m8 .angleBack { background-position: -2px -2px; }
    .MapWalker.m9 .angleBack { background-position: -106px -2px; }
    .MapWalker.m10 .angleBack { background-position: -210px -2px; }
    .MapWalker.m11 .angleBack { background-position: -314px -2px; }
    .MapWalker.m12 .angleBack { background-position: -418px -2px; }
    .MapWalker.m13 .angleBack { background-position: -522px -2px; }
    .MapWalker.m14 .angleBack { background-position: -626px -2px; }
    .MapWalker.m15 .angleBack { background-position: -730px -2px; }
$themeCss
  </style>
$_baseScript
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
