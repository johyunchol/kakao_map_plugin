// 하위호환 검증용 카나리아입니다.
//
// 0.4.x 사용자가 작성했을 법한 코드를 그대로 담고 있습니다. 이 파일이 경고 없이
// 컴파일되면 소스 수준 하위호환이 유지된다는 뜻입니다.
// (deprecated 경고는 허용되며, 실제 실행 대상이 아닙니다.)
// ignore_for_file: deprecated_member_use, unused_local_variable, avoid_print

import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

Future<void> oldStyleUsage(KakaoMapController controller) async {
  // --- 오버레이 추가 (0.4.x 시그니처) ---
  await controller.addPolyline(polylines: [
    Polyline(
      polylineId: 'p1',
      points: [LatLng(37.5, 127.0), LatLng(37.6, 127.1)],
      strokeWidth: 5,
      strokeColor: Colors.red,
      strokeOpacity: 0.8,
      strokeStyle: StrokeStyle.solid,
      endArrow: true,
      zIndex: 1,
    ),
  ]);
  await controller.addCircle(circles: [
    Circle(
      circleId: 'c1',
      center: LatLng(37.5, 127.0),
      radius: 100,
      strokeWidth: 2,
      strokeColor: Colors.blue,
      strokeOpacity: 1,
      strokeStyle: StrokeStyle.dash,
      fillColor: Colors.green,
      fillOpacity: 0.4,
    ),
  ]);
  await controller.addRectangle(rectangles: [
    Rectangle(
      rectangleId: 'r1',
      rectangleBounds: LatLngBounds(LatLng(37.4, 126.9), LatLng(37.6, 127.1)),
    ),
  ]);
  await controller.addPolygon(polygons: [
    Polygon(
      polygonId: 'g1',
      points: [LatLng(37.4, 126.9), LatLng(37.5, 127.0), LatLng(37.4, 127.1)],
      holes: const [],
    ),
  ]);
  await controller.addMarker(markers: [
    Marker(
      markerId: 'm1',
      latLng: LatLng(37.5, 127.0),
      width: 30,
      height: 40,
      offsetX: 15,
      offsetY: 40,
      markerImageSrc: 'https://example.com/a.png',
      infoWindowContent: '<div>hi</div>',
      draggable: true,
      infoWindowRemovable: true,
      infoWindowFirstShow: false,
      zIndex: 2,
      customOverlayContent: '<b>x</b>',
      customOverlayXAnchor: 0.5,
      customOverlayYAnchor: 1.0,
    ),
  ]);
  await controller.addMarkerClusterer(
    clusterer: Clusterer(
      markers: [Marker(markerId: 'cm1', latLng: LatLng(37.5, 127.0))],
      gridSize: 60,
      averageCenter: true,
      disableClickZoom: false,
      minLevel: 10,
      minClusterSize: 2,
      texts: const ['10+'],
      calculator: const [10, 100],
      styles: [
        ClustererStyle(
          width: 40,
          height: 40,
          background: Colors.orange,
          borderRadius: 20,
          color: Colors.white,
          textAlign: 'center',
          lineHeight: 40,
        ),
      ],
    ),
  );
  await controller.addCustomOverlay(customOverlays: [
    CustomOverlay(
      customOverlayId: 'o1',
      latLng: LatLng(37.5, 127.0),
      content: '<div>overlay</div>',
      xAnchor: 0.5,
      yAnchor: 1.0,
      zIndex: 3,
    ),
  ]);

  // --- 제거 계열 ---
  await controller.clear();
  await controller.clearPolyline(polylineIds: const ['p1']);
  await controller.clearCircle(circleIds: const ['c1']);
  await controller.clearRectangle(rectangleIds: const ['r1']);
  await controller.clearPolygon(polygonIds: const ['g1']);
  await controller.clearMarker(markerIds: const ['m1']);
  await controller.clearMarkerClusterer();
  await controller.clearCustomOverlay(overlayIds: const ['o1']);
  await controller.dispose();

  // --- 카메라/지도 제어 ---
  await controller.panTo(LatLng(37.5, 127.0));
  await controller.fitBounds([LatLng(37.4, 126.9), LatLng(37.6, 127.1)]);
  await controller.setMarkerDraggable('m1', true);
  await controller.setCenter(LatLng(37.5, 127.0));
  final LatLng center = await controller.getCenter();
  await controller.setLevel(3);
  await controller.setLevel(3, options: LevelOptions(animate: Animate(duration: 300)));
  final int level = await controller.getLevel();
  await controller.setMapTypeId(MapType.normal);
  final MapType mapType = await controller.getMapTypeId();
  await controller.setBounds(); // 0.4.x 에서는 무인자 호출만 가능했다
  await controller.setStyle(100, 200);
  await controller.relayout();
  final LatLngBounds bounds = await controller.getBounds();
  await controller.addOverlayMapTypeId(MapType.traffic);
  await controller.removeOverlayMapTypeId(MapType.traffic);
  await controller.setDraggable(true);
  final Object? draggable = await controller.getDraggable();
  await controller.setZoomable(true);
  final Object? zoomable = await controller.getZoomable();
  final Point pixel = await controller.coordToPixel(LatLng(37.5, 127.0));
  final LatLng coord = await controller.pixelToCoord(Point(1, 2));

  // --- 검색 (반환 타입 포함) ---
  final KeywordSearchResponse kw =
      await controller.keywordSearch(KeywordSearchRequest(keyword: '카페'));
  final CategorySearchResponse ct = await controller
      .categorySearch(CategorySearchRequest(categoryGroupCode: CategoryType.ce7));
  final AddressSearchResponse ad =
      await controller.addressSearch(AddressSearchRequest(addr: '서울'));
  final Coord2AddressResponse c2a =
      await controller.coord2Address(Coord2AddressRequest(x: 127.0, y: 37.5));
  final Coord2RegionCodeResponse c2r = await controller
      .coord2RegionCode(Coord2RegionCodeRequest(x: 127.0, y: 37.5));
  final TransCoordResponse tc =
      await controller.transCoord(TransCoordRequest(x: 127.0, y: 37.5, inputCoord: Coords.wgs84, outputCoord: Coords.wtm));

  // 내부 WebView 컨트롤러 접근
  final webView = controller.webViewController;
}

