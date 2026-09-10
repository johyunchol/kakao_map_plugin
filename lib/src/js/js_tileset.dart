/// 커스텀 타일셋 관련 스크립트를 제공합니다.
///
/// 카카오 SDK 는 `kakao.maps.Tileset.add(id, tileset)` 으로 등록한 타일셋을
/// `kakao.maps.MapTypeId[id]` 로 노출합니다. 여기서는 등록한 타일셋을 따로
/// 기억해 두었다가 ID 로 지도 타입/오버레이 전환에 사용합니다.
class JsTileset {
  /// 타일셋 관련 함수들의 스크립트를 반환합니다.
  static String getScript({required bool isIOS}) {
    return '''
    // 프로토타입 없는 객체를 써서 '__proto__' 같은 ID 가 들어와도 레지스트리가 오염되지 않게 합니다.
    /** 등록한 타일셋. id -> kakao.maps.Tileset */
    const __tilesets = Object.create(null);
    /** 타일 함수 호출 횟수. id -> number (디버깅/테스트용) */
    const __tilesetStats = Object.create(null);
    /** 현재 지도 위에 겹쳐 올린 타일셋. id -> true */
    const __tilesetOverlays = Object.create(null);

    function __pushTilesetError(message) {
        if (window.__kakaoMapErrors && window.__kakaoMapErrors.length < 50) {
            window.__kakaoMapErrors.push(message);
        }
    }

    /** 문자열로 받은 함수 원문을 실제 함수로 만듭니다. 실패하면 null 입니다. */
    function __compileTileFunction(source, label) {
        try {
            const fn = (new Function('return (' + source + ');'))();
            if (typeof fn !== 'function') throw new Error('함수가 아닙니다');
            return fn;
        } catch (e) {
            __pushTilesetError('TILESET_' + label + '_INVALID: ' + String(e));
            return null;
        }
    }

    /** {x} {y} {z} 자리표시자를 치환하는 주소 함수를 만듭니다. */
    function __templateUrlFunction(template) {
        return function (x, y, z) {
            return template
                .replace(/\\{x\\}/g, String(x))
                .replace(/\\{y\\}/g, String(y))
                .replace(/\\{z\\}/g, String(z));
        };
    }

    /** 호출 횟수를 세는 래퍼입니다. */
    function __countTileCalls(id, fn) {
        return function (x, y, z) {
            __tilesetStats[id] = (__tilesetStats[id] || 0) + 1;
            return fn(x, y, z);
        };
    }

    /** 타일셋을 만들어 SDK 에 등록합니다. */
    function addTileset(payload) {
        const raw = parseIfString(payload);
        if (!raw || !raw.id) return;
        const id = String(raw.id);

        // ROADMAP 처럼 SDK 가 이미 쓰는 지도 타입 ID 를 덮어쓰면 기본 지도가 망가지므로 거부합니다.
        if (!__tilesets[id] && kakao.maps.MapTypeId[id] !== undefined) {
            __pushTilesetError('TILESET_ID_RESERVED: ' + id + ' 는 SDK 지도 타입 ID 와 겹칩니다.');
            return;
        }

        const copyright = (raw.copyright || []).map(function (c) {
            return new kakao.maps.TilesetCopyright(
                c.msg || '', c.shortMsg || c.msg || '', c.minZoom || 0);
        });
        const minZoom = raw.minZoom == null ? 0 : raw.minZoom;
        const maxZoom = raw.maxZoom == null ? 14 : raw.maxZoom;

        let tileset;
        if (raw.tileFunction) {
            const getTile = __compileTileFunction(raw.tileFunction, 'GET_TILE');
            if (!getTile) return;
            tileset = new kakao.maps.Tileset({
                width: raw.width,
                height: raw.height,
                getTile: __countTileCalls(id, getTile),
                copyright: copyright,
                dark: !!raw.dark,
                minZoom: minZoom,
                maxZoom: maxZoom
            });
        } else {
            let urlFunc = null;
            if (raw.urlFunction) {
                urlFunc = __compileTileFunction(raw.urlFunction, 'URL_FUNC');
            } else if (raw.urlTemplate) {
                urlFunc = __templateUrlFunction(raw.urlTemplate);
            }
            if (!urlFunc) return;
            // 문서에 있는 위치 인자 생성자를 그대로 사용합니다.
            tileset = new kakao.maps.Tileset(
                raw.width, raw.height, __countTileCalls(id, urlFunc),
                copyright, !!raw.dark, minZoom, maxZoom);
        }

        // 이미 화면에 쓰고 있던 타일셋을 다시 등록하면 내렸다가 새 타일셋으로 다시 올립니다.
        // 같은 ID 로 setMapTypeId 를 다시 불러도 SDK 가 변화로 보지 않을 수 있어서 명시적으로 갈아끼웁니다.
        const previous = __tilesets[id];
        const wasBase = !!previous && !!map && map.getMapTypeId() === kakao.maps.MapTypeId[id];
        const wasOverlay = !!previous && !!__tilesetOverlays[id];
        if (wasOverlay) map.removeOverlayMapTypeId(kakao.maps.MapTypeId[id]);
        if (wasBase) map.setMapTypeId(kakao.maps.MapTypeId.ROADMAP);

        __tilesetStats[id] = 0;
        kakao.maps.Tileset.add(id, tileset);
        __tilesets[id] = tileset;

        if (wasBase) map.setMapTypeId(kakao.maps.MapTypeId[id]);
        if (wasOverlay) map.addOverlayMapTypeId(kakao.maps.MapTypeId[id]);
    }

    function __tilesetTypeId(id) {
        const typeId = kakao.maps.MapTypeId[id];
        if (typeId === undefined || !__tilesets[id]) {
            __pushTilesetError('TILESET_NOT_FOUND: ' + id + ' (addTileset 을 먼저 호출하세요)');
            return undefined;
        }
        return typeId;
    }

    /** 등록한 타일셋을 기본 지도 타입으로 사용합니다. */
    function setTileset(id) {
        const typeId = __tilesetTypeId(id);
        if (typeId === undefined) return;
        map.setMapTypeId(typeId);
    }

    /** 등록한 타일셋을 지도 위에 겹쳐 올립니다. */
    function addOverlayTileset(id) {
        const typeId = __tilesetTypeId(id);
        if (typeId === undefined) return;
        map.addOverlayMapTypeId(typeId);
        __tilesetOverlays[id] = true;
    }

    /** 겹쳐 올린 타일셋을 내립니다. */
    function removeOverlayTileset(id) {
        const typeId = __tilesetTypeId(id);
        if (typeId === undefined) return;
        map.removeOverlayMapTypeId(typeId);
        delete __tilesetOverlays[id];
    }

    /** 현재 기본 지도 타입이 등록한 타일셋이면 그 ID 를, 아니면 null 을 돌려줍니다. */
    function getActiveTilesetId() {
        let result = { tilesetId: null };
        if (map) {
            const current = map.getMapTypeId();
            for (const id in __tilesets) {
                if (kakao.maps.MapTypeId[id] === current) {
                    result.tilesetId = id;
                    break;
                }
            }
        }
        return $isIOS ? JSON.stringify(result) : result;
    }
    ''';
  }
}
