import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

/// 이전/이후 버전 비교용 성능 벤치마크입니다. public API 만 사용하므로 두 버전에서
/// 동일하게 실행할 수 있습니다. 결과는 `[bench] key=value(ms)` 형식으로 출력됩니다.
///
/// 실행: cd example && flutter test integration_test/benchmark/perf_benchmark_test.dart -d <device>
///
/// 수 분이 걸리므로 `flutter test integration_test` 기본 실행에는 포함되지 않도록
/// benchmark/ 하위에 두었습니다.

const int markerCount = 500;
const int rebuildCount = 20;
const int polylinePoints = 2000;

class BenchHost extends StatelessWidget {
  final ValueNotifier<List<Marker>?> markers;
  final ValueNotifier<List<Polyline>?> polylines;
  final ValueNotifier<int> tick;
  final Completer<KakaoMapController> ready;

  const BenchHost({
    super.key,
    required this.markers,
    required this.polylines,
    required this.tick,
    required this.ready,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ValueListenableBuilder<int>(
          valueListenable: tick,
          builder: (_, __, ___) => ValueListenableBuilder<List<Marker>?>(
            valueListenable: markers,
            builder: (_, m, __) => ValueListenableBuilder<List<Polyline>?>(
              valueListenable: polylines,
              builder: (_, p, __) => KakaoMap(
                onMapCreated: (c) {
                  if (!ready.isCompleted) ready.complete(c);
                },
                onMarkerTap: (_, __, ___) {},
                center: LatLng(37.5665, 126.9780),
                currentLevel: 8,
                markers: m,
                polylines: p,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> pumpFor(WidgetTester tester, Duration duration) async {
  final end = DateTime.now().add(duration);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 50));
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

/// JS 쪽 오버레이 함수 호출 횟수를 셉니다. 두 버전 모두 top-level `function` 선언이라
/// window 속성으로 감쌀 수 있습니다. (이전 버전: addMarker 등 단건 함수, 새 버전: addMarkers 등 배치 함수)
Future<void> installCallCounter(KakaoMapController c) async {
  await c.webViewController.runJavaScript('''
    window.__calls = 0;
    ['addMarker','addMarkers','clearMarker','addPolyline','addPolylines','clearPolyline',
     'addCircle','addCircles','clearCircle','addRectangle','addRectangles','clearRectangle',
     'addPolygon','addPolygons','clearPolygon','addCustomOverlay','addCustomOverlays',
     'clearCustomOverlay','addMarkerClusterer','clearMarkerClusterer','relayout','registerImages']
      .forEach(function (n) {
        if (typeof window[n] === 'function' && !window[n].__wrapped) {
          var orig = window[n];
          var wrapped = function () { window.__calls++; return orig.apply(this, arguments); };
          wrapped.__wrapped = true;
          window[n] = wrapped;
        }
      });
  ''');
}

Future<int> callCount(KakaoMapController c) async {
  final raw =
      await c.webViewController.runJavaScriptReturningResult('window.__calls');
  // Android 는 문자열("12"), iOS 는 숫자(12 또는 12.0)로 돌려준다.
  if (raw is num) return raw.toInt();
  return num.parse(raw.toString().replaceAll('"', '')).toInt();
}

/// JS 함수 호출 수가 [settle] 동안 변하지 않을 때까지 기다린 뒤, 안정화 대기 시간을 뺀
/// 경과 시간(ms)과 그동안 늘어난 호출 수를 돌려줍니다.
///
/// 이전 버전은 마커마다 runJavaScript 를 순차 await 하므로 "다 끝났다"를 알 방법이
/// 호출 수 안정화뿐입니다. 새 버전에도 같은 기준을 적용합니다.
class SettleResult {
  final int ms;
  final int calls;
  const SettleResult(this.ms, this.calls);
}

Future<SettleResult> settle(KakaoMapController c, Stopwatch sw, int startCalls,
    {Duration settle = const Duration(milliseconds: 400)}) async {
  var last = await callCount(c);
  var lastChange = sw.elapsedMilliseconds;
  while (true) {
    await Future<void>.delayed(const Duration(milliseconds: 25));
    final now = await callCount(c);
    if (now != last) {
      last = now;
      lastChange = sw.elapsedMilliseconds;
    } else if (sw.elapsedMilliseconds - lastChange >= settle.inMilliseconds) {
      break;
    }
  }
  return SettleResult(lastChange, last - startCalls);
}

List<Marker> makeMarkers({int shift = 0}) => List.generate(
      markerCount,
      (i) => Marker(
        markerId: 'b$i',
        latLng: LatLng(
          37.45 + ((i + shift) % 25) * 0.008,
          126.85 + ((i + shift) ~/ 25) * 0.008,
        ),
        infoWindowContent: 'marker $i',
      ),
    );

List<Polyline> makePolylines() => [
      Polyline(
        polylineId: 'long',
        points: List.generate(
          polylinePoints,
          (i) => LatLng(37.45 + i * 0.0001, 126.85 + (i % 50) * 0.0005),
        ),
        strokeColor: Colors.blue,
        strokeWidth: 4,
      ),
    ];

void report(String key, num value) {
  // ignore: avoid_print
  print('[bench] $key=$value');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await dotenv.load(fileName: 'assets/env/.env');
    AuthRepository.initialize(
      appKey: dotenv.env['APP_KEY'] ?? '',
      baseUrl: dotenv.env['BASE_URL'] ?? '',
    );
  });

  testWidgets('벤치마크', (tester) async {
    final markers = ValueNotifier<List<Marker>?>(null);
    final polylines = ValueNotifier<List<Polyline>?>(null);
    final tick = ValueNotifier(0);
    final ready = Completer<KakaoMapController>();

    await tester.pumpWidget(BenchHost(
        markers: markers, polylines: polylines, tick: tick, ready: ready));
    final c = await ready.future.timeout(const Duration(seconds: 40));
    await pumpFor(tester, const Duration(seconds: 3));
    await installCallCounter(c);

    Future<void> measure(String key, Future<void> Function() action) async {
      final start = await callCount(c);
      final sw = Stopwatch()..start();
      await action();
      final r = await settle(c, sw, start);
      report('${key}_ms', r.ms);
      report('${key}_jscalls', r.calls);
    }

    // A. 컨트롤러로 마커 500개 추가 (콜드)
    await measure('A_addMarker_${markerCount}_cold',
        () => c.addMarker(markers: makeMarkers()));

    // A2. 동일 마커 500개 재추가 (내용 동일)
    await measure('A2_addMarker_${markerCount}_same',
        () => c.addMarker(markers: makeMarkers()));

    await c.clearMarker();
    await pumpFor(tester, const Duration(milliseconds: 500));

    // B. 위젯 속성으로 마커 500개 + 긴 폴리라인을 넘기고, 부모 rebuild 20회 (내용 변화 없음)
    markers.value = makeMarkers();
    polylines.value = makePolylines();
    await pumpFor(tester, const Duration(milliseconds: 300));
    tick.value++; // 이전 버전은 첫 rebuild 에서 그리므로 워밍업 rebuild 1회
    await tester.pump();
    {
      final sw = Stopwatch()..start();
      await settle(c, sw, 0);
    }

    await measure('B_rebuild_x${rebuildCount}_unchanged_total', () async {
      for (var i = 0; i < rebuildCount; i++) {
        tick.value++;
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 16));
      }
    });

    // C. 500개 중 1개만 좌표 변경 후 rebuild
    final changed = makeMarkers();
    changed[0] = Marker(
        markerId: 'b0',
        latLng: LatLng(37.60, 127.10),
        infoWindowContent: 'moved');
    await measure('C_rebuild_1_of_${markerCount}_changed', () async {
      markers.value = changed;
      await tester.pump();
    });

    // D. 500개 전부 좌표 변경 후 rebuild
    await measure('D_rebuild_all_${markerCount}_changed', () async {
      markers.value = makeMarkers(shift: 7);
      await tester.pump();
    });

    // E. 긴 폴리라인(2000점)만 있는 상태에서 rebuild 20회
    markers.value = null;
    await tester.pump();
    await pumpFor(tester, const Duration(milliseconds: 500));
    await measure(
        'E_polyline_${polylinePoints}pts_rebuild_x${rebuildCount}_total',
        () async {
      for (var i = 0; i < rebuildCount; i++) {
        tick.value++;
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 16));
      }
    });

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await pumpFor(tester, const Duration(milliseconds: 500));
  });
}
