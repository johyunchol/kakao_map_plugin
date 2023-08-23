part of kakao_map_plugin;

enum MapType {
  normal(1),
  roadMap(1),
  skyView(2),
  hybrid(3),
  overlay(4),
  roadView(5),
  traffic(6),
  terrain(7),
  bicycle(8),
  bicycleHybrid(9),
  useDistrict(10);

  const MapType(this.id);

  final int id;

  factory MapType.getById(int mapTypeId) {
    return MapType.values.firstWhere((value) => value.id == mapTypeId,
        orElse: () => MapType.normal);
  }
}
