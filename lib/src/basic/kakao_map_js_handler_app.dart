import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin/src/basic/kakao_map_js_handler.dart';

void addJavascriptHandler(
  KakaoMapController controller,
  JavascriptMessage javascriptMessage,
) {
  debugPrint('***** [JHC_DEBUG] addJavascriptHandler - app');

  controller.webViewController.addJavaScriptHandler(
    handlerName: 'onMapCreated',
    callback: (message) {
      // print('onMapCreated >>>>>>>>>>>>>>>>>>>>>>>>');
      javascriptMessage(
        'onMapCreated',
        message.isNotEmpty ? message[0].toString() : '',
      );
    },
  );
  controller.webViewController.addJavaScriptHandler(
    handlerName: 'onMapTap',
    callback: (message) {
      // print('onMapCreated >>>>>>>>>>>>>>>>>>>>>>>>');
      javascriptMessage(
        'onMapTap',
        message.isNotEmpty ? message[0].toString() : '',
      );
    },
  );
}
