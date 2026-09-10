// `flutter drive` 로 integration_test 를 실행할 때 쓰는 드라이버 진입점입니다.
// web(Chrome) 에서 통합 테스트를 돌릴 때 필요합니다:
//   chromedriver --port=4444
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/screens_smoke_test.dart -d web-server --browser-name=chrome
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
