part of '../../kakao_map_plugin.dart';

class KakaoMap extends StatefulWidget {
  final MapCreateCallback? onMapCreated;
  final OnMapTap? onMapTap;
  final OnMarkerTap? onMarkerTap;
  final OnMarkerClustererTap? onMarkerClustererTap;
  final OnMapDoubleTap? onMapDoubleTap;
  final OnCustomOverlayTap? onCustomOverlayTap;
  final OnCameraIdle? onCameraIdle;
  final OnDragChangeCallback? onDragChangeCallback;
  final OnMarkerDragChangeCallback? onMarkerDragChangeCallback;
  final OnZoomChangeCallback? onZoomChangeCallback;
  final OnCenterChangeCallback? onCenterChangeCallback;
  final OnBoundsChangeCallback? onBoundsChangeCallback;
  final OnTilesLoadedCallback? onTilesLoadedCallback;
  final bool? mapTypeControl;
  final ControlPosition mapTypeControlPosition;
  final bool? zoomControl;
  final ControlPosition zoomControlPosition;
  final int minLevel;
  final int currentLevel;
  final int maxLevel;
  final LatLng? center;

  final List<Polyline>? polylines;
  final List<Circle>? circles;
  final List<Rectangle>? rectangles;
  final List<Polygon>? polygons;
  final List<Marker>? markers;
  final List<CustomOverlay>? customOverlays;
  final Clusterer? clusterer;

  const KakaoMap({
    super.key,
    this.onMapCreated,
    this.onMapTap,
    this.onMarkerTap,
    this.onMarkerClustererTap,
    this.onMapDoubleTap,
    this.onCustomOverlayTap,
    this.onDragChangeCallback,
    this.onMarkerDragChangeCallback,
    this.onCameraIdle,
    this.onZoomChangeCallback,
    this.onCenterChangeCallback,
    this.onBoundsChangeCallback,
    this.onTilesLoadedCallback,
    this.mapTypeControl = false,
    this.mapTypeControlPosition = ControlPosition.topRight,
    this.zoomControl = false,
    this.zoomControlPosition = ControlPosition.right,
    this.minLevel = 0,
    this.currentLevel = 3,
    this.maxLevel = 25,
    this.center,
    this.polylines,
    this.circles,
    this.rectangles,
    this.polygons,
    this.markers,
    this.clusterer,
    this.customOverlays,
  });

  @override
  State<KakaoMap> createState() => _KakaoMapState();
}

class _KakaoMapState extends State<KakaoMap> {
  late final KakaoMapController _mapController;

