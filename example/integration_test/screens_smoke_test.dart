import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/library_10_marker_clusterer_text_screen.dart';
import 'package:kakao_map_plugin_example/src/library_11_clusterer_custom_overlay_screen.dart';
import 'package:kakao_map_plugin_example/src/library_11_marker_clusterer_custom_image_screen.dart';
import 'package:kakao_map_plugin_example/src/library_1_keyword_screen.dart';
import 'package:kakao_map_plugin_example/src/library_2_keyword_list_screen.dart';
import 'package:kakao_map_plugin_example/src/library_3_category_screen.dart';
import 'package:kakao_map_plugin_example/src/library_4_category_bounds_screen.dart';
import 'package:kakao_map_plugin_example/src/library_5_address_to_coords_screen.dart';
import 'package:kakao_map_plugin_example/src/library_6_coords_to_address_screen.dart';
import 'package:kakao_map_plugin_example/src/library_7_trans_coords_screen.dart';
import 'package:kakao_map_plugin_example/src/library_8_marker_clusterer_screen.dart';
import 'package:kakao_map_plugin_example/src/library_9_marker_clusterer_click_event_screen.dart';
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
import 'package:kakao_map_plugin_example/src/map_23_coord_pixel_convert_screen.dart';
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

/// 홈 화면 메뉴에 노출되는 모든 예제 화면을 순서대로 띄웠다가 내리면서
/// Flutter 예외가 발생하지 않는지 확인하는 스모크 테스트입니다.
///
/// 실행: cd example && flutter test integration_test/screens_smoke_test.dart -d <device>
final Map<String, Widget Function()> screens = {
  'Map1DefaultScreen': () => const Map1DefaultScreen(),
  'Map2MoveScreen': () => const Map2MoveScreen(),
  'Map3LevelScreen': () => const Map3LevelScreen(),
  'Map4InfoScreen': () => const Map4InfoScreen(),
  'Map5ControllerScreen': () => const Map5ControllerScreen(),
  'Map6CustomControllerScreen': () => const Map6CustomControllerScreen(),
  'Map7DraggableScreen': () => const Map7DraggableScreen(),
  'Map8ZoomableScreen': () => const Map8ZoomableScreen(),
  'Map9TrafficScreen': () => const Map9TrafficScreen(),
  'Map10RoadViewScreen': () => const Map10RoadViewScreen(),
  'Map11TerrainScreen': () => const Map11TerrainScreen(),
  'Map12MapTypeRadioScreen': () => const Map12MapTypeRadioScreen(),
  'Map13MapTypeCheckScreen': () => const Map13MapTypeCheckScreen(),
  'Map14RegionResetScreen': () => const Map14RegionResetScreen(),
  'Map15RelayoutScreen': () => const Map15RelayoutScreen(),
  'Map16ClickListenerScreen': () => const Map16ClickListenerScreen(),
  'Map17ClickAddMarkerScreen': () => const Map17ClickAddMarkerScreen(),
  'Map18GetCenterScreen': () => const Map18GetCenterScreen(),
  'Map19ZoomChangeScreen': () => const Map19ZoomChangeScreen(),
  'Map20CenterChangeScreen': () => const Map20CenterChangeScreen(),
  'Map21BoundsChangeScreen': () => const Map21BoundsChangeScreen(),
  'Map22TilesLoadedScreen': () => const Map22TilesLoadedScreen(),
  'Map23CoordPixelConvertScreen': () => const Map23CoordPixelConvertScreen(),
  'Overlay1MarkerScreen': () => const Overlay1MarkerScreen(),
  'Overlay2MarkerDraggableScreen': () => const Overlay2MarkerDraggableScreen(),
  'Overlay3MarkerImageScreen': () => const Overlay3MarkerImageScreen(),
  'Overlay4InfoWindowScreen': () => const Overlay4InfoWindowScreen(),
  'Overlay5MarkerInfoWindowScreen': () => const Overlay5MarkerInfoWindowScreen(),
  'Overlay6MarkerClickScreen': () => const Overlay6MarkerClickScreen(),
  'Overlay10MarkersPresentationScreen': () => const Overlay10MarkersPresentationScreen(),
  'Overlay11MarkersControlScreen': () => const Overlay11MarkersControlScreen(),
  'Overlay12MarkersEvent1Screen': () => const Overlay12MarkersEvent1Screen(),
  'Overlay14MarkersImage2Screen': () => const Overlay14MarkersImage2Screen(),
  'Overlay15ShapeScreen': () => const Overlay15ShapeScreen(),
  'Overlay21CustomOverlay1Screen': () => const Overlay21CustomOverlay1Screen(),
  'Overlay22CustomOverlay2Screen': () => const Overlay22CustomOverlay2Screen(),
  'Overlay27PolygonHoleScreen': () => const Overlay27PolygonHoleScreen(),
  'RoadView1DefaultScreen': () => const RoadView1DefaultScreen(),
  'Static1DefaultScreen': () => const Static1DefaultScreen(),
  'Static2MarkerScreen': () => const Static2MarkerScreen(),
  'Static3MarkerTextScreen': () => const Static3MarkerTextScreen(),
  'Library1KeywordScreen': () => const Library1KeywordScreen(),
  'Library2KeywordListScreen': () => const Library2KeywordListScreen(),
  'Library3CategoryScreen': () => const Library3CategoryScreen(),
  'Library4CategoryBoundsScreen': () => const Library4CategoryBoundsScreen(),
  'Library5AddressToCoordsScreen': () => const Library5AddressToCoordsScreen(),
  'Library6CoordsToAddressScreen': () => const Library6CoordsToAddressScreen(),
  'Library7transCoordsScreen': () => const Library7transCoordsScreen(),
  'Library8MarkerClustererScreen': () => const Library8MarkerClustererScreen(),
  'Library9MarkerClustererClickEventScreen': () => const Library9MarkerClustererClickEventScreen(),
  'Library10MarkerClustererTextScreen': () => const Library10MarkerClustererTextScreen(),
  'Library11ClustererCustomOverlayScreen': () => const Library11ClustererCustomOverlayScreen(),
  'Library11MarkerClustererCustomImageScreen': () => const Library11MarkerClustererCustomImageScreen(),
};

Future<void> pumpFor(WidgetTester tester, Duration duration) async {
  final end = DateTime.now().add(duration);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await dotenv.load(fileName: 'assets/env/.env');
    AuthRepository.initialize(
      appKey: dotenv.env['APP_KEY'] ?? '',
      baseUrl: dotenv.env['BASE_URL'] ?? '',
    );
  });

  for (final entry in screens.entries) {
    testWidgets('예제 화면 스모크: ${entry.key}', (tester) async {
      await tester.pumpWidget(MaterialApp(home: entry.value()));
      // 지도 로드 + onMapCreated 이후 setState 경로까지 실행될 시간을 준다.
      await pumpFor(tester, const Duration(seconds: 4));
      expect(tester.takeException(), isNull,
          reason: '${entry.key} 표시 중 예외 발생');

      // 화면을 내려 dispose 경로도 검증한다.
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await pumpFor(tester, const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull,
          reason: '${entry.key} dispose 중 예외 발생');
    });
  }
}
