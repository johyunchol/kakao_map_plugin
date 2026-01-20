import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// Issue #30 Test: Quote escaping test for CustomOverlay and Marker
/// Tests multiline content, single quotes, double quotes in HTML attributes
class Issue30EscapeTestScreen extends StatefulWidget {
  const Issue30EscapeTestScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Issue30EscapeTestScreen> createState() =>
      _Issue30EscapeTestScreenState();
}

class _Issue30EscapeTestScreenState extends State<Issue30EscapeTestScreen> {
  late KakaoMapController mapController;

  List<CustomOverlay> customOverlays = [];
  List<Marker> markers = [];
  List<Polyline> polylines = [];

  @override
  void initState() {
    super.initState();
    _initOverlays();
  }

  void _initOverlays() {
    // Test 1: CustomOverlay with multiline content (Issue #30 main case)
    final multilineOverlay = CustomOverlay(
      customOverlayId: 'multiline_overlay',
      latLng: LatLng(33.450701, 126.570667),
      content: '''<div style="background-color: white; padding: 12px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0,0,0,0.3);">
  <p style="margin: 0; font-weight: bold;">Multiline Test</p>
  <p style="margin: 4px 0 0 0; font-size: 12px;">Line 1</p>
  <p style="margin: 4px 0 0 0; font-size: 12px;">Line 2</p>
</div>''',
      xAnchor: 0.5,
      yAnchor: 1.2,
      zIndex: 5,
    );
    customOverlays.add(multilineOverlay);

    // Test 2: CustomOverlay with single quotes in content
    final singleQuoteOverlay = CustomOverlay(
      customOverlayId: 'single_quote_overlay',
      latLng: LatLng(33.4520, 126.5680),
      content:
          '<div style="background-color: #fff; padding: 8px; border-radius: 8px;">It\'s a test with \'single\' quotes</div>',
      xAnchor: 0.5,
      yAnchor: 1.2,
      zIndex: 5,
    );
    customOverlays.add(singleQuoteOverlay);

    // Test 3: CustomOverlay with double quotes in HTML attributes
    final doubleQuoteOverlay = CustomOverlay(
      customOverlayId: 'double_quote_overlay',
      latLng: LatLng(33.4490, 126.5720),
      content:
          '<div style="background-color: #e3f2fd; padding: 8px; border-radius: 8px;"><a href="https://example.com" target="_blank">Link with "quotes"</a></div>',
      xAnchor: 0.5,
      yAnchor: 1.2,
      zIndex: 5,
    );
    customOverlays.add(doubleQuoteOverlay);

    // Test 4: CustomOverlay with mixed quotes and special characters
    final mixedOverlay = CustomOverlay(
      customOverlayId: 'mixed_overlay',
      latLng: LatLng(33.4530, 126.5750),
      content:
          '<div style="background-color: #fff3e0; padding: 8px; border-radius: 8px;">Mixed: "double" & \'single\' & backslash \\ test</div>',
      xAnchor: 0.5,
      yAnchor: 1.2,
      zIndex: 5,
    );
    customOverlays.add(mixedOverlay);

    // Test 5: Marker with infoWindowContent containing quotes
    final markerWithQuotes = Marker(
      markerId: 'marker_quotes',
      latLng: LatLng(33.4480, 126.5650),
      infoWindowContent:
          '<div style="padding: 5px;">Marker\'s "info" window</div>',
      infoWindowFirstShow: true,
    );
    markers.add(markerWithQuotes);

    // Test 6: Marker with multiline infoWindowContent
    final markerMultiline = Marker(
      markerId: 'marker_multiline',
      latLng: LatLng(33.4510, 126.5620),
      infoWindowContent: '''<div style="padding: 8px;">
  <strong>Multiline Info</strong>
  <br/>Line 1
  <br/>Line 2
</div>''',
      infoWindowFirstShow: true,
    );
    markers.add(markerMultiline);

    // Test 7: Polyline with initial values (reported issue case)
    final polyline = Polyline(
      polylineId: 'test_polyline',
      points: [
        LatLng(33.450701, 126.570667),
        LatLng(33.4520, 126.5680),
        LatLng(33.4530, 126.5750),
      ],
      strokeWidth: 5,
      strokeColor: Colors.blue,
      strokeOpacity: 0.8,
    );
    polylines.add(polyline);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: KakaoMap(
              onMapCreated: ((controller) async {
                mapController = controller;
                setState(() {});
              }),
              customOverlays: customOverlays,
              markers: markers,
              polylines: polylines,
              onCustomOverlayTap: (String id, LatLng latLng) {
                debugPrint('***** [CustomOverlay Tap] id: $id, latLng: $latLng');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('CustomOverlay tapped: $id')),
                );
              },
              onMarkerTap: (String markerId, LatLng latLng, int zoomLevel) {
                debugPrint(
                    '***** [Marker Tap] markerId: $markerId, latLng: $latLng');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Marker tapped: $markerId')),
                );
              },
              center: LatLng(33.450701, 126.570667),
              currentLevel: 5,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Issue #30 Test Cases:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text('1. Multiline CustomOverlay content'),
                Text('2. Single quotes in CustomOverlay'),
                Text('3. Double quotes in HTML attributes'),
                Text('4. Mixed quotes and backslash'),
                Text('5. Marker with quotes in infoWindow'),
                Text('6. Marker with multiline infoWindow'),
                Text('7. Polyline with initial values'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