  @override
  void initState() {
    super.initState();

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000));
    addJavaScriptChannels(controller);
    controller.loadHtmlString(_loadMap(),
        baseUrl: AuthRepository.instance.baseUrl);

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _mapController = KakaoMapController(controller);
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
      controller: _mapController.webViewController,
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory(() => EagerGestureRecognizer()),
      },
    );
  }

  String _loadMap() {
    return _htmlWrapper('''<script>
  let map = null;
  let geocoder = null;
  let places = null;
  let polylines = [];
  let circles = [];
  let rectangles = [];
  let polygons = [];
  let markers = [];
  let customOverlays = [];
  let clusterer = null;
  const defaultCenter = new kakao.maps.LatLng(33.450701, 126.570667);

  window.onload = function () {
    const container = document.getElementById('map');
    let center = defaultCenter;
    if (${widget.center != null}) {
      center = new kakao.maps.LatLng(${widget.center?.latitude}, ${widget.center?.longitude});
    }

    const options = {
      center: center,
      level: ${widget.currentLevel}    };

    map = new kakao.maps.Map(container, options);
    geocoder = new kakao.maps.services.Geocoder();
    places = new kakao.maps.services.Places();

    if (${widget.mapTypeControl}) {
      const mapTypeControl = new kakao.maps.MapTypeControl();
      map.addControl(mapTypeControl, ${widget.mapTypeControlPosition.id});
    }

    if (${widget.zoomControl}) {
      const zoomControl = new kakao.maps.ZoomControl()
      map.addControl(zoomControl, ${widget.zoomControlPosition.id});
    }

    map.setMinLevel(${widget.minLevel});

    map.setMaxLevel(${widget.maxLevel});

    if (${widget.onCenterChangeCallback != null}) {
      // 중심 좌표가 변경되면 발생한다.
      kakao.maps.event.addListener(map, 'center_changed', function () {
        const latLng = map.getCenter();

        const data = {
          latitude: latLng.getLat(),
          longitude: latLng.getLng(),
          zoomLevel: map.getLevel(),
        }

        centerChanged.postMessage(JSON.stringify(data));
      });
    }

    if (${widget.onZoomChangeCallback != null}) {
      // 확대 수준이 변경되기 직전 발생한다.
      kakao.maps.event.addListener(map, 'zoom_start', function () {
        const level = map.getLevel();
        zoomStart.postMessage(JSON.stringify({zoomLevel: level}));
      });

      // 확대 수준이 변경되면 발생한다.
      kakao.maps.event.addListener(map, 'zoom_changed', function () {
        const level = map.getLevel();
        zoomChanged.postMessage(JSON.stringify({zoomLevel: level}));
      });
    }

    if (${widget.onBoundsChangeCallback != null}) {
      // 지도 영역이 변경되면 발생한다.
      kakao.maps.event.addListener(map, 'bounds_changed', function () {
        const bounds = getBounds();
        boundsChanged.postMessage(JSON.stringify(bounds));
      });
    }

    if (${widget.onMapTap != null}) {
      // 지도를 클릭하면 발생한다.
      kakao.maps.event.addListener(map, 'click', function (mouseEvent) {
        // 클릭한 위도, 경도 정보를 가져옵니다
        const latLng = mouseEvent.latLng;

        const clickLatLng = {
          latitude: latLng.getLat(),
          longitude: latLng.getLng(),
          zoomLevel: map.getLevel(),
        }

        onMapTap.postMessage(JSON.stringify(clickLatLng));
      });
    }

    // 지도를 더블클릭하면 발생한다.
    kakao.maps.event.addListener(map, 'dblclick', function (mouseEvent) {
      const latLng = mouseEvent.latLng;

      const clickLatLng = {
        latitude: latLng.getLat(),
        longitude: latLng.getLng(),
        zoomLevel: map.getLevel(),
      }

      onMapDoubleTap.postMessage(JSON.stringify(clickLatLng));
    });

    if (${widget.onDragChangeCallback != null}) {
      // 마우스 드래그로 지도 이동이 완료되었을 때 마지막 파라미터로 넘어온 함수를 호출하도록 이벤트를 등록합니다
      kakao.maps.event.addListener(map, 'dragstart', function () {
        const latLng = map.getCenter();

        const result = {
          latitude: latLng.getLat(),
          longitude: latLng.getLng(),
          zoomLevel: map.getLevel(),
        }

        dragStart.postMessage(JSON.stringify(result));
      });

      kakao.maps.event.addListener(map, 'drag', function () {
        const latLng = map.getCenter();

        const result = {
          latitude: latLng.getLat(),
          longitude: latLng.getLng(),
          zoomLevel: map.getLevel(),
        }

        drag.postMessage(JSON.stringify(result));
      });

      kakao.maps.event.addListener(map, 'dragend', function () {
        const latLng = map.getCenter();

        const result = {
          latitude: latLng.getLat(),
          longitude: latLng.getLng(),
          zoomLevel: map.getLevel(),
        }

        dragEnd.postMessage(JSON.stringify(result));
      });
    }

    if (${widget.onCameraIdle != null}) {
      // 마우스 드래그로 지도 이동이 완료되었을 때 마지막 파라미터로 넘어온 함수를 호출하도록 이벤트를 등록합니다
      kakao.maps.event.addListener(map, 'idle', function () {
        const latLng = map.getCenter();

        const idleLatLng = {
          latitude: latLng.getLat(),
          longitude: latLng.getLng(),
          zoomLevel: map.getLevel(),
        }

        cameraIdle.postMessage(JSON.stringify(idleLatLng));
      });
    }

    if (${widget.onTilesLoadedCallback != null}) {
      // 확대수준이 변경되거나 지도가 이동했을때 타일 이미지 로드가 모두 완료되면 발생한다.
      // 지도이동이 미세하기 일어나 타일 이미지 로드가 일어나지 않은경우 발생하지 않는다.
      kakao.maps.event.addListener(map, 'tilesloaded', function () {
        const latLng = map.getCenter();

        const result = {
          latitude: latLng.getLat(),
          longitude: latLng.getLng(),
          zoomLevel: map.getLevel(),
        }

        tilesLoaded.postMessage(JSON.stringify(result));
      });
    }

    map.setCopyrightPosition(kakao.maps.CopyrightPosition.BOTTOMRIGHT, false)

    onMapCreated.postMessage({"test": 1});
  }


  function clearPolyline() {
    for (let i = 0; i < polylines.length; i++) {
      polylines[i].setMap(null);
    }

    polylines = [];
  }

  function clearCircle() {
    for (let i = 0; i < circles.length; i++) {
      circles[i].setMap(null);
    }

    circles = [];
  }
  
  function clearRectangle() {
    for (let i = 0; i < rectangles.length; i++) {
      rectangles[i].setMap(null);
    }

    rectangles = [];
  }

  function clearPolygon() {
    for (let i = 0; i < polygons.length; i++) {
      polygons[i].setMap(null);
    }

    polygons = [];
  }

  function clearMarker() {
    for (let i = 0; i < markers.length; i++) {
      markers[i].setMap(null);
    }

    markers = [];
  }

  function clearMarkerClusterer() {
    if (!clusterer) return;

    clusterer.clear();
  }


  function clearCustomOverlay() {
    for (let i = 0; i < customOverlays.length; i++) {
      customOverlays[i].setMap(null);
    }

    customOverlays = [];
  }

  function clear() {
    clearPolyline();
    clearCircle();
    clearPolygon();
    clearMarker();
    clearCustomOverlay();
  }

  function addPolyline(callId, points, color, opacity, width, stroke, endArrow, zIndex) {
    let list = JSON.parse(points);
    let paths = [];
    for (let i = 0; i < list.length; i++) {
      paths.push(new kakao.maps.LatLng(list[i].latitude, list[i].longitude));
    }

    opacity = Number(opacity)
    width = Number(width)
    endArrow = endArrow === 'true'

    // 지도에 표시할 선을 생성합니다
    let polyline = new kakao.maps.Polyline({
      path: paths,
      strokeWeight: width,
      strokeColor: color,
      strokeOpacity: opacity,
      strokeStyle: stroke,
      endArrow: endArrow,
      zIndex: zIndex,
    });


    polylines.push(polyline);

    // 지도에 선을 표시합니다
    polyline.setMap(map);
  }

  function addCircle(callId, center, radius, strokeWeight, strokeColor, strokeOpacity = 1, strokeStyle = 'solid', fillColor = '#FFFFFF', fillOpacity = 0, zIndex) {
    center = JSON.parse(center);

    // 지도에 표시할 원을 생성합니다
    let circle = new kakao.maps.Circle({
      center: new kakao.maps.LatLng(center.latitude, center.longitude),  // 원의 중심좌표 입니다
      radius: radius, // 미터 단위의 원의 반지름입니다
      strokeWeight: strokeWeight, // 선의 두께입니다
      strokeColor: strokeColor, // 선의 색깔입니다
      strokeOpacity: strokeOpacity, // 선의 불투명도 입니다 1에서 0 사이의 값이며 0에 가까울수록 투명합니다
      strokeStyle: strokeStyle, // 선의 스타일 입니다
      fillColor: fillColor, // 채우기 색깔입니다
      fillOpacity: fillOpacity,  // 채우기 불투명도 입니다
      zIndex: zIndex,
    });

    circles.push(circle);

    // 지도에 원을 표시합니다
    circle.setMap(map);
  }

  function addRectangle(callId, rectangleBounds, strokeWeight, strokeColor, strokeOpacity = 1, strokeStyle = 'solid', fillColor = '#FFFFFF', fillOpacity = 0, zIndex) {
    rectangleBounds = JSON.parse(rectangleBounds);

    // 지도에 표시할 원을 생성합니다
    let rectangle = new kakao.maps.Rectangle({
      bounds: new kakao.maps.LatLngBounds(
        new kakao.maps.LatLng(rectangleBounds['sw'].latitude, rectangleBounds['sw'].longitude),
        new kakao.maps.LatLng(rectangleBounds['ne'].latitude, rectangleBounds['ne'].longitude)
        ),
      strokeWeight: strokeWeight, // 선의 두께입니다
      strokeColor: strokeColor, // 선의 색깔입니다
      strokeOpacity: strokeOpacity, // 선의 불투명도 입니다 1에서 0 사이의 값이며 0에 가까울수록 투명합니다
      strokeStyle: strokeStyle, // 선의 스타일 입니다
      fillColor: fillColor, // 채우기 색깔입니다
      fillOpacity: fillOpacity, // 채우기 불투명도 입니다
      zIndex: zIndex,
    });

    rectangles.push(rectangle);

    // 지도에 원을 표시합니다
    rectangle.setMap(map);
  }

  function addPolygon(callId, points, holes, strokeWeight, strokeColor, strokeOpacity = 1, strokeStyle = 'solid', fillColor = '#FFFFFF', fillOpacity = 0, zIndex) {
    points = JSON.parse(points);
    let paths = [];
    for (let i = 0; i < points.length; i++) {
      paths.push(new kakao.maps.LatLng(points[i].latitude, points[i].longitude));
    }

    holes = JSON.parse(holes);
    if (!empty(holes)) {
      let holePaths = [];

      for (let i = 0; i < holes.length; i++) {
        let array = [];
        for (let j = 0; j < holes[i].length; j++) {
          array.push(new kakao.maps.LatLng(holes[i][j].latitude, holes[i][j].longitude));
        }
        holePaths.push(array);
      }

      return addPolygonWithHole(callId, paths, holePaths, strokeWeight, strokeColor, strokeOpacity, strokeStyle, fillColor, fillOpacity, zIndex);
    }

    return addPolygonWithoutHole(callId, paths, strokeWeight, strokeColor, strokeOpacity, strokeStyle, fillColor, fillOpacity, zIndex);
  }

  function addPolygonWithoutHole(callId, points, strokeWeight, strokeColor, strokeOpacity = 1, strokeStyle = 'solid', fillColor = '#FFFFFF', fillOpacity = 0, zIndex) {
    // 지도에 표시할 다각형을 생성합니다
    let polygon = new kakao.maps.Polygon({
      path: points, // 그려질 다각형의 좌표 배열입니다
      strokeWeight: strokeWeight, // 선의 두께입니다
      strokeColor: strokeColor, // 선의 색깔입니다
      strokeOpacity: strokeOpacity, // 선의 불투명도 입니다 1에서 0 사이의 값이며 0에 가까울수록 투명합니다
      strokeStyle: strokeStyle, // 선의 스타일입니다
      fillColor: fillColor, // 채우기 색깔입니다
      fillOpacity: fillOpacity, // 채우기 불투명도 입니다
      zIndex: zIndex, 
    });

    polygons.push(polygon);

    // 지도에 다각형을 표시합니다
    polygon.setMap(map);
  }

  function addPolygonWithHole(callId, points, holes, strokeWeight, strokeColor, strokeOpacity = 1, strokeStyle = 'solid', fillColor = '#FFFFFF', fillOpacity = 0, zIndex) {
    // 다각형을 생성하고 지도에 표시합니다
    let polygon = new kakao.maps.Polygon({
      map: map,
      path: [points, ...holes], // 좌표 배열의 배열로 하나의 다각형을 표시할 수 있습니다
      strokeWeight: strokeWeight, // 선의 두께입니다
      strokeColor: strokeColor, // 선의 색깔입니다
      strokeOpacity: strokeOpacity, // 선의 불투명도 입니다 1에서 0 사이의 값이며 0에 가까울수록 투명합니다
      fillColor: fillColor, // 채우기 색깔입니다
      fillOpacity: fillOpacity, // 채우기 불투명도 입니다
      zIndex: zIndex,
    });

    polygons.push(polygon);
  }

  function addMarker(markerId, latLng, draggable, width = 24, height = 30, offsetX = null, offsetY = null, imageSrc = '', infoWindowText = '', infoWindowRemovable = true, infoWindowFirstShow, zIndex) {

    latLng = JSON.parse(latLng);
    let markerPosition = new kakao.maps.LatLng(latLng.latitude, latLng.longitude); // 마커가 표시될 위치입니다

    // 마커를 생성합니다
    let marker = new kakao.maps.Marker({
      position: markerPosition,
    });

    marker['id'] = markerId;

    marker.setDraggable(draggable);
    
    if (zIndex) {
      marker.setZIndex(zIndex);
    }

    // 마커가 지도 위에 표시되도록 설정합니다
    marker.setMap(map);

    if (imageSrc !== '' && imageSrc !== 'null') {
      let imageSize = new kakao.maps.Size(width, height); // 마커이미지의 크기입니다

      let offset;
      if (offsetX && offsetY) {
        offset = new kakao.maps.Point(offsetX, offsetY);
      }
      let imageOption = {offset: offset}; // 마커이미지의 옵션입니다. 마커의 좌표와 일치시킬 이미지 안에서의 좌표를 설정합니다.

      let markerImage = new kakao.maps.MarkerImage(imageSrc, imageSize, imageOption);
      marker.setImage(markerImage);
    }

    markers.push(marker);

    let infoWindow = null
    if (infoWindowText !== '' && infoWindowText !== 'null') {

      // 인포윈도우를 생성하고 지도에 표시합니다
      infoWindow = new kakao.maps.InfoWindow({
        position: markerPosition,
        content: infoWindowText,
        removable: infoWindowRemovable
      });
    }

    if (infoWindowFirstShow) {
      if (infoWindow != null) {
        infoWindow.open(map, marker);
      }
    }

    if (draggable && ${widget.onMarkerDragChangeCallback != null}) {

      kakao.maps.event.addListener(marker, 'dragstart', function () {
        let latLng = marker.getPosition();

        const resultLatLng = {
          markerId: marker.id,
          latitude: latLng.getLat(),
          longitude: latLng.getLng(),
          zoomLevel: map.getLevel(),
          drag: 'dragstart'
        }

        onMarkerDragChangeCallback.postMessage(JSON.stringify(resultLatLng));
      })

      kakao.maps.event.addListener(marker, 'dragend', function () {
        let latLng = marker.getPosition();

        const resultLatLng = {
          markerId: marker.id,
          latitude: latLng.getLat(),
          longitude: latLng.getLng(),
          zoomLevel: map.getLevel(),
          drag: 'dragend'
        }

        onMarkerDragChangeCallback.postMessage(JSON.stringify(resultLatLng));
      })
    }

    if (${widget.onMarkerTap != null}) {
      kakao.maps.event.addListener(marker, 'click', function () {
        if (infoWindow != null) {
          infoWindow.open(map, marker);
        }

        // 클릭한 위도, 경도 정보를 가져옵니다
        let latLng = marker.getPosition();

        const clickLatLng = {
          markerId: marker.id,
          latitude: latLng.getLat(),
          longitude: latLng.getLng(),
          zoomLevel: map.getLevel(),
        }

        onMarkerTap.postMessage(JSON.stringify(clickLatLng));

      });
    }
  }

  function setMarkerDraggable(markerId, draggable) {
    let marker = null;
    for (let i = 0; i < markers.length; i++) {
      if (markerId === markers[i].markerId) {
        marker = markers[i];
        break;
      }
    }

    if (marker != null) {
      marker.setDraggable(draggable);
    }
  }

  function addMarkerClusterer(markerList, gridSize = 60, averageCenter = true, disableClickZoom = true, minLevel = 10, minClusterSize = 2, texts, calculator, styles) {
    markerList = JSON.parse(markerList);
    markerList.map(function (marker) {
      addMarker(
        marker.markerId,
        JSON.stringify(marker.latLng),
        marker?.draggable,
        marker?.width,
        marker?.height,
        marker?.offsetX,
        marker?.offsetY,
        marker?.imageSrc,
        marker?.infoWindowText,
        marker?.infoWindowRemovable,
        marker?.infoWindowFirstShow,
        marker?.zIndex,
        )
    })

    clusterer = new kakao.maps.MarkerClusterer({
      map: map,
      gridSize: gridSize,
      averageCenter: averageCenter,
      minLevel: minLevel,
      disableClickZoom: true,
    });

    clusterer.setMinClusterSize(minClusterSize);

    texts = JSON.parse(texts)
    if (texts) {
      clusterer.setTexts(texts)
    }

    calculator = JSON.parse(calculator)
    if (calculator) {
      clusterer.setCalculator(calculator)
    }

    styles = JSON.parse(styles)
    if (styles) {
      styles = styles.map(function (style) {
        return {...style, background: hexToRgba(style.background), color: hexToRgba(style.color)}
      })

      clusterer.setStyles(styles)
    }

    clusterer.addMarkers(markers);


    if (${widget.onMarkerClustererTap != null}) {
      kakao.maps.event.addListener(clusterer, 'clusterclick', function (cluster) {
        // 클릭한 위도, 경도 정보를 가져옵니다
        let latLng = cluster.getCenter();

        const clickLatLng = {
          latitude: latLng.getLat(),
          longitude: latLng.getLng(),
          zoomLevel: map.getLevel(),
        }

        onMarkerClustererTap.postMessage(JSON.stringify(clickLatLng))
      });
    }
  }

  function getMarkerClustererStyles(styles) {
    styles = JSON.parse(styles)

    styles = styles?.map(function (style) {
      return removeUndefinedValue(style)
    })

    return styles
  }

  function removeUndefinedValue(obj) {
    const newObj = {}; // 빈객체를 만들어놓고

    Object.keys(obj).forEach(key => {
      if (obj[key]) {
        newObj[key] = obj[key]
      }
    });

    return newObj;
  }

  function addCustomOverlay(customOverlayId, latLng, content, isClickable, xAnchor, yAnchor, zIndex) {
    latLng = JSON.parse(latLng);
    let markerPosition = new kakao.maps.LatLng(latLng.latitude, latLng.longitude); // 마커가 표시될 위치입니다
    isClickable = Boolean(isClickable);

    content = '<div id="' + customOverlayId + '">' + content + '</div>'
    if (${widget.onCustomOverlayTap != null}) {
      content =
        '<div id="' + customOverlayId +
        '" onclick="addCustomOverlayListener(`' + customOverlayId +
        '`, `' + latLng.latitude +
        '`, `' + latLng.longitude +
        '`)">' + content + '</div>';
    }

    let customOverlay = new kakao.maps.CustomOverlay({
      map: map,
      clickable: isClickable,
      content: content,
      position: markerPosition,
      xAnchor: xAnchor,
      yAnchor: yAnchor,
      zIndex: zIndex,
    });
    
    customOverlay['id'] = customOverlayId;
    
    customOverlays.push(customOverlay);

    customOverlay.setMap(map);
  }

  function addCustomOverlayListener(customOverlayId, latitude, longitude) {
    // 클릭한 위도, 경도 정보를 가져옵니다
    let latLng = new kakao.maps.LatLng(latitude, longitude); // 마커가 표시될 위치입니다

    const clickLatLng = {
      customOverlayId: customOverlayId,
      latitude: latLng.getLat(),
      longitude: latLng.getLng(),
    }

    onCustomOverlayTap.postMessage(JSON.stringify(clickLatLng));
  }


  function showInfoWindow(marker, latitude, longitude, contents = '', infoWindowRemovable) {
    let iwPosition = new kakao.maps.LatLng(latitude, longitude);

    // 인포윈도우를 생성하고 지도에 표시합니다
    let infoWindow = new kakao.maps.InfoWindow({
      map: map, // 인포윈도우가 표시될 지도
      position: iwPosition,
      content: contents,
      removable: infoWindowRemovable
    });

    infoWindow.open(map, marker);
  }

  /**
   * 지도의 중심 좌표를 설정한다.
   * @param latitude Number
   * @param longitude Number
   */
  function setCenter(latitude, longitude) {
    map.setCenter(new kakao.maps.LatLng(latitude, longitude));
  }

  /**
   * 지도의 중심 좌표를 반환한다.
   */
  function getCenter() {
    const center = map.getCenter();

    let result = {
      latitude: center.getLat(),
      longitude: center.getLng(),
    };

    if (${Platform.isIOS}) {
      result = JSON.stringify(result);
    }

    return result;
  }

  /**
   * 지도의 확대 수준을 설정한다.
   * MapTypeId 의 종류에 따라 설정 범위가 다르다.
   * SKYVIEW, HYBRID 일 경우 0 ~ 14, ROADMAP 일 경우 1 ~ 14.
   * @param level
   * @param options
   */
  function setLevel(level, options) {
    if (!options) {
      return map.setLevel(level);
    }
    
    let levelOption = {}
    
    console.log(options);
    options = JSON.parse(options);
    
    if (options?.animate) {
      levelOption['animate'] = options.animate;
    }
    
    if (options?.anchor) {
      levelOption['anchor'] = new kakao.maps.LatLng(options?.anchor?.latitude, options?.anchor?.longitude);
    }
    
    console.log(JSON.stringify(levelOption));
  
    map.setLevel(level, levelOption);
  }

  /**
   * 지도의 확대 수준을 반환한다.
   */
  function getLevel() {
    let result = {
      level: map.getLevel()
    };

    if (${Platform.isIOS}) {
      result = JSON.stringify(result);
    }

    return result;
  }

  /**
   * 지도의 타입을 설정한다.
   * 베이스타입 : ROADMAP, SKYVIEW, HYBRID
   */
  function setMapTypeId(mapTypeId) {
    map.setMapTypeId(mapTypeId);
  }

  function getMapTypeId() {
    let result = {
      mapTypeId: map.getMapTypeId()
    };

    if (${Platform.isIOS}) {
      result = JSON.stringify(result);
    }

    return result;
  }

  /**
   * 지도에 로드뷰, 교통정보 등의 오버레이 타입의 타일 이미지를 올린다.
   * 로드뷰 타일 이미지를 추가할 경우 RoadviewOverlay 와 동일한 기능을 수행한다.
   * 오버레이타입: OVERLAY, TERRAIN, TRAFFIC, BICYCLE, bicycleHybrid, USE_DISTRICT
   */
  function addOverlayMapTypeId(mapTypeId) {
    map.addOverlayMapTypeId(mapTypeId);
  }

  /**
   * 지도에 로드뷰, 교통정보 등의 오버레이 타입의 타일 이미지를 삭제한다.
   */
  function removeOverlayMapTypeId(mapTypeId) {
    map.removeOverlayMapTypeId(mapTypeId);
  }

  function setDraggable(draggable) {
    map.setDraggable(draggable);
  }

  function getDraggable() {
    return map.getDraggable();
  }

  function setZoomable(zoomable) {
    map.setZoomable(zoomable);
  }

  function getZoomable() {
    return map.getZoomable();
  }

  function setBounds(bounds, paddingTop = 0, paddingRight = 0, paddingBottom = 0, paddingLeft = 0) {
    map.setBounds(bounds, paddingTop, paddingRight, paddingBottom, paddingLeft);
  }

  function getBounds() {
    let bounds = map.getBounds();
    const sw = {
      latitude: bounds.getSouthWest().getLat(),
      longitude: bounds.getSouthWest().getLng(),
    };

    const ne = {
      latitude: bounds.getNorthEast().getLat(),
      longitude: bounds.getNorthEast().getLng(),
    };

    let result = {
      sw: sw,
      ne: ne
    };

    if (${Platform.isIOS}) {
      result = JSON.stringify(result);
    }

    return result;
  }

  function setMinLevel(minLevel) {
    map.setMinLevel(minLevel);
  }

  function setMaxLevel(maxLevel) {
    map.setMaxLevel(maxLevel);
  }

  /**
   * 중심 좌표를 지정한 픽셀 만큼 부드럽게 이동한다.
   * 만약 이동할 거리가 지도 화면의 크기보다 클 경우 애니메이션 없이 이동한다.
   * @param dx Number
   * @param dy Number
   */
  function panBy(dx, dy) {
    map.panBy(dx, dy);
  }

  /**
   * 중심 좌표를 지정한 좌표 또는 영역으로 부드럽게 이동한다. 필요하면 확대 또는 축소도 수행한다.
   * 만약 이동할 거리가 지도 화면의 크기보다 클 경우 애니메이션 없이 이동한다.
   * 첫 번째 매개변수로 좌표나 영역을 지정할 수 있으며,
   * 영역(bounds)을 지정한 경우에만 padding 옵션이 유효하다.
   * padding 값을 지정하면 그 값만큼의 상하좌우 픽셀이 확보된 영역으로 계산되어 이동한다.
   * padding의 기본값은 32.
   * @param latitude
   * @param longitude
   * @param padding Number
   */
  function panTo(latitude, longitude, padding = 32) {
    // 이동할 위도 경도 위치를 생성합니다
    let moveLatLon = new kakao.maps.LatLng(latitude, longitude);

    // 지도 중심을 부드럽게 이동시킵니다
    // 만약 이동할 거리가 지도 화면보다 크면 부드러운 효과 없이 이동합니다
    map.panTo(moveLatLon);
  }

  function fitBounds(points) {
    let list = JSON.parse(points);

    let bounds = new kakao.maps.LatLngBounds();
    for (let i = 0; i < list.length; i++) {
      // LatLngBounds 객체에 좌표를 추가합니다
      bounds.extend(new kakao.maps.LatLng(list[i].latitude, list[i].longitude));
    }

    map.setBounds(bounds);
  }

  /**
   * 지도에 컨트롤을 추가한다.
   * @param isShowZoomControl boolean
   */
  function setZoomControl(isShowZoomControl) {
    if (!isShowZoomControl) return;

    const zoomControl = new kakao.maps.ZoomControl();
    map.addControl(zoomControl, kakao.maps.ControlPosition.RIGHT);
  }

  function relayout() {
    map.relayout();
  }

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
    
    places.keywordSearch(request.keyword, function(result, status) {
      if (typeof result === 'object') {
        keywordSearchCallback.postMessage(JSON.stringify(result));
      }
    }, options);
  }
  
  // function categorySearch(category, latitude, longitude) {
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
    
    places.categorySearch(request.categoryGroupCode, function(result, status) {
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
    
    geocoder.addressSearch(request.addr, function(result, status) {
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
 
    geocoder.coord2Address(request.longitude, request.latitude, function(result, status) {
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
 
    geocoder.coord2RegionCode(request.longitude, request.latitude, function(result, status) {
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
     
    geocoder.transCoord(request.x, request.y, function(result, status) {
      if (typeof result === 'object') {
        transCoordCallback.postMessage(JSON.stringify(result));
      }
    }, options)
  }
</script>
    ''');
  }

  @override
  void didUpdateWidget(KakaoMap oldWidget) {
    _mapController.addPolyline(polylines: widget.polylines);
    _mapController.addCircle(circles: widget.circles);
    _mapController.addRectangle(rectangles: widget.rectangles);
    _mapController.addPolygon(polygons: widget.polygons);
    _mapController.addMarker(markers: widget.markers);
    _mapController.addMarkerClusterer(clusterer: widget.clusterer);
    _mapController.addCustomOverlay(customOverlays: widget.customOverlays);
    super.didUpdateWidget(oldWidget);
  }

  void addJavaScriptChannels(WebViewController controller) {
    controller
      ..addJavaScriptChannel('onMapCreated',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onMapCreated != null) {
          widget.onMapCreated!(_mapController);
        }
      })
      ..addJavaScriptChannel('onMapTap',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onMapTap != null) {
          widget.onMapTap!(LatLng.fromJson(jsonDecode(result.message)));
        }
      })
      ..addJavaScriptChannel('onMapDoubleTap',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onMapDoubleTap != null) {
          widget.onMapDoubleTap!(LatLng.fromJson(jsonDecode(result.message)));
        }
      })
      ..addJavaScriptChannel('onMarkerTap',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onMarkerTap != null) {
          widget.onMarkerTap!(
            jsonDecode(result.message)['markerId'],
            LatLng.fromJson(jsonDecode(result.message)),
            jsonDecode(result.message)['zoomLevel'],
          );
        }
      })
      ..addJavaScriptChannel('onMarkerClustererTap',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onMarkerClustererTap != null) {
          widget.onMarkerClustererTap!(
            LatLng.fromJson(jsonDecode(result.message)),
            jsonDecode(result.message)['zoomLevel'],
          );
        }
      })
      ..addJavaScriptChannel('onCustomOverlayTap',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onCustomOverlayTap != null) {
          widget.onCustomOverlayTap!(
            jsonDecode(result.message)['customOverlayId'],
            LatLng.fromJson(jsonDecode(result.message)),
          );
        }
      })
      ..addJavaScriptChannel('onMarkerDragChangeCallback',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onMarkerDragChangeCallback != null) {
          widget.onMarkerDragChangeCallback!(
            jsonDecode(result.message)['markerId'],
            LatLng.fromJson(jsonDecode(result.message)),
            jsonDecode(result.message)['zoomLevel'],
            jsonDecode(result.message)['drag'] == 'dragstart'
                ? MarkerDragType.start
                : MarkerDragType.end,
          );
        }
      })
      ..addJavaScriptChannel('zoomStart',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onZoomChangeCallback != null) {
          widget.onZoomChangeCallback!(
            jsonDecode(result.message)['zoomLevel'],
            ZoomType.start,
          );
        }
      })
      ..addJavaScriptChannel('zoomChanged',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onZoomChangeCallback != null) {
          widget.onZoomChangeCallback!(
            jsonDecode(result.message)['zoomLevel'],
            ZoomType.end,
          );
        }
      })
      ..addJavaScriptChannel('centerChanged',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onCenterChangeCallback != null) {
          widget.onCenterChangeCallback!(
            LatLng.fromJson(jsonDecode(result.message)),
            jsonDecode(result.message)['zoomLevel'],
          );
        }
      })
      ..addJavaScriptChannel('boundsChanged',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onBoundsChangeCallback != null) {
          final latLngBounds = jsonDecode(result.message);

          final sw = latLngBounds['sw'];
          final ne = latLngBounds['ne'];

          widget.onBoundsChangeCallback!(LatLngBounds(
            LatLng(sw['latitude'], sw['longitude']),
            LatLng(ne['latitude'], ne['longitude']),
          ));
        }
      })
      ..addJavaScriptChannel('dragStart',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onDragChangeCallback != null) {
          widget.onDragChangeCallback!(
            LatLng.fromJson(jsonDecode(result.message)),
            jsonDecode(result.message)['zoomLevel'],
            DragType.start,
          );
        }
      })
      ..addJavaScriptChannel('drag',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onDragChangeCallback != null) {
          widget.onDragChangeCallback!(
            LatLng.fromJson(jsonDecode(result.message)),
            jsonDecode(result.message)['zoomLevel'],
            DragType.move,
          );
        }
      })
      ..addJavaScriptChannel('dragEnd',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onDragChangeCallback != null) {
          widget.onDragChangeCallback!(
            LatLng.fromJson(jsonDecode(result.message)),
            jsonDecode(result.message)['zoomLevel'],
            DragType.end,
          );
        }
      })
      ..addJavaScriptChannel('cameraIdle',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onCameraIdle != null) {
          widget.onCameraIdle!(
            LatLng.fromJson(jsonDecode(result.message)),
            jsonDecode(result.message)['zoomLevel'],
          );
        }
      })
      ..addJavaScriptChannel('tilesLoaded',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onTilesLoadedCallback != null) {
          widget.onTilesLoadedCallback!(
            LatLng.fromJson(jsonDecode(result.message)),
            jsonDecode(result.message)['zoomLevel'],
          );
        }
      })
      ..addJavaScriptChannel("keywordSearchCallback",
          onMessageReceived: (JavaScriptMessage result) {
        KeywordSearchService.keywordSearchCallback(result.message);
      })
      ..addJavaScriptChannel("categorySearchCallback",
          onMessageReceived: (JavaScriptMessage result) {
        CategorySearchService.categorySearchCallback(result.message);
      })
      ..addJavaScriptChannel("addressSearchCallback",
          onMessageReceived: (JavaScriptMessage result) {
        AddressSearchService.addressSearchCallback(result.message);
      })
      ..addJavaScriptChannel("coord2AddressCallback",
          onMessageReceived: (JavaScriptMessage result) {
        Coord2AddressService.coord2AddressCallback(result.message);
      })
      ..addJavaScriptChannel("coord2RegionCodeCallback",
          onMessageReceived: (JavaScriptMessage result) {
        Coord2RegionCodeService.coord2RegionCodeCallback(result.message);
      })
      ..addJavaScriptChannel("transCoordCallback",
          onMessageReceived: (JavaScriptMessage result) {
        TransCoordService.transCodeCallback(result.message);
      });
  }
}
