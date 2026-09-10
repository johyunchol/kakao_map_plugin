/// JavaScript 검색 서비스 스크립트를 제공합니다.
///
/// 각 검색 함수는 선택적으로 `requestId` 를 받습니다. requestId 가 주어지면
/// 응답을 `{"requestId": n, "result": [...]}` 형태로 보내 Dart 쪽에서 요청별로
/// 라우팅할 수 있게 하고, 없으면 기존처럼 결과 배열만 보냅니다(레거시 호환).
class JsSearch {
  /// 검색 서비스 함수들의 스크립트를 반환합니다.
  static String getScript() {
    return '''
    // 카카오 SDK 의 성공 상태값입니다. typeof null === 'object' 이므로 result 의 타입만으로
    // 성공 여부를 판정하면 SDK 가 실패 시 돌려주는 result=null 을 성공으로 오판하게 됩니다.
    // status 를 1급 판정 기준으로 삼아 이 문제를 막습니다.
    /**
     * 검색 결과를 채널로 전달합니다.
     * requestId 가 있으면 {requestId, result} 또는 {requestId, error} 로 감싸서 보냅니다.
     *
     * 상태 판정 규칙:
     * - OK          : 결과 그대로 전달
     * - ZERO_RESULT : **오류가 아니라 빈 결과**입니다. 빈 배열을 전달해
     *                 "검색 결과 없음" 이 예외가 아닌 빈 목록으로 처리되게 합니다.
     * - 그 외(ERROR): 오류로 전달
     *
     * typeof null === 'object' 이므로 result 의 타입만으로 성공 여부를 판정하면
     * SDK 가 실패 시 돌려주는 result=null 을 성공으로 오판하게 됩니다.
     */
    function __postSearchResult(channel, requestId, result, status, pagination) {
        const S = (typeof kakao !== 'undefined' && kakao.maps && kakao.maps.services)
            ? kakao.maps.services.Status : null;
        const okStatus = S ? S.OK : 'OK';
        const zeroStatus = S ? S.ZERO_RESULT : 'ZERO_RESULT';

        let ok = false;
        let payload = null;
        if (status === okStatus && result != null) {
            ok = true;
            payload = result;
        } else if (status === zeroStatus) {
            ok = true;
            payload = Array.isArray(result) ? result : [];
        }

        if (requestId === undefined || requestId === null) {
            if (ok) {
                channel.postMessage(JSON.stringify(payload));
            }
            return;
        }

        if (ok) {
            const message = { requestId: requestId, result: payload };
            if (pagination) {
                message.pagination = {
                    totalCount: pagination.totalCount, current: pagination.current,
                    hasNextPage: !!pagination.hasNextPage, hasPrevPage: !!pagination.hasPrevPage
                };
            }
            channel.postMessage(JSON.stringify(message));
        } else {
            channel.postMessage(JSON.stringify({ requestId: requestId, error: String(status) }));
        }
    }

    /**
     * 검색 서비스 사용 가능 여부를 확인합니다.
     * services 라이브러리를 제외하고 로드한 경우 채널로 에러를 돌려주고 false 를 반환합니다.
     */
    function __requireServices(channel, requestId) {
        if (typeof ensureServices === 'function' && ensureServices()) return true;
        __postSearchResult(channel, requestId, null,
            'SERVICES_LIBRARY_NOT_LOADED');
        return false;
    }

    function keywordSearch(request, requestId) {
        if (!__requireServices(keywordSearchCallback, requestId)) return;
        request = parseIfString(request);

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

        places.keywordSearch(request.keyword, function (result, status, pagination) {
            __postSearchResult(keywordSearchCallback, requestId, result, status, pagination);
        }, options);
    }

    function categorySearch(request, requestId) {
        if (!__requireServices(categorySearchCallback, requestId)) return;
        request = parseIfString(request);

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

        places.categorySearch(request.categoryGroupCode, function (result, status, pagination) {
            __postSearchResult(categorySearchCallback, requestId, result, status, pagination);
        }, options);
    }

    function addressSearch(request, requestId) {
        if (!__requireServices(addressSearchCallback, requestId)) return;
        request = parseIfString(request);

        let options = {
            page: request.page,
            size: request.size,
            // Dart 의 AddressSearchRequest.toJson() 은 'analyzeType' 키로 내보내므로
            // 그 값도 함께 받아들입니다(레거시 analyze_type 키와의 하위호환 유지).
            analyze_type: request.analyze_type ?? request.analyzeType,
        };

        geocoder.addressSearch(request.addr, function (result, status, pagination) {
            __postSearchResult(addressSearchCallback, requestId, result, status, pagination);
        }, options);
    }

    function coord2Address(request, requestId) {
        if (!__requireServices(coord2AddressCallback, requestId)) return;
        request = parseIfString(request);

        let options = {
            input_coord: request.input_coord,
        };

        geocoder.coord2Address(request.x, request.y, function (result, status) {
            __postSearchResult(coord2AddressCallback, requestId, result, status);
        }, options);
    }

    function coord2RegionCode(request, requestId) {
        if (!__requireServices(coord2RegionCodeCallback, requestId)) return;
        request = parseIfString(request);

        let options = {
            input_coord: request.input_coord,
            output_coord: request.output_coord,
        };

        geocoder.coord2RegionCode(request.x, request.y, function (result, status) {
            __postSearchResult(coord2RegionCodeCallback, requestId, result, status);
        }, options);
    }

    function transCoord(request, requestId) {
        if (!__requireServices(transCoordCallback, requestId)) return;
        request = parseIfString(request)

        let options = {
            input_coord: request.input_coord,
            output_coord: request.output_coord,
        };

        geocoder.transCoord(request.x, request.y, function (result, status) {
            __postSearchResult(transCoordCallback, requestId, result, status);
        }, options);
    }
    ''';
  }
}
