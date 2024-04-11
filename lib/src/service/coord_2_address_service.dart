part of '../../kakao_map_plugin.dart';

class Coord2AddressService extends BaseService<Coord2AddressResponse> {
  static final Coord2AddressService _instance =
      Coord2AddressService._internal();

  factory Coord2AddressService() => _instance;

  Coord2AddressService._internal() : super();

  static void coord2AddressCallback(String message) {
    final resultData = jsonDecode(message);
    _instance.completer.complete(Coord2AddressResponse.fromJson(resultData));
  }

  static Future<Coord2AddressResponse> coord2AddressResult() =>
      _instance.completer.future;
}
