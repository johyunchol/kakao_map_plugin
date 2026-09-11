import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' show Color, ImageByteFormat;
import 'dart:convert';

import 'package:flutter/services.dart';

import 'constants/image_type.dart';
import 'hex_color.dart';

/// 마커에 사용할 커스텀 아이콘을 나타내는 클래스입니다.
///
/// 마커 아이콘은 에셋 이미지 또는 네트워크 URL로부터 생성할 수 있습니다.
/// 에셋 이미지는 base64로 인코딩되어 저장되며, 네트워크 이미지는 URL이 저장됩니다.
///
/// 예시:
/// ```dart
/// // 에셋 이미지 사용
/// final assetIcon = await MarkerIcon.fromAsset('assets/marker.png');
///
/// // 네트워크 이미지 사용
/// final networkIcon = MarkerIcon.network('https://example.com/marker.png');
/// ```
class MarkerIcon {
  /// 이미지 소스입니다.
  ///
  /// 에셋 이미지의 경우 base64로 인코딩된 문자열이며,
  /// 네트워크 이미지의 경우 URL 문자열입니다.
  final String imageSrc;

  /// 이미지 타입입니다.
  ///
  /// [ImageType.file]은 에셋 이미지를, [ImageType.url]은 네트워크 이미지를 나타냅니다.
  /// 기본값은 [ImageType.file]입니다.
  ImageType? imageType = ImageType.file;

  /// 에셋 이미지의 base64 인코딩 결과를 캐싱하는 저장소입니다.
  ///
  /// 동일한 [assetName]에 대해 [fromAsset]이 반복 호출되어도
  /// 매번 이미지를 다시 읽고 인코딩하지 않도록 합니다.
  static final Map<String, String> _assetCache = {};

  /// 마커 아이콘의 내부 생성자입니다.
  ///
  /// 이 생성자는 직접 호출하지 않고, [fromAsset] 또는 [network] 팩토리 메서드를 사용하세요.
  MarkerIcon._(this.imageSrc, {this.imageType});

  /// 에셋 이미지로부터 마커 아이콘을 생성합니다.
  ///
  /// [assetName]은 pubspec.yaml에 정의된 에셋 경로여야 합니다.
  /// 이미지는 base64로 인코딩되어 저장됩니다.
  ///
  /// 동일한 [assetName]으로 다시 호출하면 캐시된 결과를 반환하여
  /// 불필요한 파일 읽기 및 인코딩을 방지합니다.
  ///
  /// 예시:
  /// ```dart
  /// final icon = await MarkerIcon.fromAsset('assets/images/marker.png');
  ///
  /// final marker = Marker(
  ///   markerId: 'marker_1',
  ///   latLng: LatLng(37.5665, 126.9780),
  ///   icon: icon,
  /// );
  /// ```
  ///
  /// Returns: base64로 인코딩된 이미지를 포함하는 [MarkerIcon] 인스턴스
  static Future<MarkerIcon> fromAsset(String assetName) async {
    // base64 문자열만 캐시하고 인스턴스는 매번 새로 만듭니다.
    // (imageType 이 가변 필드이므로 인스턴스 공유 시 호출자 간 간섭이 생길 수 있음)
    var base64String = _assetCache[assetName];
    if (base64String == null) {
      final ByteData data = await rootBundle.load(assetName);
      base64String = base64Encode(data.buffer.asUint8List());
      _assetCache[assetName] = base64String;
    }
    return MarkerIcon._(base64String, imageType: ImageType.file);
  }

  /// 이미지 바이트(PNG 등)로부터 마커 아이콘을 생성합니다.
  ///
  /// 네트워크나 파일에서 직접 읽은 바이트를 사용할 때 유용합니다.
  ///
  /// 예시:
  /// ```dart
  /// final bytes = await File('marker.png').readAsBytes();
  /// final icon = MarkerIcon.fromBytes(bytes);
  /// ```
  static MarkerIcon fromBytes(List<int> bytes) =>
      MarkerIcon._(base64Encode(bytes), imageType: ImageType.file);

  /// base64 로 인코딩된 이미지 문자열로부터 마커 아이콘을 생성합니다.
  ///
  /// [base64]는 data URL 접두사(`data:image/png;base64,`) 없이 순수 base64 문자열이어야 합니다.
  static MarkerIcon fromBase64(String base64) =>
      MarkerIcon._(base64, imageType: ImageType.file);

  /// 네트워크 URL로부터 마커 아이콘을 동기적으로 생성합니다. (권장)
  ///
  /// [url]은 인터넷에서 접근 가능한 이미지 URL이어야 합니다.
  /// 이미지는 런타임에 로드됩니다.
  ///
  /// 예시:
  /// ```dart
  /// final icon = MarkerIcon.network(
  ///   'https://example.com/images/marker.png',
  /// );
  ///
  /// final marker = Marker(
  ///   markerId: 'marker_1',
  ///   latLng: LatLng(37.5665, 126.9780),
  ///   icon: icon,
  /// );
  /// ```
  ///
  /// Returns: URL을 포함하는 [MarkerIcon] 인스턴스
  static MarkerIcon network(String url) {
    return MarkerIcon._(url, imageType: ImageType.url);
  }

