window.yandexMaps = window.yandexMaps || {};

async function initYandexMap(mapId, state = {}, placemarks = [], polygons = [], polylines = [], callbacks = {}) {
  // Wait until the container div and ymaps3 global are both available
  await new Promise((resolve) => {
    function poll() {
      if (document.getElementById(mapId) && window.ymaps3) resolve();
      else setTimeout(poll, 50);
    }
    poll();
  });

  if (window.yandexMaps[mapId]) return;

  await window.ymaps3.ready;
  if (!window.yandexMapHelpers) throw new Error('yandex_map_helpers.js is not loaded');

  const behaviors =
    Array.isArray(state?.behaviors) && state.behaviors.length > 0
      ? state.behaviors
      : window.yandexMapHelpers.defaultBehaviors();

  const location = {
    center: Array.isArray(state?.center) ? state.center : [37.62, 55.75],
    zoom: Number.isFinite(state?.zoom) ? state.zoom : 10,
    ...(Array.isArray(state?.bounds) && state.bounds.length > 1 ? { bounds: state.bounds } : {}),
  };

  const map = new window.ymaps3.YMap(document.getElementById(mapId), {
    location,
    behaviors,
    type: 'map',
    mode: 'vector',
  });

  window.yandexMapSchemeLayers = window.yandexMapSchemeLayers || {};
  const schemeLayer = new window.ymaps3.YMapDefaultSchemeLayer();
  map.addChild(schemeLayer);
  window.yandexMapSchemeLayers[mapId] = schemeLayer;

  map.addChild(new window.ymaps3.YMapDefaultFeaturesLayer());

  window.yandexMaps[mapId] = map;

  const { onCameraPositionChanged, onMapTap, onMapLongTap } = callbacks || {};
  if (onCameraPositionChanged || onMapTap || onMapLongTap) {
    let longTapTimer = null;

    const listener = new window.ymaps3.YMapListener({
      onUpdate({ location: loc, mapInAction }) {
        if (onCameraPositionChanged) {
          onCameraPositionChanged(loc.center[1], loc.center[0], loc.zoom, !mapInAction);
        }
      },
      onClick(object, event) {
        if (!object && onMapTap) {
          onMapTap(event.coordinates[1], event.coordinates[0]);
        }
      },
      onTouchStart(_object, event) {
        if (!onMapLongTap) return;
        clearTimeout(longTapTimer);
        const [lon, lat] = event.coordinates;
        longTapTimer = setTimeout(() => onMapLongTap(lat, lon), 500);
      },
      onTouchEnd() { clearTimeout(longTapTimer); },
      onTouchMove() { clearTimeout(longTapTimer); },
    });

    map.addChild(listener);
  }

  if (window.yandexMapController) {
    await Promise.all([
      ...placemarks.map((item) =>
        window.yandexMapController.addPlacemark(item.geometry, item.properties || {}, item.options || {}, mapId, item.id),
      ),
      ...polygons.map((item) =>
        window.yandexMapController.addPolygon(item.geometry, item.properties || {}, item.options || {}, mapId, item.id),
      ),
      ...polylines.map((item) =>
        window.yandexMapController.addPolyline(item.geometry, item.properties || {}, item.options || {}, mapId, item.id),
      ),
    ]);
  }
}

function destroyYandexMap(mapId, placemarksIds = [], polygonsIds = [], polylinesIds = []) {
  if (window.yandexMaps?.[mapId]) {
    window.yandexMaps[mapId].destroy();
    delete window.yandexMaps[mapId];
  }

  if (window.yandexMapSchemeLayers?.[mapId]) {
    delete window.yandexMapSchemeLayers[mapId];
  }

  for (const id of placemarksIds) {
    if (window.placemarks?.[id]) delete window.placemarks[id];
  }

  for (const id of polygonsIds) {
    if (window.polygons?.[id]) delete window.polygons[id];
  }

  for (const id of polylinesIds) {
    if (window.polylines?.[id]) delete window.polylines[id];
  }

  if (window.clusters) {
    for (const clusterId of Object.keys(window.clusters)) {
      if (window.clusters[clusterId].mapId === mapId) {
        delete window.clusters[clusterId];
      }
    }
  }

  if (window.userLocationMarkers?.[mapId]) {
    const record = window.userLocationMarkers[mapId];
    navigator.geolocation?.clearWatch(record.watchId);
    delete window.userLocationMarkers[mapId];
  }
}
