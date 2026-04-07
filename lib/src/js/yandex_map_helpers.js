window.yandexMapHelpers = window.yandexMapHelpers || {};

// JS-side fallback — Dart passes behaviors via MapState, but this default is needed when state omits them
window.yandexMapHelpers.defaultBehaviors = function () {
  return ['drag', 'scrollZoom', 'pinchZoom', 'dblClick'];
};

window.yandexMapHelpers.getMap = function (mapId) {
  return window.yandexMaps?.[mapId];
};

window.yandexMapHelpers.clonePoint = function (point) {
  if (!Array.isArray(point)) return point;
  return [...point];
};

window.yandexMapHelpers.clonePolygonGeometry = function (geometry) {
  if (!Array.isArray(geometry)) return [];
  return geometry.map((ring) => {
    if (!Array.isArray(ring)) return [];
    return ring.map((point) => window.yandexMapHelpers.clonePoint(point));
  });
};

window.yandexMapHelpers.cloneLineGeometry = function (geometry) {
  if (!Array.isArray(geometry)) return [];
  return geometry.map((point) => window.yandexMapHelpers.clonePoint(point));
};

window.yandexMapHelpers.deepClone = function (value) {
  if (value == null) return {};
  return JSON.parse(JSON.stringify(value));
};

window.yandexMapHelpers.createPlacemarkElement = function (properties = {}, options = {}) {
  const size = options.iconSize || 20;
  const cursor = options.cursor || 'pointer';
  const visible = options.visible !== false;

  // Image icon from bytes (data URL)
  if (options.iconDataUrl) {
    const img = document.createElement('img');
    img.src = options.iconDataUrl;
    if (options.iconWidth != null && options.iconHeight != null) {
      img.style.width = `${options.iconWidth}px`;
      img.style.height = `${options.iconHeight}px`;
    }
    img.style.transform = 'translate(-50%, -100%)';
    img.style.cursor = cursor;
    img.style.display = visible ? 'block' : 'none';
    img.draggable = false;
    if (typeof properties.hintContent === 'string' && properties.hintContent.length > 0) {
      img.title = properties.hintContent;
    }
    return img;
  }

  // Default circle icon — all values come from Dart, no JS-side fallbacks
  const el = document.createElement('div');
  el.style.width = `${size}px`;
  el.style.height = `${size}px`;
  el.style.borderRadius = '50%';
  el.style.border = `${options.borderWidth}px solid ${options.borderColor}`;
  el.style.boxSizing = 'border-box';
  if (options.hasShadow) {
    el.style.boxShadow = '0 2px 8px rgba(0, 0, 0, 0.35)';
  }
  el.style.background = options.iconColor;
  el.style.transform = 'translate(-50%, -50%)';
  el.style.cursor = cursor;
  el.style.display = visible ? 'block' : 'none';

  const content = properties.iconContent || properties.iconCaption;
  if (typeof content === 'string' && content.length > 0) {
    el.textContent = content;
    el.style.color = '#ffffff';
    el.style.fontSize = '10px';
    el.style.fontWeight = '600';
    el.style.display = 'flex';
    el.style.alignItems = 'center';
    el.style.justifyContent = 'center';
    el.style.padding = '2px';
    el.style.minWidth = `${size}px`;
    el.style.borderRadius = '10px';
  }

  if (typeof properties.hintContent === 'string' && properties.hintContent.length > 0) {
    el.title = properties.hintContent;
  }

  return el;
};

window.yandexMapHelpers.createPlacemarkRecord = function (geometry, properties, options, mapId, placemarkId) {
  const markerElement = window.yandexMapHelpers.createPlacemarkElement(properties, options);

  const marker = new window.ymaps3.YMapMarker(
    {
      coordinates: geometry,
      draggable: Boolean(options.draggable),
      onClick: () => {
        if (typeof window._yandexMapPlacemarkTap === 'function') {
          window._yandexMapPlacemarkTap(placemarkId, geometry[1], geometry[0]);
        }
      },
    },
    markerElement,
  );

  return {
    id: placemarkId,
    mapId,
    geometry: window.yandexMapHelpers.clonePoint(geometry),
    properties: window.yandexMapHelpers.deepClone(properties),
    options: window.yandexMapHelpers.deepClone(options),
    marker,
  };
};

window.yandexMapHelpers.rebuildPlacemark = function (record) {
  const map = window.yandexMapHelpers.getMap(record.mapId);
  if (!map) throw new Error('Map not initialized.');

  if (record.marker) {
    map.removeChild(record.marker);
  }

  const nextRecord = window.yandexMapHelpers.createPlacemarkRecord(
    record.geometry,
    record.properties,
    record.options,
    record.mapId,
    record.id,
  );
  map.addChild(nextRecord.marker);
  window.placemarks[record.id] = nextRecord;
  return nextRecord;
};

