import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

class _TestService extends BaseService<List<String>> {}

void main() {
  group('BaseService 요청 ID 라우팅', () {
    List<String> fromJson(dynamic json) => (json as List).cast<String>();

    test('동시 요청이 각자의 응답을 받는다', () async {
      final service = _TestService();
      final id1 = service.createRequest();
      final id2 = service.createRequest();
      final f1 = service.requestFuture(id1);
      final f2 = service.requestFuture(id2);

      // 응답 순서가 뒤바뀌어 도착해도 올바르게 매칭되어야 한다.
      service.handleMessage(
          jsonEncode({
            'requestId': id2,
            'result': ['two']
          }),
          fromJson);
      service.handleMessage(
          jsonEncode({
            'requestId': id1,
            'result': ['one']
          }),
          fromJson);

      expect(await f1, ['one']);
      expect(await f2, ['two']);
    });

    test('error 응답은 completeError 로 전달된다', () async {
      final service = _TestService();
      final id = service.createRequest();
      final future = service.requestFuture(id);

      service.handleMessage(
          jsonEncode({'requestId': id, 'error': 'ZERO_RESULT'}), fromJson);

      await expectLater(future, throwsA(isA<StateError>()));
    });

    test('잘못된 JSON 이나 변환 실패가 예외를 밖으로 던지지 않는다', () async {
      final service = _TestService();
      final id = service.createRequest();
      final future = service.requestFuture(id);

      expect(
          () => service.handleMessage('not json', fromJson), returnsNormally);
      expect(
        () => service.handleMessage(
            jsonEncode({'requestId': id, 'result': 'not a list'}), fromJson),
        returnsNormally,
      );
      await expectLater(future, throwsA(anything));
    });

    test('레거시 형식(배열)은 기존 completer 를 완료한다', () async {
      final service = _TestService();
      service.resetCompleter();
      final legacy = service.completer.future;

      service.handleMessage(jsonEncode(['legacy']), fromJson);

      expect(await legacy, ['legacy']);
      // 이미 완료된 completer 에 다시 도착해도 예외가 없어야 한다.
      expect(() => service.handleMessage(jsonEncode(['again']), fromJson),
          returnsNormally);
    });

    test('요청 ID 응답이 레거시 completer 에도 반영된다 (하위호환)', () async {
      final service = _TestService();
      service.resetCompleter();
      final legacy = service.completer.future; // 기존 방식: xxxResult() 로 대기
      final id = service.createRequest();
      final modern = service.requestFuture(id);

      service.handleMessage(
          jsonEncode({
            'requestId': id,
            'result': ['both']
          }),
          fromJson);

      expect(await modern, ['both']);
      expect(await legacy, ['both']);
    });

    test('failRequest 는 대기 중인 요청을 에러로 종료한다', () async {
      final service = _TestService();
      final id = service.createRequest();
      final future = service.requestFuture(id);
      service.failRequest(id, Exception('bridge failure'));
      await expectLater(future, throwsA(isA<Exception>()));
      expect(
          () => service.failRequest(id, Exception('twice')), returnsNormally);
    });
  });

  group('모델 fromJson', () {
    test('LatLng.fromJson 은 정수 좌표도 받아들인다', () {
      final latLng = LatLng.fromJson({'latitude': 37, 'longitude': 127.5});
      expect(latLng.latitude, 37.0);
      expect(latLng.longitude, 127.5);
    });

    test('LatLngBounds.fromJson 은 중첩 Map 을 파싱한다', () {
      final bounds = LatLngBounds.fromJson({
        'sw': {'latitude': 1, 'longitude': 2},
        'ne': {'latitude': 3.5, 'longitude': 4.5},
      });
      expect(bounds.sw.latitude, 1.0);
      expect(bounds.ne.longitude, 4.5);
    });
  });

  group('MarkerIcon 하위호환', () {
    test('fromNetwork 는 여전히 Future<MarkerIcon> 을 반환한다', () async {
      final Future<MarkerIcon> future =
          MarkerIcon.fromNetwork('https://example.com/a.png');
      final icon = await future;
      expect(icon.imageSrc, 'https://example.com/a.png');
      expect(icon.imageType, ImageType.url);
    });

    test('network 는 동기적으로 생성한다', () {
      final icon = MarkerIcon.network('https://example.com/a.png');
      expect(icon.imageType, ImageType.url);
    });
  });

  group('AuthRepository 하위호환', () {
    test('appKey setter 가 동작한다', () {
      AuthRepository.instance.appKey = 'direct-key';
      expect(AuthRepository.instance.appKey, 'direct-key');
      expect(AuthRepository.isInitialized, isTrue);
    });
  });

  group('ClustererStyle.toJson', () {
    test('null 필드는 키를 생략한다', () {
      final json = ClustererStyle(width: 40).toJson();
      expect(json.containsKey('width'), isTrue);
      expect(json.containsKey('color'), isFalse);
      expect(json.containsKey('background'), isFalse);
      expect(json.containsKey('lineHeight'), isFalse);
    });
  });
}
