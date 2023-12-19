part of kakao_map_plugin;

enum MapView {
  basicMap(0),
  roadMap(1),
  staticMap(2);

  const MapView(this.id);

  final int id;

  factory MapView.getById(int MapViewId) {
    return MapView.values.firstWhere((value) => value.id == MapViewId,
        orElse: () => MapView.basicMap);
  }
}
