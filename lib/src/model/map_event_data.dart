part of '../../kakao_map_plugin.dart';

/// 지도 탭 이벤트 내부 데이터 클래스입니다.
class _MapTapEventData {
  final double latitude;
  final double longitude;
  final int zoomLevel;

  const _MapTapEventData({
    required this.latitude,
    required this.longitude,
    required this.zoomLevel,
  });

  factory _MapTapEventData.fromJson(Map<String, dynamic> json) {
    return _MapTapEventData(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      zoomLevel: (json['zoomLevel'] as num).toInt(),
    );
  }

  LatLng toLatLng() => LatLng(latitude, longitude);
}

/// 마커 탭 이벤트 내부 데이터 클래스입니다.
class _MarkerTapEventData {
  final String markerId;
  final double latitude;
  final double longitude;
  final int zoomLevel;

  const _MarkerTapEventData({
    required this.markerId,
    required this.latitude,
    required this.longitude,
    required this.zoomLevel,
  });

  factory _MarkerTapEventData.fromJson(Map<String, dynamic> json) {
    return _MarkerTapEventData(
      markerId: json['markerId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      zoomLevel: (json['zoomLevel'] as num).toInt(),
    );
  }

  LatLng toLatLng() => LatLng(latitude, longitude);
}

/// 마커 클러스터 탭 이벤트 내부 데이터 클래스입니다.
class _ClusterTapEventData {
  final double latitude;
  final double longitude;
  final int zoomLevel;
  final List<String> markerIds;

  const _ClusterTapEventData({
    required this.latitude,
    required this.longitude,
    required this.zoomLevel,
    required this.markerIds,
  });

  factory _ClusterTapEventData.fromJson(Map<String, dynamic> json) {
    return _ClusterTapEventData(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      zoomLevel: (json['zoomLevel'] as num).toInt(),
      markerIds: (json['markers'] as List<dynamic>).cast<String>(),
    );
  }

  LatLng toLatLng() => LatLng(latitude, longitude);
}

/// 커스텀 오버레이 탭 이벤트 내부 데이터 클래스입니다.
class _CustomOverlayTapEventData {
  final String customOverlayId;
  final double latitude;
  final double longitude;

  const _CustomOverlayTapEventData({
    required this.customOverlayId,
    required this.latitude,
    required this.longitude,
  });

  factory _CustomOverlayTapEventData.fromJson(Map<String, dynamic> json) {
    return _CustomOverlayTapEventData(
      customOverlayId: json['customOverlayId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  LatLng toLatLng() => LatLng(latitude, longitude);
}

/// 마커 드래그 이벤트 내부 데이터 클래스입니다.
class _MarkerDragEventData {
  final String markerId;
  final double latitude;
  final double longitude;
  final int zoomLevel;
  final MarkerDragType dragType;

  const _MarkerDragEventData({
    required this.markerId,
    required this.latitude,
    required this.longitude,
    required this.zoomLevel,
    required this.dragType,
  });

  factory _MarkerDragEventData.fromJson(Map<String, dynamic> json) {
    return _MarkerDragEventData(
      markerId: json['markerId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      zoomLevel: (json['zoomLevel'] as num).toInt(),
      dragType: json['drag'] == 'dragstart'
          ? MarkerDragType.start
          : MarkerDragType.end,
    );
  }

  LatLng toLatLng() => LatLng(latitude, longitude);
}

/// 드래그 이벤트 내부 데이터 클래스입니다.
class _DragEventData {
  final double latitude;
  final double longitude;
  final int zoomLevel;

  const _DragEventData({
    required this.latitude,
    required this.longitude,
    required this.zoomLevel,
  });

  factory _DragEventData.fromJson(Map<String, dynamic> json) {
    return _DragEventData(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      zoomLevel: (json['zoomLevel'] as num).toInt(),
    );
  }

  LatLng toLatLng() => LatLng(latitude, longitude);
}

/// 줌 이벤트 내부 데이터 클래스입니다.
class _ZoomEventData {
  final int zoomLevel;

  const _ZoomEventData({required this.zoomLevel});

  factory _ZoomEventData.fromJson(Map<String, dynamic> json) {
    return _ZoomEventData(
      zoomLevel: (json['zoomLevel'] as num).toInt(),
    );
  }
}

/// 중심 변경 이벤트 내부 데이터 클래스입니다.
class _CenterChangeEventData {
  final double latitude;
  final double longitude;
  final int zoomLevel;

  const _CenterChangeEventData({
    required this.latitude,
    required this.longitude,
    required this.zoomLevel,
  });

  factory _CenterChangeEventData.fromJson(Map<String, dynamic> json) {
    return _CenterChangeEventData(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      zoomLevel: (json['zoomLevel'] as num).toInt(),
    );
  }

  LatLng toLatLng() => LatLng(latitude, longitude);
}

/// 경계 변경 이벤트 내부 데이터 클래스입니다.
class _BoundsChangeEventData {
  final double swLatitude;
  final double swLongitude;
  final double neLatitude;
  final double neLongitude;

  const _BoundsChangeEventData({
    required this.swLatitude,
    required this.swLongitude,
    required this.neLatitude,
    required this.neLongitude,
  });

  factory _BoundsChangeEventData.fromJson(Map<String, dynamic> json) {
    final sw = json['sw'] as Map<String, dynamic>;
    final ne = json['ne'] as Map<String, dynamic>;
    return _BoundsChangeEventData(
      swLatitude: (sw['latitude'] as num).toDouble(),
      swLongitude: (sw['longitude'] as num).toDouble(),
      neLatitude: (ne['latitude'] as num).toDouble(),
      neLongitude: (ne['longitude'] as num).toDouble(),
    );
  }

  LatLngBounds toLatLngBounds() => LatLngBounds(
        LatLng(swLatitude, swLongitude),
        LatLng(neLatitude, neLongitude),
      );
}
