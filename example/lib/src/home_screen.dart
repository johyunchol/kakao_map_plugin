import 'package:flutter/material.dart';
import 'package:kakao_map_plugin_example/src/map_10_roadview_screen.dart';
import 'package:kakao_map_plugin_example/src/map_11_terrain_screen.dart';
import 'package:kakao_map_plugin_example/src/map_12_map_type_radio_screen.dart';
import 'package:kakao_map_plugin_example/src/map_13_map_type_check_screen.dart';
import 'package:kakao_map_plugin_example/src/map_14_region_reset_screen.dart';
import 'package:kakao_map_plugin_example/src/map_15_relayout_screen.dart.dart';
import 'package:kakao_map_plugin_example/src/map_16_click_listener_screen.dart';
import 'package:kakao_map_plugin_example/src/map_17_click_add_marker_screen.dart';
import 'package:kakao_map_plugin_example/src/map_18_get_center_screen.dart';
import 'package:kakao_map_plugin_example/src/map_19_zoom_change_screen.dart';
import 'package:kakao_map_plugin_example/src/map_1_default_screen.dart';
import 'package:kakao_map_plugin_example/src/map_20_center_change_screen.dart';
import 'package:kakao_map_plugin_example/src/map_21_bounds_change_screen.dart';
import 'package:kakao_map_plugin_example/src/map_22_tiles_loaded_screen.dart';
import 'package:kakao_map_plugin_example/src/map_2_move_screen.dart';
import 'package:kakao_map_plugin_example/src/map_3_level_screen.dart';
import 'package:kakao_map_plugin_example/src/map_4_info_screen.dart';
import 'package:kakao_map_plugin_example/src/map_5_controller_screen.dart';
import 'package:kakao_map_plugin_example/src/map_6_custom_controller_screen.dart';
import 'package:kakao_map_plugin_example/src/map_7_draggable_screen.dart';
import 'package:kakao_map_plugin_example/src/map_8_zoomable_screen.dart';
import 'package:kakao_map_plugin_example/src/map_9_traffic_screen.dart';
import 'package:kakao_map_plugin_example/src/overlay_10_markers_presentation_screen.dart';
import 'package:kakao_map_plugin_example/src/overlay_11_markers_control_screen.dart';
import 'package:kakao_map_plugin_example/src/overlay_12_markers_event1_screen.dart';
import 'package:kakao_map_plugin_example/src/overlay_14_markers_image_screen.dart';
import 'package:kakao_map_plugin_example/src/overlay_15_shape_screen.dart';
import 'package:kakao_map_plugin_example/src/overlay_1_marker_screen.dart';
import 'package:kakao_map_plugin_example/src/overlay_21_custom_overlay1_screen.dart';
import 'package:kakao_map_plugin_example/src/overlay_22_custom_overlay2_screen.dart';
import 'package:kakao_map_plugin_example/src/overlay_27_polygon_hole.dart';
import 'package:kakao_map_plugin_example/src/overlay_2_marker_draggable_screen.dart';
import 'package:kakao_map_plugin_example/src/overlay_3_marker_image_screen.dart';
import 'package:kakao_map_plugin_example/src/overlay_4_infowindow_screen.dart';
import 'package:kakao_map_plugin_example/src/overlay_5_marker_infowindow_screen.dart';
import 'package:kakao_map_plugin_example/src/overlay_6_marker_click_screen.dart';
import 'package:kakao_map_plugin_example/src/roadview_1_default_screen.dart';
import 'package:kakao_map_plugin_example/src/static_1_default_screen.dart';
import 'package:kakao_map_plugin_example/src/static_2_marker_screen.dart';
import 'package:kakao_map_plugin_example/src/static_3_marker_text_screen.dart';

String selectedTitle = '';

class MenuItem {
  final String title;
  final Widget newPage;

  MenuItem({required this.title, required this.newPage});
}

class MenuGroup {
  final String name;
  final List<MenuItem> items;

