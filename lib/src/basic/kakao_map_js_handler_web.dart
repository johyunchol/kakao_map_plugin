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

    if (jsData is JSString) {
      final dartString = jsData.toDart;

      if (dartString.startsWith('onMapCreated:')) {
        final message = dartString.substring('onMapCreated:'.length);
        print('📩 JS에서 받은 메시지: $message');
        javascriptMessage(
          'onMapCreated',
          dartString.substring('onMapCreated:'.length),
        );

        // if (widget.onMapCreated != null) {
        //   widget.onMapCreated!(_mapController);
        // }
      }

      // if (dartString.startsWith('onMapTap:')) {
      //   final message = dartString.substring('onMapTap:'.length);
      //   print('📩 JS에서 받은 메시지: $message');
      //   if (widget.onMapTap != null) {
      //     widget.onMapTap!(LatLng.fromJson(jsonDecode(message)));
      //   }
      // }
    } else {
      print('⚠️ JS 데이터가 문자열이 아님: $jsData');
    }
  });
}