window.yandexMapHelpers.createPolygonRecord = function (geometry, properties, options, mapId, polygonId) {
  const feature = new window.ymaps3.YMapFeature({
    geometry: {
      type: 'Polygon',
      coordinates: geometry,
    },
    style: options.style || {},
    properties: window.yandexMapHelpers.deepClone(properties),
  });

  return {
    id: polygonId,
    mapId,
    geometry: window.yandexMapHelpers.clonePolygonGeometry(geometry),
    properties: window.yandexMapHelpers.deepClone(properties),
    options: window.yandexMapHelpers.deepClone(options),
    feature,
  };
};

window.yandexMapHelpers.rebuildPolygon = function (record) {
  const map = window.yandexMapHelpers.getMap(record.mapId);
  if (!map) throw new Error('Map not initialized.');

  if (record.feature) {
    map.removeChild(record.feature);
  }

  const nextRecord = window.yandexMapHelpers.createPolygonRecord(
    record.geometry,
    record.properties,
    record.options,
    record.mapId,
    record.id,
  );
  map.addChild(nextRecord.feature);
  window.polygons[record.id] = nextRecord;
  return nextRecord;
};

window.yandexMapHelpers.createPolylineRecord = function (geometry, properties, options, mapId, polylineId) {
  const feature = new window.ymaps3.YMapFeature({
    geometry: {
      type: 'LineString',
      coordinates: geometry,
    },
    style: options.style || {},
    properties: window.yandexMapHelpers.deepClone(properties),
  });

  return {
    id: polylineId,
    mapId,
    geometry: window.yandexMapHelpers.cloneLineGeometry(geometry),
    properties: window.yandexMapHelpers.deepClone(properties),
    options: window.yandexMapHelpers.deepClone(options),
    feature,
  };
};

window.yandexMapHelpers.createClusterElement = function (count, options) {
  const size = options.clusterSize || 36;

  if (options.iconDataUrl) {
    // Custom image — natural size, no constraints. Wrapper needed for count badge.
    const wrap = document.createElement('div');
    wrap.style.cssText = 'position:relative;display:inline-block;transform:translate(-50%,-50%);cursor:pointer;';
    const img = document.createElement('img');
    img.src = options.iconDataUrl;
    img.draggable = false;
    img.style.display = 'block';
    if (options.iconWidth != null && options.iconHeight != null) {
      img.style.width = `${options.iconWidth}px`;
      img.style.height = `${options.iconHeight}px`;
    }
    wrap.appendChild(img);
    if (options.showClusterCount) {
      const badge = document.createElement('div');
      badge.textContent = String(count);
      badge.style.cssText =
        'position:absolute;top:-4px;right:-4px;background:#e53935;color:#fff;' +
        'border-radius:50%;min-width:16px;height:16px;font-size:10px;font-weight:600;' +
        'display:flex;align-items:center;justify-content:center;padding:0 2px;box-sizing:border-box;';
      wrap.appendChild(badge);
    }
    return wrap;
  }

  // Default circle — all values come from Dart, no JS-side fallbacks
  const el = document.createElement('div');
  el.style.width = `${size}px`;
  el.style.height = `${size}px`;
  el.style.borderRadius = '50%';
  el.style.border = `${options.borderWidth}px solid ${options.borderColor}`;
  el.style.boxSizing = 'border-box';
  if (options.hasShadow) {
    el.style.boxShadow = '0 2px 8px rgba(0, 0, 0, 0.35)';
  }
  el.style.background = options.clusterColor;
  el.style.color = '#ffffff';
  el.style.display = 'flex';
  el.style.alignItems = 'center';
  el.style.justifyContent = 'center';
  el.style.fontSize = '13px';
  el.style.fontWeight = '600';
  el.style.transform = 'translate(-50%, -50%)';
  el.style.cursor = 'pointer';
  if (options.showClusterCount) {
    el.textContent = String(count);
  }
  return el;
};

window.yandexMapHelpers.createClusterMarker = function (coordinates, count, options, clusterId) {
  const el = yandexMapHelpers.createClusterElement(count, options);

  return new window.ymaps3.YMapMarker(
    {
      coordinates,
      onClick: () => {
        if (typeof window._yandexMapClusterTap === 'function') {
          window._yandexMapClusterTap(clusterId, coordinates[1], coordinates[0], count);
        }
      },
    },
    el,
  );
};

window.yandexMapHelpers.rebuildPolyline = function (record) {
  const map = window.yandexMapHelpers.getMap(record.mapId);
  if (!map) throw new Error('Map not initialized.');

  if (record.feature) {
    map.removeChild(record.feature);
  }

  const nextRecord = window.yandexMapHelpers.createPolylineRecord(
    record.geometry,
    record.properties,
    record.options,
    record.mapId,
    record.id,
  );
  map.addChild(nextRecord.feature);
  window.polylines[record.id] = nextRecord;
  return nextRecord;
};

window.yandexMapHelpers.createUserLocationElement = function () {
  const el = document.createElement('div');
  el.style.cssText =
    'width:14px;height:14px;border-radius:50%;' +
    'background:#4285F4;border:2px solid #fff;box-shadow:0 2px 6px rgba(0,0,0,.3);' +
    'transform:translate(-50%,-50%);';
  return el;
};
