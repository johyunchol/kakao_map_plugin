import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

import '../model/lat_lng.dart';

/// 카카오맵 길찾기 수단입니다.
enum KakaoMapRouteMode {
  /// 자동차
  car('car', 'CAR'),

  /// 대중교통
  transit('traffic', 'PUBLICTRANSIT'),

  /// 도보
  walk('walk', 'FOOT'),

  /// 자전거
  bicycle('bicycle', 'BICYCLE');

  /// 웹 링크(`map.kakao.com/link/by/…`)에 쓰는 값
  final String webValue;

  /// 앱 스킴(`kakaomap://route?by=…`)에 쓰는 값
  final String appValue;

  const KakaoMapRouteMode(this.webValue, this.appValue);
}

/// 카카오맵(웹/앱)으로 연결하는 URL 을 만드는 순수 Dart 헬퍼입니다.
///
/// 이 플러그인은 지도를 앱 안에 그리지만, "카카오맵 앱에서 길찾기" 같은 기능은
/// 카카오맵으로 넘기는 편이 자연스럽습니다. 여기서는 URL 만 만들고 실제 실행은
/// 앱이 `url_launcher` 등으로 처리합니다.
///
/// - [web] 계열: `https://map.kakao.com/link/...` — 모바일에서 열면 카카오맵 앱이 설치돼
///   있을 때 앱으로 연결되고, 없으면 모바일 웹 지도가 뜹니다. **가장 안전한 선택**입니다.
/// - [app] 계열: `kakaomap://...` 앱 스킴 — 앱이 없으면 실패하므로 [storeUrl] 로 대체하세요.
///   iOS 는 `Info.plist` 의 `LSApplicationQueriesSchemes` 에 `kakaomap` 을 추가해야
///   `canLaunchUrl` 이 동작합니다.
///
/// 예시:
/// ```dart
/// final uri = KakaoMapLinks.web.route(
///   to: LatLng(37.5665, 126.9780), toName: '서울시청', mode: KakaoMapRouteMode.transit,
/// );
/// await launchUrl(uri, mode: LaunchMode.externalApplication);
/// ```
class KakaoMapLinks {
  KakaoMapLinks._();

  /// `https://map.kakao.com/link/…` 웹 링크 빌더입니다.
  static const KakaoMapWebLinks web = KakaoMapWebLinks._();

  /// `kakaomap://…` 앱 스킴 빌더입니다.
  static const KakaoMapAppLinks app = KakaoMapAppLinks._();

  /// 카카오맵 앱 설치 페이지입니다. 현재 플랫폼에 맞는 스토어 주소를 돌려줍니다.
  static Uri storeUrl({TargetPlatform? platform}) {
    final target = platform ?? (kIsWeb ? TargetPlatform.android : defaultTargetPlatform);
    if (target == TargetPlatform.iOS || target == TargetPlatform.macOS) {
      return Uri.parse('https://apps.apple.com/kr/app/id304608425');
    }
    return Uri.parse(
        'https://play.google.com/store/apps/details?id=net.daum.android.map');
  }

  static String _coords(LatLng p) => '${p.latitude},${p.longitude}';
}

/// `https://map.kakao.com/link/…` 링크입니다.
class KakaoMapWebLinks {
  const KakaoMapWebLinks._();

  static const String _base = 'https://map.kakao.com/link';

  /// 좌표 위치를 지도에 표시합니다. [name] 은 마커에 표시될 이름입니다.
  Uri place(LatLng position, {String name = '위치'}) =>
      Uri.parse('$_base/map/${Uri.encodeComponent(name)},${KakaoMapLinks._coords(position)}');

  /// 카카오 장소 ID 로 장소 상세를 엽니다. (검색 결과의 `id`)
  Uri placeById(String placeId) => Uri.parse('$_base/map/$placeId');

  /// 도착지까지 길찾기를 엽니다. [from] 을 주면 출발지도 지정합니다.
  Uri route({
    required LatLng to,
    String toName = '도착지',
    LatLng? from,
    String fromName = '출발지',
    KakaoMapRouteMode? mode,
  }) {
    final toPart = '${Uri.encodeComponent(toName)},${KakaoMapLinks._coords(to)}';
    if (mode != null && from != null) {
      final fromPart = '${Uri.encodeComponent(fromName)},${KakaoMapLinks._coords(from)}';
      return Uri.parse('$_base/by/${mode.webValue}/$fromPart/$toPart');
    }
    if (from != null) {
      final fromPart = '${Uri.encodeComponent(fromName)},${KakaoMapLinks._coords(from)}';
      return Uri.parse('$_base/from/$fromPart/to/$toPart');
    }
    return Uri.parse('$_base/to/$toPart');
  }

  /// 장소 ID 를 도착지로 길찾기를 엽니다.
  Uri routeToPlace(String placeId) => Uri.parse('$_base/to/$placeId');

  /// 좌표의 로드뷰를 엽니다.
  Uri roadview(LatLng position) => Uri.parse('$_base/roadview/${KakaoMapLinks._coords(position)}');

  /// 키워드로 검색합니다.
  Uri search(String keyword) => Uri.parse('$_base/search/${Uri.encodeComponent(keyword)}');
}

/// `kakaomap://…` 앱 스킴입니다. 앱이 설치돼 있어야 동작합니다.
class KakaoMapAppLinks {
  const KakaoMapAppLinks._();

  /// 좌표 위치를 봅니다.
  Uri look(LatLng position) =>
      Uri.parse('kakaomap://look?p=${KakaoMapLinks._coords(position)}');

  /// 길찾기를 엽니다. [from] 이 없으면 현재 위치가 출발지입니다.
  Uri route({
    required LatLng to,
    LatLng? from,
    KakaoMapRouteMode mode = KakaoMapRouteMode.car,
  }) {
    final params = <String, String>{
      if (from != null) 'sp': KakaoMapLinks._coords(from),
      'ep': KakaoMapLinks._coords(to),
      'by': mode.appValue,
    };
    return Uri(scheme: 'kakaomap', host: 'route', queryParameters: params);
  }

  /// 키워드로 검색합니다. [near] 를 주면 그 좌표 주변을 우선합니다.
  Uri search(String keyword, {LatLng? near}) => Uri(
        scheme: 'kakaomap',
        host: 'search',
        queryParameters: {
          'q': keyword,
          if (near != null) 'p': KakaoMapLinks._coords(near),
        },
      );

  /// 카카오 장소 ID 의 상세를 엽니다.
  Uri place(String placeId) => Uri(scheme: 'kakaomap', host: 'place', queryParameters: {'id': placeId});

  /// 카카오맵 앱을 엽니다.
  Uri open() => Uri.parse('kakaomap://open');
}