  MenuGroup({required this.name, required this.items});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final List<MenuGroup> group = [
    MenuGroup(
      name: '지도',
      items: [
        MenuItem(title: '지도 생성하기', newPage: const Map1DefaultScreen()),
        MenuItem(title: '지도 이동시키기', newPage: const Map2MoveScreen()),
        MenuItem(title: '지도 레벨 바꾸기', newPage: const Map3LevelScreen()),
        MenuItem(title: '지도 정보 얻어오기', newPage: const Map4InfoScreen()),
        MenuItem(title: '지도에 컨트롤 올리기', newPage: const Map5ControllerScreen()),
        MenuItem(
            title: '지도에 사용자 컨트롤 올리기',
            newPage: const Map6CustomControllerScreen()),
        MenuItem(title: '지도 이동 막기', newPage: const Map7DraggableScreen()),
        MenuItem(title: '지도 확대 축소 막기', newPage: const Map8ZoomableScreen()),
        MenuItem(title: '지도에 교통정보 표시하기', newPage: const Map9TrafficScreen()),
        MenuItem(
            title: '지도에 로드뷰 도로 표시하기', newPage: const Map10RoadViewScreen()),
        MenuItem(title: '지도에 지형도 표시하기', newPage: const Map11TerrainScreen()),
        MenuItem(title: '지도 타입 바꾸기1', newPage: const Map12MapTypeRadioScreen()),
        MenuItem(title: '지도 타입 바꾸기2', newPage: const Map13MapTypeCheckScreen()),
        MenuItem(
            title: '지도 범위 재설정 하기', newPage: const Map14RegionResetScreen()),
        MenuItem(
            title: '지도 영역 크기 동적 변경하기', newPage: const Map15RelayoutScreen()),
        MenuItem(
            title: '클릭 이벤트 등록하기', newPage: const Map16ClickListenerScreen()),
        MenuItem(
            title: '클릭한 위치에 마커 표시하기',
            newPage: const Map17ClickAddMarkerScreen()),
        MenuItem(title: '이동 이벤트 등록하기', newPage: const Map18GetCenterScreen()),
        MenuItem(
            title: '확대, 축소 이벤트 등록하기', newPage: const Map19ZoomChangeScreen()),
        MenuItem(
            title: '중심좌표 변경 이벤트 등록하기',
            newPage: const Map20CenterChangeScreen()),
        MenuItem(
            title: '영역 변경 이벤트 등록하기', newPage: const Map21BoundsChangeScreen()),
        MenuItem(
            title: '타일로드 이벤트 등록하기', newPage: const Map22TilesLoadedScreen()),
        // MenuItem(title: '커스텀 타일셋1', newPage: const Map1DefaultScreen()),
        // MenuItem(title: '커스텀 타일셋2', newPage: const Map1DefaultScreen()),
      ],
    ),
    MenuGroup(name: '오버레이', items: [
      MenuItem(title: '마커 생성하기', newPage: const Overlay1MarkerScreen()),
      MenuItem(
          title: '드래그 가능한 마커 생성하기',
          newPage: const Overlay2MarkerDraggableScreen()),
      MenuItem(
          title: '다른 이미지로 마커 생성하기', newPage: const Overlay3MarkerImageScreen()),
      MenuItem(title: '인포윈도우 생성하기', newPage: const Overlay4InfoWindowScreen()),
      MenuItem(
          title: '마커에 인포윈도우 표시하기',
          newPage: const Overlay5MarkerInfoWindowScreen()),
      MenuItem(
          title: '마커에 클릭 이벤트 등록하기', newPage: const Overlay6MarkerClickScreen()),
      // MenuItem(title: '마커에 마우스 이벤트 등록하기', newPage: const Overlay7MarkerMouseEventScreen()),
      // MenuItem(title: 'draggable 마커 이벤트 적용하기', newPage: const Overlay8MarkerDraggableEventScreen()),
      // MenuItem(title: 'geolocation으로 마커 표시하기', newPage: const Overlay9MarkerGeolocatorScreen()),
      MenuItem(
          title: '여러개 마커 표시하기',
          newPage: const Overlay10MarkersPresentationScreen()),
      MenuItem(
          title: '여러개 마커 제어하기', newPage: const Overlay11MarkersControlScreen()),
      MenuItem(
          title: '여러개 마커에 이벤트 등록하기1',
          newPage: const Overlay12MarkersEvent1Screen()),
      // MenuItem(title: '여러개 마커에 이벤트 등록하기2', newPage: const Overlay13MarkersEvent2Screen()),
      MenuItem(
          title: '다양한 이미지 마커 표시하기',
          newPage: const Overlay14MarkersImage2Screen()),
      MenuItem(
          title: '원, 선, 사각형, 다각형 표시하기', newPage: const Overlay15ShapeScreen()),
      // MenuItem(title: '선의 거리 계산하기', newPage: const Overlay16LineDistanceScreen()),
      // MenuItem(title: '다각형의 면적 계산하기', newPage: const Overlay17PolygonAreaScreen()),
      // MenuItem(title: '다각형에 이벤트 등록하기1', newPage: const Overlay18PolygonEvent1Screen()),
      // MenuItem(title: '다각형에 이벤트 등록하기2', newPage: const Overlay19PolygonEvent2Screen()),
      // MenuItem(title: '원의 반경 계산하기', newPage: const Overlay20CircleRadiusScreen()),
      MenuItem(
          title: '커스텀 오버레이 생성하기1',
          newPage: const Overlay21CustomOverlay1Screen()),
      MenuItem(
          title: '커스텀 오버레이 생성하기2',
          newPage: const Overlay22CustomOverlay2Screen()),
      // MenuItem(title: '닫기가 가능한 커스텀 오버레이', newPage: const Overlay23RemovableCustomOverlayScreen()),
      // MenuItem(title: '이미지 마커와 커스텀 오버레이', newPage: const Overlay24ImageMarkerCustomOverlayScreen()),
      // MenuItem(title: '커스텀오버레이를 드래그 하기', newPage: const Overlay25DragCustomOverlayScreen()),
      // MenuItem(title: '지도 영역 밖의 마커위치 추적하기', newPage: const Overlay26MarkerTrackerScreen()),
      MenuItem(
          title: '구멍난 다각형 만들기', newPage: const Overlay27PolygonHoleScreen()),
    ]),
    MenuGroup(name: '로드뷰', items: [
      MenuItem(title: '로드뷰 생성하기', newPage: const RoadView1DefaultScreen()),
      // MenuItem(title: '로드뷰 도로를 이용하여 로드뷰 생성하기', newPage: const RoadView2DefaultScreen()),
      // MenuItem(title: '동동이를 이용하여 로드뷰와 지도 연동하기', newPage: const RoadView3MoveScreen()),
      // MenuItem(title: '로드뷰에 마커와 인포윈도우 올리기', newPage: const RoadView4Overlay1Screen()),
      // MenuItem(title: '마커의 고도와 반경 조절하기', newPage: const RoadView5Overlay2Screen()),
      // MenuItem(title: '로드뷰에 커스텀오버레이 올리기', newPage: const RoadView6CustomOverlayScreen()),
      // MenuItem(title: '로드뷰에 이미지 올리기', newPage: const RoadView7ImageScreen()),
    ]),
    MenuGroup(name: '정적지도', items: [
      MenuItem(title: '이미지 지도 생성하기', newPage: const Static1DefaultScreen()),
      MenuItem(title: '이미지 지도에 마커 표시하기', newPage: const Static2MarkerScreen()),
      MenuItem(title: '마커와 텍스트 표시하기', newPage: const Static3MarkerTextScreen()),
    ]),
    // MenuGroup(name: '라이브러리', items: [
    //   MenuItem(title: '키워드로 장소검색하기', newPage: const Library1KeywordScreen()),
    //   MenuItem(title: '키워드로 장소검색하고 목록으로 표출하기', newPage: const Library2KeywordListScreen()),
    //   MenuItem(title: '카테고리로 장소 검색하기', newPage: const Library3CategoryScreen()),
    //   MenuItem(title: '카테고리별 장소 검색하기', newPage: const Library4CategoryBoundsScreen()),
    //   MenuItem(title: '주소로 장소 표시하기', newPage: const Library5AddressToCoordsScreen()),
    //   MenuItem(title: '좌표로 주소를 얻어내기', newPage: const Library6CoordsToAddressScreen()),
    //   MenuItem(title: 'WTM 좌표를 WGS84 좌표로 변환하기', newPage: const Library7transCoordsScreen()),
    //   MenuItem(title: '마커 클러스터러 사용하기', newPage: const Library8MarkerClustererScreen()),
    //   MenuItem(title: '마커 클러스터러에 클릭이벤트 추가하기', newPage: const Library9MarkerClustererClickEventScreen()),
    //   MenuItem(title: '클러스터 마커에 텍스트 표시하기', newPage: const Library10MarkerClustererTextScreen()),
    //   MenuItem(title: 'Drawing Library 사용하기', newPage: const Library11DrawingLibraryScreen()),
    //   MenuItem(title: 'Drawing Library 에서 데이터 얻기', newPage: const Library12DrawingGetDataScreen()),
    //   MenuItem(title: 'Toolbox 사용하기', newPage: const Library13DrawingToolboxScreen()),
    //   MenuItem(title: 'Drawing undo, redo', newPage: const Library14DrawingUntoRedoScreen()),
    // ]),
  ];

  late PageController _pageController;
  late TabController _tabController;
  int _page = 0;

  @override
  void initState() {
    _pageController = PageController();
    _tabController = TabController(length: group.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('카카오맵 샘플'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (value) {
            _page = value;
            _pageController.animateToPage(_page,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease);
          },
          tabs: group.map((e) => Tab(text: e.name)).toList(),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (value) {
          _page = value;
          _tabController.animateTo(_page,
              duration: const Duration(milliseconds: 300), curve: Curves.ease);
        },
        children: group
            .map(
              (groupItem) => ListView.separated(
                itemBuilder: (context, index) {
                  final item = groupItem.items[index];
                  return InkWell(
                    onTap: () {
                      selectedTitle = item.title;
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => item.newPage));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 24.0),
                      child: Text(groupItem.items[index].title),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider(height: 1);
                },
                itemCount: groupItem.items.length,
              ),
            )
            .toList(),
      ),
    );
  }
}