  /// 네트워크 URL로부터 마커 아이콘을 생성합니다.
  ///
  /// 네트워크 요청이 발생하지 않으므로 동기 버전인 [network]를 사용하는 것을 권장합니다.
  ///
  /// [url]은 인터넷에서 접근 가능한 이미지 URL이어야 합니다.
  /// 이미지는 런타임에 로드됩니다.
  ///
  /// 예시:
  /// ```dart
  /// final icon = await MarkerIcon.fromNetwork(
  ///   'https://example.com/images/marker.png',
  /// );
  ///
  /// final marker = Marker(
  ///   markerId: 'marker_1',
  ///   latLng: LatLng(37.5665, 126.9780),
  ///   icon: icon,
  /// );
  /// ```
  ///
  /// Returns: URL을 포함하는 [MarkerIcon] 인스턴스
  static Future<MarkerIcon> fromNetwork(String url) =>
      Future.value(network(url));

  /// 색만 바꿔 쓰는 기본 핀 모양 아이콘입니다. 네트워크·에셋 없이 바로 씁니다.
  ///
  /// [size] 는 아이콘의 세로 크기(px)이며 가로는 그 0.7배입니다. 핀 끝이 좌표를
  /// 가리키도록 마커에는 `width: size * 0.7, height: size, offsetX: size * 0.35,
  /// offsetY: size` 를 함께 지정하세요.
  ///
  /// 예시:
  /// ```dart
  /// Marker(
  ///   markerId: 'm1',
  ///   latLng: latLng,
  ///   icon: MarkerIcon.pin(color: Colors.red),
  ///   width: 28, height: 40, offsetX: 14, offsetY: 40,
  /// )
  /// ```
  static MarkerIcon pin({
    required Color color,
    Color? borderColor,
    Color dotColor = const Color(0xFFFFFFFF),
    double size = 40,
  }) {
    final fill = _css(color);
    final stroke = borderColor == null ? 'none' : _css(borderColor);
    final width = (size * 0.7).round();
    final height = size.round();
    // 24x34 뷰박스의 핀. 끝점 (12,34) 가 좌표에 놓입니다.
    final svg =
        '<svg xmlns="http://www.w3.org/2000/svg" width="$width" height="$height" viewBox="0 0 24 34">'
        '<path d="M12 1C6 1 1.5 5.6 1.5 11.4c0 7.7 9 20.4 9.6 21.2a1.2 1.2 0 0 0 1.8 0c.6-.8 9.6-13.5 9.6-21.2C22.5 5.6 18 1 12 1z" '
        'fill="$fill" stroke="$stroke" stroke-width="1.2"/>'
        '<circle cx="12" cy="11.5" r="4.2" fill="${_css(dotColor)}"/></svg>';
    return MarkerIcon._(
      'data:image/svg+xml;charset=utf-8,${Uri.encodeComponent(svg)}',
      imageType: ImageType.url,
    );
  }

  /// Flutter 위젯을 그대로 그려 마커 아이콘으로 씁니다.
  ///
  /// 위젯을 화면 밖에서 한 번 렌더링해 PNG 로 만들므로 배지, 프로필 사진, 가격표
  /// 같은 "앱 스타일" 마커를 HTML 없이 만들 수 있습니다. 결과는 정적 이미지라
  /// 위젯 안의 상호작용은 동작하지 않습니다.
  ///
  /// [logicalSize] 는 위젯의 논리 픽셀 크기이고, 마커에는 같은 값을
  /// `width/height` 로 넘기세요(이미지는 [pixelRatio] 배로 렌더링됩니다).
  /// 이미지가 포함된 위젯은 로드가 끝나도록 [delay] 를 주거나 미리 캐시하세요.
  ///
  /// 예시:
  /// ```dart
  /// final icon = await MarkerIcon.fromWidget(
  ///   Container(
  ///     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  ///     decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(16)),
  ///     child: const Text('12,000원', style: TextStyle(color: Colors.white, fontSize: 13)),
  ///   ),
  ///   logicalSize: const Size(90, 32),
  /// );
  /// ```
  static Future<MarkerIcon> fromWidget(
    Widget widget, {
    required Size logicalSize,
    double pixelRatio = 3.0,
    Duration delay = Duration.zero,
    TextDirection textDirection = TextDirection.ltr,
  }) async {
    final binding = WidgetsFlutterBinding.ensureInitialized();
    final view = binding.platformDispatcher.views.first;

    final repaintBoundary = RenderRepaintBoundary();
    final renderView = RenderView(
      view: view,
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints.tight(logicalSize),
        physicalConstraints: BoxConstraints.tight(logicalSize * pixelRatio),
        devicePixelRatio: pixelRatio,
      ),
      child: RenderPositionedBox(
        alignment: Alignment.center,
        child: repaintBoundary,
      ),
    );

    final pipelineOwner = PipelineOwner();
    final buildOwner = BuildOwner(focusManager: FocusManager());
    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final element = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(
        textDirection: textDirection,
        child: MediaQuery(
          data: MediaQueryData(size: logicalSize, devicePixelRatio: pixelRatio),
          child: SizedBox.fromSize(size: logicalSize, child: widget),
        ),
      ),
    ).attachToRenderTree(buildOwner);

    void flush() {
      buildOwner.buildScope(element);
      buildOwner.finalizeTree();
      pipelineOwner
        ..flushLayout()
        ..flushCompositingBits()
        ..flushPaint();
    }

    flush();
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
      flush();
    }

    final image = await repaintBoundary.toImage(pixelRatio: pixelRatio);
    final data = await image.toByteData(format: ImageByteFormat.png);
    image.dispose();
    if (data == null) {
      throw StateError('위젯을 이미지로 변환하지 못했습니다.');
    }
    return fromBytes(data.buffer.asUint8List());
  }

  static String _css(Color color) => color.toCssColor();
}
