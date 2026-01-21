/// JavaScript 검색 서비스 스크립트를 제공합니다.
class JsSearch {
  /// 검색 서비스 함수들의 스크립트를 반환합니다.
  static String getScript() {
    return '''
    function keywordSearch(request) {
        request = JSON.parse(request);

        let options = {
            category_group_code: request.categoryGroupCode,
            x: request.x,
            y: request.y,
            radius: request.radius,
            rect: request.rect,
            page: request.page,
            size: request.size,
            sort: request.sort,
            useMapCenter: request.useMapCenter,
            useMapBounds: request.useMapBounds,
        };

        places.keywordSearch(request.keyword, function (result, status) {
            if (typeof result === 'object') {
                keywordSearchCallback.postMessage(JSON.stringify(result));
            }
        }, options);
    }

    function categorySearch(request) {
        request = JSON.parse(request);

        let options = {
            x: request.x,
            y: request.y,
            radius: request.radius,
            rect: request.rect,
            page: request.page,
            size: request.size,
            sort: request.sort,
            useMapCenter: request.useMapCenter,
            useMapBounds: request.useMapBounds,
        };

        places.categorySearch(request.categoryGroupCode, function (result, status) {
            if (typeof result === 'object') {
                categorySearchCallback.postMessage(JSON.stringify(result));
            }
        }, options);
    }

    function addressSearch(request) {
        request = JSON.parse(request);

        let options = {
            page: request.page,
            size: request.size,
            analyze_type: request.analyze_type,
        };

        geocoder.addressSearch(request.addr, function (result, status) {
            if (typeof result === 'object') {
                addressSearchCallback.postMessage(JSON.stringify(result));
            }
        }, options);
    }

    function coord2Address(request) {
        request = JSON.parse(request);

        let options = {
            input_coord: request.input_coord,
        };

        geocoder.coord2Address(request.x, request.y, function (result, status) {
            if (typeof result === 'object') {
                coord2AddressCallback.postMessage(JSON.stringify(result));
            }
        }, options);
    }

    function coord2RegionCode(request) {
        request = JSON.parse(request);

        let options = {
            input_coord: request.input_coord,
            output_coord: request.output_coord,
        };

        geocoder.coord2RegionCode(request.x, request.y, function (result, status) {
            if (typeof result === 'object') {
                coord2RegionCodeCallback.postMessage(JSON.stringify(result));
            }
        }, options);
    }

    function transCoord(request) {
        request = JSON.parse(request)

        let options = {
            input_coord: request.input_coord,
            output_coord: request.output_coord,
        };

        geocoder.transCoord(request.x, request.y, function (result, status) {
            if (typeof result === 'object') {
                transCoordCallback.postMessage(JSON.stringify(result));
            }
        }, options);
    }
    ''';
  }
}
