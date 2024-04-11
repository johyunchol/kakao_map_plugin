part of '../../../kakao_map_plugin.dart';

enum Coords {
  wgs84('WGS84'),
  wcongnamul('WCONGNAMUL'),
  congnamul('CONGNAMUL'),
  wtm('WTM'),
  tm('TM');

  const Coords(this.name);

  final String name;

  factory Coords.getByName(String styleName) {
    return Coords.values.firstWhere((value) => value.name == styleName,
        orElse: () => Coords.wgs84);
  }
}