Future<void> oldStyleStatics() async {
  // AuthRepository: initialize / instance / 직접 대입
  AuthRepository.initialize(appKey: 'key', baseUrl: 'https://example.com');
  AuthRepository.instance.appKey = 'another';
  final String key = AuthRepository.instance.appKey;
  final String? base = AuthRepository.instance.baseUrl;

  // MarkerIcon: 0.4.x 는 두 팩토리 모두 Future 였다
  final Future<MarkerIcon> a = MarkerIcon.fromAsset('assets/a.png');
  final Future<MarkerIcon> b = MarkerIcon.fromNetwork('https://example.com/a.png');
  final MarkerIcon icon = await b;
  final String src = icon.imageSrc;
  final ImageType? type = icon.imageType;

  // 검색 서비스 정적 경로
  KeywordSearchService().resetCompleter();
  KeywordSearchService.keywordSearchCallback('[]');
  final Future<KeywordSearchResponse> r =
      KeywordSearchService.keywordSearchResult();
  CategorySearchService.categorySearchCallback('[]');
  AddressSearchService.addressSearchCallback('[]');
  Coord2AddressService.coord2AddressCallback('[]');
  Coord2RegionCodeService.coord2RegionCodeCallback('[]');
  TransCoordService.transCodeCallback('[]');

  // htmlWrapper 는 0.4.x 에서 인자 1개였다
  final String html = htmlWrapper('<script></script>');

  // 열거형
  const types = [
    MapType.normal,
    MapType.roadMap,
    MapType.skyView,
    MapType.hybrid,
    MapType.overlay,
    MapType.roadView,
    MapType.traffic,
    MapType.terrain,
    MapType.bicycle,
    MapType.useDistrict,
  ];
  final MapType byId = MapType.getById(1);
  const positions = [
    ControlPosition.topLeft,
    ControlPosition.top,
    ControlPosition.topRight,
    ControlPosition.left,
    ControlPosition.right,
    ControlPosition.bottomLeft,
    ControlPosition.bottom,
    ControlPosition.bottomRight,
  ];
  const strokes = [StrokeStyle.solid, StrokeStyle.dash, StrokeStyle.dot];
  const drags = [DragType.start, DragType.move, DragType.end];
  const markerDrags = [MarkerDragType.start, MarkerDragType.end];
  const zooms = [ZoomType.start, ZoomType.end];
  const images = [ImageType.file, ImageType.url];

  // 모델 JSON 왕복
  final LatLng ll = LatLng.fromJson(const {'latitude': 37.5, 'longitude': 127.0});
  final Map<String, dynamic> llJson = ll.toJson();
  final LatLngBounds lb = LatLngBounds(LatLng(37.4, 126.9), LatLng(37.6, 127.1));
  final LatLng sw = lb.getSouthWest();
  final LatLng ne = lb.getNorthEast();
}

/// 0.4.x 스타일의 위젯 사용 (모든 콜백 시그니처 포함)
Widget oldStyleWidget() {
  return KakaoMap(
    onMapCreated: (KakaoMapController controller) {},
    onMapTap: (LatLng latLng) {},
    onMapDoubleTap: (LatLng latLng) {},
    onMarkerTap: (String markerId, LatLng latLng, int zoomLevel) {},
    onMarkerClustererTap:
        (LatLng latLng, int zoomLevel, List<Marker> markers) {},
    onCustomOverlayTap: (String overlayId, LatLng latLng) {},
    onDragChangeCallback:
        (LatLng latLng, int zoomLevel, DragType dragType) {},
    onMarkerDragChangeCallback: (String markerId, LatLng latLng, int zoomLevel,
        MarkerDragType dragType) {},
    onCameraIdle: (LatLng latLng, int zoomLevel) {},
    onZoomChangeCallback: (int zoomLevel, ZoomType zoomType) {},
    onCenterChangeCallback: (LatLng latLng, int zoomLevel) {},
    onBoundsChangeCallback: (LatLngBounds bounds) {},
    onTilesLoadedCallback: (LatLng latLng, int zoomLevel) {},
    mapTypeControl: true,
    mapTypeControlPosition: ControlPosition.topRight,
    zoomControl: true,
    zoomControlPosition: ControlPosition.right,
    minLevel: 1,
    currentLevel: 3,
    maxLevel: 14,
    center: LatLng(37.5, 127.0),
    polylines: const [],
    circles: const [],
    rectangles: const [],
    polygons: const [],
    markers: const [],
    clusterer: null,
    customOverlays: const [],
  );
}

/// 로드뷰 / 정적 지도 위젯도 그대로 사용 가능해야 한다.
Widget oldStyleOtherWidgets() {
  return Column(children: [
    KakaoRoadMap(center: LatLng(37.5, 127.0)),
    KakaoStaticMap(center: LatLng(37.5, 127.0)),
  ]);
}
