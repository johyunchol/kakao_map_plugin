part of '../../kakao_map_plugin.dart';

class Coord2RegionCodeService extends BaseService<Coord2RegionCodeResponse> {
  static final Coord2RegionCodeService _instance =
      Coord2RegionCodeService._internal();

  factory Coord2RegionCodeService() => _instance;

  Coord2RegionCodeService._internal() : super();

  static void coord2RegionCodeCallback(String message) {
    final resultData = jsonDecode(message);
    _instance.completer.complete(Coord2RegionCodeResponse.fromJson(resultData));
  }

  static Future<Coord2RegionCodeResponse> coord2RegionCodeResult() =>
      _instance.completer.future;
}
