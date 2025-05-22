import 'dart:html' as html;
import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin/src/basic/kakao_map_js_handler.dart';

void addJavascriptHandler(
  KakaoMapController controller,
  JavascriptMessage javascriptMessage,
) {
  html.window.onMessage.listen((event) {
    debugPrint('***** [JHC_DEBUG] addJavascriptHandler - web');
    final jsData = event.data;

    if (jsData is! JSString) {
      print('⚠️ JS 데이터가 문자열이 아님: $jsData');
      return;
    }

    final dartString = jsData.toDart;
    final indexOf = dartString.indexOf(':');
    final name = dartString.substring(0, indexOf);
    final message = dartString.substring(indexOf + 1);

    javascriptMessage(name, message);
  });
}
