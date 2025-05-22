import 'package:kakao_map_plugin/kakao_map_plugin.dart';

export 'kakao_map_js_handler_app.dart'
    if (dart.library.html) 'kakao_map_js_handler_web.dart';

typedef JavascriptMessage = void Function(
  String name,
  String message,
);
