import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

/// Issue #60: CustomOverlay tap listener test screen
/// Tests CustomOverlay tap callback after:
/// 1. Modal dialog appears and disappears
/// 2. Navigation to another screen and back
/// 3. Stacked widgets change on top of the map
class Issue60CustomOverlayTapTestScreen extends StatefulWidget {
  const Issue60CustomOverlayTapTestScreen({Key? key, this.title})
      : super(key: key);

  final String? title;

  @override
  State<Issue60CustomOverlayTapTestScreen> createState() =>
      _Issue60CustomOverlayTapTestScreenState();
}

class _Issue60CustomOverlayTapTestScreenState
    extends State<Issue60CustomOverlayTapTestScreen> {
  KakaoMapController? mapController;
  List<CustomOverlay> customOverlays = [];
  List<String> tapLogs = [];
  bool showOverlayWidget = false;

  @override
  void initState() {
    super.initState();
    _initOverlays();
  }

  void _initOverlays() {
    customOverlays = [
      CustomOverlay(
        customOverlayId: 'overlay_1',
        latLng: LatLng(33.450701, 126.570667),
        content:
            '<div style="background-color: #4CAF50; color: white; padding: 12px 16px; border-radius: 8px; font-weight: bold; cursor: pointer; box-shadow: 0 2px 6px rgba(0,0,0,0.3);">Overlay 1 - Tap Me</div>',
        xAnchor: 0.5,
        yAnchor: 1.5,
        zIndex: 5,
      ),
      CustomOverlay(
        customOverlayId: 'overlay_2',
        latLng: LatLng(33.4520, 126.5750),
        content:
            '<div style="background-color: #2196F3; color: white; padding: 12px 16px; border-radius: 8px; font-weight: bold; cursor: pointer; box-shadow: 0 2px 6px rgba(0,0,0,0.3);">Overlay 2 - Tap Me</div>',
        xAnchor: 0.5,
        yAnchor: 1.5,
        zIndex: 5,
      ),
      CustomOverlay(
        customOverlayId: 'overlay_3',
        latLng: LatLng(33.4480, 126.5650),
        content:
            '<div style="background-color: #FF5722; color: white; padding: 12px 16px; border-radius: 8px; font-weight: bold; cursor: pointer; box-shadow: 0 2px 6px rgba(0,0,0,0.3);">Overlay 3 - Tap Me</div>',
        xAnchor: 0.5,
        yAnchor: 1.5,
        zIndex: 5,
      ),
    ];
  }

  void _addTapLog(String message) {
    setState(() {
      tapLogs.insert(0, '[${DateTime.now().toString().substring(11, 19)}] $message');
      if (tapLogs.length > 10) {
        tapLogs.removeLast();
      }
    });
  }

  void _showModal() async {
    _addTapLog('Opening modal...');
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Modal'),
        content: const Text(
            'This is a test modal. Close it and try tapping the CustomOverlay.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
    _addTapLog('Modal closed. Try tapping overlays now.');
  }

  void _showBottomSheet() async {
    _addTapLog('Opening bottom sheet...');
    await showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Test Bottom Sheet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Close this and try tapping the CustomOverlay.'),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
    _addTapLog('Bottom sheet closed. Try tapping overlays now.');
  }

  void _navigateToAnotherScreen() async {
    _addTapLog('Navigating to another screen...');
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Another Screen')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('This is another screen.'),
                const SizedBox(height: 16),
                const Text('Go back and try tapping the CustomOverlay.'),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    _addTapLog('Returned from another screen. Try tapping overlays now.');
  }

  void _toggleOverlayWidget() {
    setState(() {
      showOverlayWidget = !showOverlayWidget;
    });
    _addTapLog(showOverlayWidget
        ? 'Overlay widget shown. Try tapping map overlays.'
        : 'Overlay widget hidden. Try tapping map overlays.');
  }

  void _refreshOverlays() {
    _addTapLog('Refreshing overlays...');
    setState(() {
      // Re-trigger didUpdateWidget by creating new overlay instances
      customOverlays = customOverlays
          .map((o) => CustomOverlay(
                customOverlayId: o.customOverlayId,
                latLng: o.latLng,
                content: o.content,
                xAnchor: o.xAnchor,
                yAnchor: o.yAnchor,
                zIndex: o.zIndex,
              ))
          .toList();
    });
    _addTapLog('Overlays refreshed.');
  }

  void _callRelayout() {
    if (mapController != null) {
      _addTapLog('Calling relayout...');
      mapController!.relayout();
      _addTapLog('Relayout called. Try tapping overlays now.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Issue #60 Test'),
      ),
      body: Column(
        children: [
          // Map section
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                KakaoMap(
                  onMapCreated: (controller) {
                    mapController = controller;
                    _addTapLog('Map created');
                  },
                  customOverlays: customOverlays,
                  onCustomOverlayTap: (String id, LatLng latLng) {
                    _addTapLog('CustomOverlay TAPPED: $id');
                    debugPrint('***** [callback] CustomOverlay tapped: $id / $latLng');
                  },
                  onMapTap: (latLng) {
                    _addTapLog('Map tapped at: ${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}');
                  },
                  center: LatLng(33.450701, 126.570667),
                ),
                // Overlay widget to test stacked widget changes
                if (showOverlayWidget)
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Text(
                        'This is an overlay widget on top of the map.\nTap the CustomOverlay buttons below.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Log section
          Container(
            height: 120,
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tap Logs:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => setState(() => tapLogs.clear()),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: tapLogs.length,
                    itemBuilder: (context, index) => Text(
                      tapLogs[index],
                      style: TextStyle(
                        fontSize: 12,
                        color: tapLogs[index].contains('TAPPED')
                            ? Colors.green[700]
                            : Colors.black87,
                        fontWeight: tapLogs[index].contains('TAPPED')
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Test buttons section
          Container(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _showModal,
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('Show Modal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showBottomSheet,
                  icon: const Icon(Icons.keyboard_arrow_up, size: 18),
                  label: const Text('Bottom Sheet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _navigateToAnotherScreen,
                  icon: const Icon(Icons.navigation, size: 18),
                  label: const Text('Navigate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _toggleOverlayWidget,
                  icon: Icon(
                    showOverlayWidget ? Icons.visibility_off : Icons.visibility,
                    size: 18,
                  ),
                  label: Text(showOverlayWidget ? 'Hide Widget' : 'Show Widget'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _refreshOverlays,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _callRelayout,
                  icon: const Icon(Icons.crop_free, size: 18),
                  label: const Text('Relayout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
