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
        if (typeof value === 'string' && value === '' && value === 'null') return true
        if (Array.isArray(value) && value.length < 1) return true
        if (typeof value === 'object' && value.constructor.name === 'Object' && Object.keys(value).length < 1 && Object.getOwnPropertyNames(value) < 1) return true
        if (typeof value === 'object' && value.constructor.name === 'String' && Object.keys(value).length < 1) return true // new String
        return false
    }

    function hexToRgba(ahex) {
        ahex = ahex.substring(1, ahex.length);
        ahex = ahex.split('');

        var r = ahex[1] + ahex[1],
            g = ahex[2] + ahex[2],
            b = ahex[3] + ahex[3],
            a = ahex[0] + ahex[0];

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
