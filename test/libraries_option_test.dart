import 'package:flutter_test/flutter_test.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

void main() {
  setUp(() {
    AuthRepository.initialize(appKey: 'test_key');
  });

  tearDown(() {
    // 다른 테스트에 영향을 주지 않도록 기본값으로 되돌립니다.
    AuthRepository.instance.libraries = null;
  });

  group('KakaoMapLibrary', () {
    test('기본값은 전체 라이브러리다', () {
      expect(KakaoMapLibrary.all, {
        KakaoMapLibrary.services,
        KakaoMapLibrary.clusterer,
        KakaoMapLibrary.drawing,
      });
    });

    test('집합 순서와 무관하게 항상 동일한 쿼리 문자열을 만든다', () {
      final a = KakaoMapLibrary.toQueryValue(
          {KakaoMapLibrary.drawing, KakaoMapLibrary.services});
      final b = KakaoMapLibrary.toQueryValue(
          {KakaoMapLibrary.services, KakaoMapLibrary.drawing});
      expect(a, b);
      expect(a, 'services,drawing');
    });

    test('빈 집합은 빈 문자열을 만든다', () {
      expect(KakaoMapLibrary.toQueryValue({}), '');
    });
  });

  group('htmlWrapper', () {
    test('기본값은 세 라이브러리를 모두 포함해 기존 동작을 유지한다', () {
      final html = htmlWrapper('<script></script>');
      expect(html, contains('libraries=services,clusterer,drawing'));
      expect(html, contains('appkey=test_key'));
    });

    test('AuthRepository.libraries 로 전역 기본값을 바꿀 수 있다', () {
      AuthRepository.instance.libraries = {KakaoMapLibrary.services};
      final html = htmlWrapper('<script></script>');
      expect(html, contains('libraries=services'));
      expect(html, isNot(contains('drawing')));
    });

    test('명시적 인자가 전역 기본값보다 우선한다', () {
      AuthRepository.instance.libraries = {KakaoMapLibrary.services};
      final html = htmlWrapper('<script></script>',
          libraries: {KakaoMapLibrary.clusterer});
      expect(html, contains('libraries=clusterer'));
      expect(html, isNot(contains('services')));
    });

    test('빈 집합이면 libraries 파라미터 자체를 붙이지 않는다', () {
      final html = htmlWrapper('<script></script>', libraries: {});
      expect(html, isNot(contains('libraries=')));
      expect(html, contains('appkey=test_key'));
    });

    test('appKey 는 URL 인코딩되어 삽입된다', () {
      AuthRepository.instance.appKey = "key with space&amp";
      final html = htmlWrapper('<script></script>');
      expect(html, isNot(contains('key with space&amp')));
      expect(html, contains('appkey=key+with+space%26amp'));
    });

    test('initialize 로 libraries 를 지정할 수 있다', () {
      AuthRepository.initialize(
        appKey: 'k',
        libraries: {KakaoMapLibrary.clusterer, KakaoMapLibrary.services},
      );
      expect(AuthRepository.instance.libraries,
          {KakaoMapLibrary.clusterer, KakaoMapLibrary.services});
      expect(htmlWrapper(''), contains('libraries=services,clusterer'));
    });
  });
}
