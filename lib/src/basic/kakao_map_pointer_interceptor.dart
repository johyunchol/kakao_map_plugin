import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

/// 지도 위에 겹쳐 놓은 Flutter 위젯(버튼, 카드 등)이 web 에서도 탭을 받게 합니다.
///
/// web 에서 지도는 iframe(HTML 요소)으로 그려지는데, 브라우저는 그 영역의
/// 포인터 이벤트를 iframe 에 먼저 전달하므로 `Stack` 으로 지도 위에 올린 Flutter
/// 위젯은 눌리지 않습니다. 이 위젯은 자식 영역에 투명한 HTML 레이어를 깔아
/// 이벤트를 Flutter 쪽으로 돌립니다. Android/iOS 에서는 [child] 를 그대로
/// 반환하므로 플랫폼을 가리지 않고 감싸 두면 됩니다.
///
/// 지도 위에 올리는 위젯마다(또는 그 묶음마다) 감싸세요. `Scaffold` 의
/// `floatingActionButton` 처럼 지도와 겹치는 것도 포함됩니다.
///
/// 예시:
/// ```dart
/// Stack(
///   children: [
///     KakaoMap(onMapCreated: ...),
///     Positioned(
///       top: 16,
///       right: 16,
///       child: KakaoMapPointerInterceptor(
///         child: ElevatedButton(onPressed: ..., child: const Text('현재 위치')),
///       ),
///     ),
///   ],
/// )
/// ```
class KakaoMapPointerInterceptor extends StatelessWidget {
  /// 지도 위에 겹치는 위젯입니다.
  final Widget child;

  /// false 이면 아무것도 가로채지 않고 [child] 를 그대로 둡니다.
  final bool intercepting;

  /// 지도 위 위젯용 포인터 인터셉터를 만듭니다.
  const KakaoMapPointerInterceptor({
    super.key,
    required this.child,
    this.intercepting = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || !intercepting) return child;
    return PointerInterceptor(child: child);
  }
}
