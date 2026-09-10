/// 커스텀 타일셋 하단에 표시되는 저작권 문구입니다.
///
/// 예시:
/// ```dart
/// const TilesetCopyright('© My Tiles', shortMsg: '© MT', minZoom: 5)
/// ```
class TilesetCopyright {
  /// 기본으로 표시되는 문구입니다.
  final String msg;

  /// 지도 영역이 작아졌을 때 표시되는 짧은 문구입니다.
  ///
  /// 지정하지 않으면 [msg]를 그대로 사용합니다.
  final String? shortMsg;

  /// 이 문구가 표시되기 시작하는 최소 레벨입니다.
  final int minZoom;

  /// 저작권 문구를 생성합니다.
  const TilesetCopyright(this.msg, {this.shortMsg, this.minZoom = 0});

  /// JS 로 전달할 Map 으로 변환합니다.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'msg': msg,
        'shortMsg': shortMsg ?? msg,
        'minZoom': minZoom,
      };
}

/// 카카오 지도 위에 올릴 커스텀 타일셋입니다.
///
/// 타일 이미지를 어디서 가져올지 세 가지 방법 중 **하나만** 지정합니다.
///
/// - [urlTemplate]: `{x}`, `{y}`, `{z}` 자리표시자가 들어간 주소 템플릿
/// - [urlFunction]: `(x, y, z)` 를 받아 주소 문자열을 돌려주는 JavaScript 함수 원문
/// - [tileFunction]: `(x, y, z)` 를 받아 DOM Element 를 돌려주는 JavaScript 함수 원문
///
/// 등록은 `KakaoMapController.addTileset()` 으로 하고, 등록한 [id] 로
/// `setTileset()` (기본 지도로 사용) 또는 `addOverlayTileset()` (기존 지도 위에
/// 겹쳐서 사용) 을 호출합니다.
///
/// 예시:
/// ```dart
/// await controller.addTileset(const Tileset(
///   id: 'MY_TILES',
///   urlTemplate: 'https://tiles.example.com/{z}/{y}/{x}.png',
///   copyright: [TilesetCopyright('© Example')],
/// ));
/// await controller.setTileset('MY_TILES');
/// ```
///
/// [urlFunction] 과 [tileFunction] 은 WebView 안에서 그대로 실행되는 코드이므로
/// 앱이 직접 작성한 문자열만 넘기고, 외부에서 받은 값을 넣지 마세요.
class Tileset {
  /// 타일셋을 구분하는 ID 입니다.
  ///
  /// 영문자, 숫자, 밑줄만 쓸 수 있고 숫자로 시작할 수 없습니다(예: `MY_TILES`).
  /// `ROADMAP`, `SKYVIEW` 처럼 카카오 SDK 가 쓰는 지도 타입 ID 는 사용할 수 없습니다.
  ///
  /// 같은 ID 로 다시 등록하면 새 타일셋으로 바뀌며, 그 타일셋을 이미 지도에
  /// 표시 중이었다면 화면도 새 타일셋으로 갱신됩니다.
  final String id;

  /// 타일 한 장의 가로 크기입니다. 단위는 픽셀입니다.
  final int width;

  /// 타일 한 장의 세로 크기입니다. 단위는 픽셀입니다.
  final int height;

  /// 타일 주소 템플릿입니다. `{x}`, `{y}`, `{z}` 가 각각 열, 행, 레벨로 치환됩니다.
  final String? urlTemplate;

  /// 타일 주소를 돌려주는 JavaScript 함수 원문입니다.
  ///
  /// 예: `'function (x, y, z) { return "https://…/" + z + "/" + y + "/" + x + ".png"; }'`
  final String? urlFunction;

  /// 타일 Element 를 돌려주는 JavaScript 함수 원문입니다.
  ///
  /// 이미지 대신 임의의 DOM 을 타일로 쓰고 싶을 때 사용합니다.
  final String? tileFunction;

  /// 저작권 문구 목록입니다.
  final List<TilesetCopyright> copyright;

  /// 어두운 타일이면 true 로 지정합니다. 지도 컨트롤 색상에 반영됩니다.
  final bool dark;

  /// 타일이 제공되는 최소 레벨입니다. 지정하지 않으면 0 입니다.
  final int? minZoom;

  /// 타일이 제공되는 최대 레벨입니다. 지정하지 않으면 14 입니다.
  final int? maxZoom;

  /// 타일셋을 생성합니다.
  ///
  /// [urlTemplate], [urlFunction], [tileFunction] 중 정확히 하나를 지정해야 합니다.
  const Tileset({
    required this.id,
    this.width = 256,
    this.height = 256,
    this.urlTemplate,
    this.urlFunction,
    this.tileFunction,
    this.copyright = const [],
    this.dark = false,
    this.minZoom,
    this.maxZoom,
  })  : assert(id != '', 'id 는 비어 있을 수 없습니다.'),
        assert(
          (urlTemplate != null ? 1 : 0) +
                  (urlFunction != null ? 1 : 0) +
                  (tileFunction != null ? 1 : 0) ==
              1,
          'urlTemplate, urlFunction, tileFunction 중 하나만 지정하세요.',
        );

  /// JS 로 전달할 Map 으로 변환합니다.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'width': width,
        'height': height,
        if (urlTemplate != null) 'urlTemplate': urlTemplate,
        if (urlFunction != null) 'urlFunction': urlFunction,
        if (tileFunction != null) 'tileFunction': tileFunction,
        'copyright': copyright.map((e) => e.toJson()).toList(growable: false),
        'dark': dark,
        if (minZoom != null) 'minZoom': minZoom,
        if (maxZoom != null) 'maxZoom': maxZoom,
      };
}
