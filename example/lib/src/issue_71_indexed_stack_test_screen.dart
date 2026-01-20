import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

/// Issue #71: IndexedStack에서 지도 중심이 이동하는 문제 테스트
///
/// 문제 재현:
/// - IndexedStack에서 같은 KakaoMap 위젯을 여러 화면에서 사용할 때
/// - 최초 화면에서만 중심이 맞춰지고
/// - 다른 화면으로 전환 시 지도 중심이 "약간 오른쪽 아래로" 이동함
///
/// 해결책:
/// - KakaoMap에 keepAlive: true 옵션 추가
/// - 내부적으로 activate/deactivate 시 relayout() 호출 및 상태 복원
class Issue71IndexedStackTestScreen extends StatefulWidget {
  const Issue71IndexedStackTestScreen({Key? key}) : super(key: key);

  @override
  State<Issue71IndexedStackTestScreen> createState() =>
      _Issue71IndexedStackTestScreenState();
}

class _Issue71IndexedStackTestScreenState
    extends State<Issue71IndexedStackTestScreen> {
  int _currentIndex = 0;
  bool _useKeepAlive = true; // keepAlive 옵션 토글

  // 지도 중심 좌표 (서울 시청)
  final LatLng _center = LatLng(37.5666805, 126.9784147);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue #71: IndexedStack 테스트'),
      ),
      body: Column(
        children: [
          // 현재 탭 정보 표시
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '현재 탭: $_currentIndex',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        const Text('keepAlive: '),
                        Switch(
                          value: _useKeepAlive,
                          onChanged: (value) {
                            setState(() {
                              _useKeepAlive = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('중심 좌표: ${_center.latitude}, ${_center.longitude}'),
                const SizedBox(height: 8),
                Text(
                  _useKeepAlive
                      ? 'keepAlive=true: 탭 전환 시 상태가 유지됩니다.'
                      : 'keepAlive=false: 탭 전환 시 중심이 이동할 수 있습니다.',
                  style: TextStyle(
                    color: _useKeepAlive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // IndexedStack으로 지도 화면 전환
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                _MapScreen(
                  key: ValueKey('map_0_$_useKeepAlive'),
                  center: _center,
                  label: 'Tab 0',
                  keepAlive: _useKeepAlive,
                ),
                _MapScreen(
                  key: ValueKey('map_1_$_useKeepAlive'),
                  center: _center,
                  label: 'Tab 1',
                  keepAlive: _useKeepAlive,
                ),
                _MapScreen(
                  key: ValueKey('map_2_$_useKeepAlive'),
                  center: _center,
                  label: 'Tab 2',
                  keepAlive: _useKeepAlive,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Tab 0',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Tab 1',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Tab 2',
          ),
        ],
      ),
    );
  }
}

/// 개별 지도 화면 위젯
class _MapScreen extends StatefulWidget {
  const _MapScreen({
    Key? key,
    required this.center,
    required this.label,
    this.keepAlive = false,
  }) : super(key: key);

  final LatLng center;
  final String label;
  final bool keepAlive;

  @override
  State<_MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<_MapScreen> {
  KakaoMapController? _mapController;
  LatLng? _currentCenter;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        KakaoMap(
          center: widget.center,
          keepAlive: widget.keepAlive,
          onMapCreated: (controller) {
            _mapController = controller;
            _updateCurrentCenter();
          },
          onCameraIdle: (latLng, zoomLevel) {
            setState(() {
              _currentCenter = latLng;
            });
          },
          onCenterChangeCallback: (latLng, zoomLevel) {
            setState(() {
              _currentCenter = latLng;
            });
          },
        ),
        // 현재 중심 좌표 표시
        Positioned(
          top: 8,
          left: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '설정된 중심: ${widget.center.latitude.toStringAsFixed(7)}, '
                  '${widget.center.longitude.toStringAsFixed(7)}',
                  style: const TextStyle(fontSize: 12),
                ),
                if (_currentCenter != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '현재 중심: ${_currentCenter!.latitude.toStringAsFixed(7)}, '
                    '${_currentCenter!.longitude.toStringAsFixed(7)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '차이 (lat): ${(_currentCenter!.latitude - widget.center.latitude).toStringAsFixed(7)}\n'
                    '차이 (lng): ${(_currentCenter!.longitude - widget.center.longitude).toStringAsFixed(7)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: _hasDifference() ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        // 중심 재설정 버튼
        Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: '${widget.label}_center',
                onPressed: _resetCenter,
                child: const Icon(Icons.my_location),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: '${widget.label}_relayout',
                onPressed: _relayout,
                backgroundColor: Colors.orange,
                child: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _hasDifference() {
    if (_currentCenter == null) return false;
    final latDiff = (_currentCenter!.latitude - widget.center.latitude).abs();
    final lngDiff = (_currentCenter!.longitude - widget.center.longitude).abs();
    // 0.0001도 이상 차이나면 문제로 판단
    return latDiff > 0.0001 || lngDiff > 0.0001;
  }

  Future<void> _updateCurrentCenter() async {
    if (_mapController != null) {
      try {
        final center = await _mapController!.getCenter();
        setState(() {
          _currentCenter = center;
        });
      } catch (e) {
        debugPrint('Error getting center: $e');
      }
    }
  }

  void _resetCenter() {
    _mapController?.setCenter(widget.center);
    _updateCurrentCenter();
  }

  void _relayout() {
    _mapController?.relayout();
    _updateCurrentCenter();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
