import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// Coordinate to Pixel Conversion Example
/// This example demonstrates how to convert between geographic coordinates (LatLng)
/// and pixel positions on the map screen.
class Map23CoordPixelConvertScreen extends StatefulWidget {
  const Map23CoordPixelConvertScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Map23CoordPixelConvertScreen> createState() =>
      _Map23CoordPixelConvertScreenState();
}

class _Map23CoordPixelConvertScreenState
    extends State<Map23CoordPixelConvertScreen> {
  late KakaoMapController mapController;

  String coordToPixelResult = '';
  String pixelToCoordResult = '';
  String clickedCoordResult = '';

  LatLng? lastClickedLatLng;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: Stack(
        children: [
          KakaoMap(
            onMapCreated: ((controller) async {
              mapController = controller;
            }),
            currentLevel: 3,
            center: LatLng(37.5665, 126.9780), // Seoul City Hall
            onMapTap: (latLng) async {
              lastClickedLatLng = latLng;
              clickedCoordResult =
                  'Clicked: (${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)})';

              // Convert clicked coordinate to pixel
              final pixel = await mapController.coordToPixel(latLng);
              coordToPixelResult =
                  'Coord to Pixel: (${pixel.x.toStringAsFixed(2)}, ${pixel.y.toStringAsFixed(2)})';

              // Convert pixel back to coordinate
              final convertedLatLng = await mapController.pixelToCoord(pixel);
              pixelToCoordResult =
                  'Pixel to Coord: (${convertedLatLng.latitude.toStringAsFixed(6)}, ${convertedLatLng.longitude.toStringAsFixed(6)})';

              setState(() {});
            },
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Tap on the map to convert coordinates',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    clickedCoordResult.isEmpty
                        ? 'Waiting for tap...'
                        : clickedCoordResult,
                    style: const TextStyle(fontSize: 12),
                  ),
                  if (coordToPixelResult.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      coordToPixelResult,
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ],
                  if (pixelToCoordResult.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      pixelToCoordResult,
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Get center and convert to pixel
                      final center = await mapController.getCenter();
                      final pixel = await mapController.coordToPixel(center);

                      clickedCoordResult =
                          'Center: (${center.latitude.toStringAsFixed(6)}, ${center.longitude.toStringAsFixed(6)})';
                      coordToPixelResult =
                          'Center Pixel: (${pixel.x.toStringAsFixed(2)}, ${pixel.y.toStringAsFixed(2)})';

                      // Convert back
                      final convertedLatLng =
                          await mapController.pixelToCoord(pixel);
                      pixelToCoordResult =
                          'Back to Coord: (${convertedLatLng.latitude.toStringAsFixed(6)}, ${convertedLatLng.longitude.toStringAsFixed(6)})';

                      setState(() {});
                    },
                    child: const Text('Convert Center'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Convert a fixed pixel position (center of screen)
                      // Using Point(0, 0) which represents the top-left corner
                      final topLeftPixel = Point(0, 0);
                      final topLeftCoord =
                          await mapController.pixelToCoord(topLeftPixel);

                      clickedCoordResult = 'Pixel (0, 0) = Top-Left Corner';
                      coordToPixelResult = '';
                      pixelToCoordResult =
                          'Top-Left Coord: (${topLeftCoord.latitude.toStringAsFixed(6)}, ${topLeftCoord.longitude.toStringAsFixed(6)})';

                      setState(() {});
                    },
                    child: const Text('Get Top-Left'),
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
