import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin/src/basic/kakao_map_js_handler.dart';

void addJavascriptHandler(
  KakaoMapController controller,
  JavascriptMessage javascriptMessage,
) {
  debugPrint('***** [JHC_DEBUG] addJavascriptHandler - app');

  for (var event in JavascriptEvent.values) {
    controller.webViewController.addJavaScriptHandler(
      handlerName: event.name,
      callback: (message) {
        javascriptMessage(
          event.name,
          message.isNotEmpty ? message[0].toString() : '',
        );
      },
    );
  }
}
