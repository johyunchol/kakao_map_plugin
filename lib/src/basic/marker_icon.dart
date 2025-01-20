part of '../../kakao_map_plugin.dart';

class MarkerIcon {
  final String imageSrc;

  MarkerIcon._(this.imageSrc);

  /// Create a MarkerIcon from an asset image
  static Future<MarkerIcon> fromAsset(String assetName) async {
    ByteData data = await rootBundle.load(assetName);
    List<int> bytes = data.buffer.asUint8List();
    String base64String = base64Encode(bytes);
    return MarkerIcon._(base64String);
  }

  /// Create a MarkerIcon from a network image
  static MarkerIcon fromNetwork(String url) {
    return MarkerIcon._(url);
  }

  /// Create a MarkerIcon from a Widget
  static Future<MarkerIcon> fromWidget(Widget widget) async {
    final Completer<Size> sizeCompleter = Completer<Size>();

    final GlobalKey boundaryKey = GlobalKey();

    // Create a widget to measure its size
    Widget measuringWidget = MaterialApp(
      home: Scaffold(
        body: Center(
          child: RepaintBoundary(
            key: boundaryKey,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (!sizeCompleter.isCompleted) {
                  sizeCompleter.complete(
                      Size(constraints.maxWidth, constraints.maxHeight));
                }
                return widget;
              },
            ),
          ),
        ),
      ),
    );

    // Create a RenderBox with the measured size
    final Size widgetSize = await _getWidgetSize(measuringWidget);
    final RenderRepaintBoundary boundary =
        boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    final RenderBox renderBox =
        _createRenderBox(widget, widgetSize.width, widgetSize.height, boundary);
    await _ensureRendered(renderBox);

    final ui.Image image = await boundary.toImage(
        pixelRatio:
            ui.PlatformDispatcher.instance.views.first.devicePixelRatio);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();
    final String base64String = base64Encode(pngBytes);

    return MarkerIcon._(base64String);
  }

  static Future<Size> _getWidgetSize(Widget widget) async {
    final Completer<Size> completer = Completer<Size>();

    runApp(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final RenderBox box = context.findRenderObject() as RenderBox;
                completer.complete(box.size);
              });
              return widget;
            },
          ),
        ),
      ),
    );

    return completer.future;
  }

  static RenderBox _createRenderBox(Widget widget, double width, double height,
      RenderRepaintBoundary boundary) {
    final RenderBox box = RenderRepaintBoundary()
      ..child = RenderPositionedBox(
        alignment: Alignment.center,
        child: RenderConstrainedBox(
          additionalConstraints: BoxConstraints.tight(Size(width, height)),
          child: boundary,
        ),
      );

    final pipelineOwner = PipelineOwner();
    box.attach(pipelineOwner);
    return box;
  }

  static Future<void> _ensureRendered(RenderBox box) async {
    final Completer<void> completer = Completer();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final RenderView renderView = RenderView(
        view: PlatformDispatcher.instance.views.first,
        child: box,
        configuration: const ViewConfiguration(
          devicePixelRatio: 1.0,
        ),
      );
      renderView.prepareInitialFrame();
      completer.complete();
    });

    return completer.future;
  }
}
