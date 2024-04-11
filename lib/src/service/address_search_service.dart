part of '../../kakao_map_plugin.dart';

class AddressSearchService extends BaseService<AddressSearchResponse> {
  static final AddressSearchService _instance =
      AddressSearchService._internal();

  factory AddressSearchService() => _instance;

  AddressSearchService._internal() : super();

  static Future<void> addressSearchCallback(String message) async {
    final resultData = jsonDecode(message);
    _instance._completer.complete(AddressSearchResponse.fromJson(resultData));
  }

  static Future<AddressSearchResponse> addressSearchResult() {
    return _instance.completer.future;
  }
}
