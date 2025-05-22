part of '../../../kakao_map_plugin.dart';

enum JavascriptEvent {
  onMapCreated('onMapCreated'),
  onMapTap('onMapTap'),
  onMapDoubleTap('onMapDoubleTap'),
  centerChanged('centerChanged'),
  zoomStart('zoomStart'),
  zoomChanged('zoomChanged'),
  boundsChanged('boundsChanged'),
  dragStart('dragStart'),
  drag('drag'),
  dragEnd('dragEnd'),
  cameraIdle('cameraIdle'),
  tilesLoaded('tilesLoaded'),
  ;

  const JavascriptEvent(this.name);

  final String name;

  factory JavascriptEvent.getByName(String styleName) {
    return JavascriptEvent.values.firstWhere((value) => value.name == styleName,
        orElse: () => JavascriptEvent.onMapCreated);
  }
}
