/// JavaScript 유틸리티 스크립트를 제공합니다.
class JsUtils {
  /// 유틸리티 함수들의 스크립트를 반환합니다.
  static String getScript({
    required bool isIOS,
  }) {
    return '''
    const empty = (value) => {
        if (value === null) return true
        if (typeof value === 'undefined') return true
        if (typeof value === 'string' && (value === '' || value === 'null')) return true
        if (Array.isArray(value) && value.length < 1) return true
        if (typeof value === 'object' && value.constructor.name === 'Object' && Object.keys(value).length < 1 && Object.getOwnPropertyNames(value).length < 1) return true
        if (typeof value === 'object' && value.constructor.name === 'String' && Object.keys(value).length < 1) return true // new String
        return false
    }

    /**
     * null / 'null' / undefined 를 undefined 로 정규화합니다.
     * JS 기본 파라미터는 undefined 일 때만 적용되므로 배치 payload 의 null 을 변환할 때 사용합니다.
     */
    function nv(value) {
        return (value === null || value === undefined || value === 'null') ? undefined : value;
    }

    /** 문자열이면 JSON.parse, 아니면 그대로 반환합니다. (단건 호출/배치 호출 양쪽 호환) */
    function parseIfString(value) {
        return typeof value === 'string' ? JSON.parse(value) : value;
    }

    /** 인덱스(Map)로부터 파생 배열들을 재계산합니다. 배치 중에는 지연됩니다. */
    function syncOverlayArrays() {
        if (__batchDepth > 0) return;
        polylines = Array.from(polylineIndex.values());
        circles = Array.from(circleIndex.values());
        rectangles = Array.from(rectangleIndex.values());
        polygons = Array.from(polygonIndex.values());
        markers = Array.from(markerIndex.values());
        customOverlays = Array.from(customOverlayIndex.values());
    }

    /** fn 실행 동안 파생 배열 재계산을 지연하고, 종료 시 한 번만 수행합니다. */
    function runBatch(fn) {
        __batchDepth++;
        try {
            fn();
        } finally {
            __batchDepth--;
            syncOverlayArrays();
        }
    }

    /** list 의 각 항목에 fn 을 적용하되, 한 항목의 예외가 나머지를 막지 않게 합니다. */
    function forEachSafe(list, label, fn) {
        runBatch(function () {
            for (let i = 0; i < list.length; i++) {
                try { fn(list[i], i); }
                catch (e) {
                    if (window.__kakaoMapErrors.length < 50) {
                        window.__kakaoMapErrors.push(label + '[' + i + ']: ' + String(e));
                    }
                }
            }
        });
    }

    /** 오버레이 1개를 지도에서 내리고 부가 리소스(인포윈도우, 탭 디바운스 기록)를 정리합니다. */
    function detachOverlay(overlay) {
        if (!overlay) return;
        if (overlay.__infoWindow) {
            try { overlay.__infoWindow.close(); } catch (e) {}
            overlay.__infoWindow = null;
        }
        if (typeof lastOverlayTapTime !== 'undefined' && overlay.id !== undefined) {
            lastOverlayTapTime.delete(overlay.id);
        }
        overlay.setMap(null);
    }

    /**
     * ids 에 포함된 오버레이만 남기고 나머지를 제거합니다.
     * ids 가 비어 있으면 전부 제거합니다. exclude 집합에 포함된 id 는 건드리지 않습니다.
     */
    function retainIndexed(index, ids, exclude) {
        try { ids = parseIfString(ids); } catch (e) { /* JSON 이 아니면 원문을 id 로 취급 */ }
        if (typeof ids === 'string') ids = [ids];
        else if (ids != null && !Array.isArray(ids)) ids = [String(ids)];
        const keep = new Set(empty(ids) ? [] : ids);
        for (const [id, overlay] of Array.from(index.entries())) {
            if (keep.has(id)) continue;
            if (exclude && exclude.has(id)) continue;
            detachOverlay(overlay);
            index.delete(id);
        }
    }

    // ---- 마커 이미지 캐시 -------------------------------------------------
    // base64 -> Blob URL, imageSrc -> (크기/오프셋 키 -> kakao.maps.MarkerImage)
    const __blobUrlCache = new Map();
    const __markerImageCache = new Map();
    // Dart 가 사전 등록한 이미지 (key -> base64). 마커 payload 에는 '@key' 만 실려 옵니다.
    const __imageRegistry = new Map();

    /** base64 이미지를 key 로 등록합니다. payload: {key: base64, ...} */
    function registerImages(payload) {
        const images = parseIfString(payload) || {};
        for (const key of Object.keys(images)) {
            __imageRegistry.set(key, images[key]);
        }
    }

    /** '@key' 형태의 참조를 실제 base64 로 되돌립니다. 미등록이면 빈 문자열을 반환합니다. */
    function resolveImageSrc(imageSrc) {
        if (typeof imageSrc === 'string' && imageSrc.charAt(0) === '@') {
            const registered = __imageRegistry.get(imageSrc.substring(1));
            if (registered !== undefined) return registered;
            if (window.__kakaoMapErrors.length < 50) {
                window.__kakaoMapErrors.push('resolveImageSrc: unregistered image key ' + imageSrc);
            }
            return '';
        }
        return imageSrc;
    }

    function base64ToBlobUrl(base64) {
        try {
            let url = __blobUrlCache.get(base64);
            if (url) return url;
            const binary = atob(base64);
            const bytes = new Uint8Array(binary.length);
            for (let i = 0; i < binary.length; i++) {
                bytes[i] = binary.charCodeAt(i);
            }
            url = URL.createObjectURL(new Blob([bytes], { type: 'image/png' }));
            __blobUrlCache.set(base64, url);
            return url;
        } catch (e) {
            if (window.__kakaoMapErrors.length < 50) {
                window.__kakaoMapErrors.push('base64ToBlobUrl: ' + String(e));
            }
            return '';
        }
    }

    /** 동일한 이미지/크기/오프셋 조합은 MarkerImage 인스턴스를 재사용합니다. 이미지를 만들 수 없으면 null 을 반환합니다. */
    function getMarkerImage(imageSrc, imageType, width, height, offsetX, offsetY) {
        let byDims = __markerImageCache.get(imageSrc);
        if (!byDims) {
            byDims = new Map();
            __markerImageCache.set(imageSrc, byDims);
        }
        const key = width + '|' + height + '|' + offsetX + '|' + offsetY;
        let image = byDims.get(key);
        if (image) return image;

        const src = imageType === 'file' ? base64ToBlobUrl(resolveImageSrc(imageSrc)) : imageSrc;
        if (empty(src)) return null;
        const size = new kakao.maps.Size(width, height);
        let offset;
        if (offsetX != null && offsetY != null) {
            offset = new kakao.maps.Point(offsetX, offsetY);
        }
        image = new kakao.maps.MarkerImage(src, size, { offset: offset });
        byDims.set(key, image);
        return image;
    }

    function releaseImageCaches() {
        for (const url of __blobUrlCache.values()) {
            try { URL.revokeObjectURL(url); } catch (e) {}
        }
        __blobUrlCache.clear();
        __markerImageCache.clear();
        __imageRegistry.clear();
    }

    function hexToRgba(ahex) {
        ahex = ahex.substring(1, ahex.length);
        ahex = ahex.split('');

        var r = ahex[1] + ahex[1],
            g = ahex[2] + ahex[2],
            b = ahex[3] + ahex[3],
            a = ahex[0] + ahex[0];

        if (ahex.length === 3) {
            r = ahex[0] + ahex[0];
            g = ahex[1] + ahex[1];
            b = ahex[2] + ahex[2];
            a = 'FF';
        }

        if (ahex.length === 6) {
            r = ahex[0] + ahex[1];
            g = ahex[2] + ahex[3];
            b = ahex[4] + ahex[5];
            a = 'FF';
        }

        if (ahex.length > 6) {
            r = ahex[2] + ahex[3];
            g = ahex[4] + ahex[5];
            b = ahex[6] + ahex[7];
            a = ahex[0] + ahex[1];
        }

        var int_r = parseInt(r, 16),
            int_g = parseInt(g, 16),
            int_b = parseInt(b, 16),
            int_a = parseInt(a, 16);


        int_a = int_a / 255;

        if (int_a < 1 && int_a > 0) int_a = int_a.toFixed(2);

        if (int_a || int_a === 0) {
            return 'rgba(' + int_r + ', ' + int_g + ', ' + int_b + ', ' + int_a + ')';
        }

        return 'rgb(' + int_r + ', ' + int_g + ', ' + int_b + ')';
    }

    /**
     * Convert LatLng coordinates to pixel position on the map
     * @param latitude Number
     * @param longitude Number
     * @returns {x: number, y: number}
     */
    function coordToPixel(latitude, longitude) {
        // dispose() 이후처럼 지도가 없으면 호출자가 구분할 수 있도록 null 을 돌려줍니다.
        if (!map) return $isIOS ? 'null' : null;
        const latLng = new kakao.maps.LatLng(latitude, longitude);
        const point = map.project(latLng);

        let result = {
            x: point.x,
            y: point.y,
        };

        if ($isIOS) {
            result = JSON.stringify(result);
        }

        return result;
    }

    /**
     * Convert pixel position to LatLng coordinates
     * @param x Number - pixel x coordinate
     * @param y Number - pixel y coordinate
     * @returns {latitude: number, longitude: number}
     */
    function pixelToCoord(x, y) {
        if (!map) return $isIOS ? 'null' : null;
        const point = new kakao.maps.Point(x, y);
        const latLng = map.unproject(point);

        let result = {
            latitude: latLng.getLat(),
            longitude: latLng.getLng(),
        };

        if ($isIOS) {
            result = JSON.stringify(result);
        }

        return result;
    }
    ''';
  }
}
