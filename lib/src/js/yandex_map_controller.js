window.placemarks = window.placemarks || {};
window.polygons = window.polygons || {};
window.polylines = window.polylines || {};
window.yandexMaps = window.yandexMaps || {};
const yandexMapHelpers = window.yandexMapHelpers;

window.yandexMapController = {
  /**
 * Moves map center to specified coordinates
 * @param {number} lon - Target longitude
 * @param {number} lat - Target latitude
 * @param {number} zoom - Zoom level
 * @param {number} duration - Animation duration in milliseconds
 * @param {string} mapId - ID of target map instance
 * @returns {Promise<void>}
 */
  moveTo: async function (lon, lat, zoom, duration, mapId) {
    return new Promise((resolve, reject) => {
      try {
        if (!yandexMapHelpers) return reject('yandex_map_helpers.js is not loaded');
        const map = yandexMapHelpers.getMap(mapId);
        if (!map) return reject('Map not initialized.');

        map.setLocation({ center: [lon, lat], zoom, duration: duration || 300 });
        resolve();
      } catch (e) {
        reject(e);
      }
    });
  },

  /**
 * Sets map zoom level
 * @param {number} zoom - Target zoom level
 * @param {number} duration - Animation duration in milliseconds
 * @param {string} mapId - ID of target map instance
 * @returns {Promise<void>}
 */
  setZoom: async function (zoom, duration, mapId) {
    return new Promise((resolve, reject) => {
      try {
        if (!yandexMapHelpers) return reject('yandex_map_helpers.js is not loaded');
        const map = yandexMapHelpers.getMap(mapId);
        if (!map) return reject('Map not initialized.');

        map.setLocation({ center: map.center, zoom, duration: duration || 300 });
        resolve();
      } catch (e) {
        reject(e);
      }
    });
  },

  /**
 * Zooms in by one level
 * @param {number} duration - Animation duration in milliseconds
 * @param {string} mapId - ID of target map instance
 * @returns {Promise<void>}
 */
  zoomIn: async function (duration, mapId) {
    return new Promise((resolve, reject) => {
      try {
        const map = yandexMapHelpers.getMap(mapId);
        if (!map) return reject('Map not initialized.');
        window.yandexMapController.setZoom(map.zoom + 1, duration, mapId).then(resolve).catch(reject);
      } catch (e) {
        reject(e);
      }
    });
  },

  /**
 * Zooms out by one level
 * @param {number} duration - Animation duration in milliseconds
 * @param {string} mapId - ID of target map instance
 * @returns {Promise<void>}
 */
  zoomOut: async function (duration, mapId) {
    return new Promise((resolve, reject) => {
      try {
        const map = yandexMapHelpers.getMap(mapId);
        if (!map) return reject('Map not initialized.');
        window.yandexMapController.setZoom(map.zoom - 1, duration, mapId).then(resolve).catch(reject);
      } catch (e) {
        reject(e);
      }
    });
  },

  /**
 * Gets current zoom level
 * @param {string} mapId - ID of target map instance
 * @returns {Promise<number>} Current zoom level
 */
  getZoom: async function (mapId) {
    return new Promise((resolve, reject) => {
      try {
        const map = yandexMapHelpers.getMap(mapId);
        if (!map) return reject('Map not initialized.');
        resolve(map.zoom);
      } catch (e) {
        reject(e);
      }
    });
  },

  /**
 * Gets current map center coordinates
 * @param {string} mapId - ID of target map instance
 * @returns {Promise<Array<number>>} [latitude, longitude] coordinates
 */
  getCenter: async function (mapId) {
    return new Promise((resolve, reject) => {
      try {
        const map = yandexMapHelpers.getMap(mapId);
        if (!map) return reject('Map not initialized.');
        resolve([map.center[1], map.center[0]]);
      } catch (e) {
        reject(e);
      }
    });
  },

  /**
 * Gets current visible bounds
 * @param {string} mapId - ID of target map instance
 * @returns {Promise<Array<number>>} [swLat, swLon, neLat, neLon]
 */
  getBounds: async function (mapId) {
    return new Promise((resolve, reject) => {
      try {
        const map = yandexMapHelpers.getMap(mapId);
        if (!map) return reject('Map not initialized.');
        const b = map.bounds;
        resolve([b[0][1], b[0][0], b[1][1], b[1][0]]);
      } catch (e) {
        reject(e);
      }
    });
  },

  /**
 * Adjusts view to contain specified bounds
 * @param {number} swLon - South-west longitude
 * @param {number} swLat - South-west latitude
 * @param {number} neLon - North-east longitude
 * @param {number} neLat - North-east latitude
 * @param {number} duration - Animation duration in milliseconds
 * @param {string} mapId - ID of target map instance
 * @returns {Promise<void>}
 */
  fitBounds: async function (swLon, swLat, neLon, neLat, duration, mapId) {
    return new Promise((resolve, reject) => {
      try {
        if (!yandexMapHelpers) return reject('yandex_map_helpers.js is not loaded');
        const map = yandexMapHelpers.getMap(mapId);
        if (!map) return reject('Map not initialized.');

        map.setLocation({
          bounds: [[swLon, swLat], [neLon, neLat]],
          duration: duration || 300,
        });
        resolve();
      } catch (e) {
        reject(e);
      }
    });
  },

  /**
 * Enables/disables scroll zoom interaction
 * @param {boolean} enabled - Whether to enable scroll zoom
 * @param {string} mapId - ID of target map instance
 * @returns {Promise<void>}
 */
  enableScrollZoom: async function (enabled, mapId) {
    return new Promise((resolve, reject) => {
      try {
        if (!yandexMapHelpers) return reject('yandex_map_helpers.js is not loaded');
        const map = yandexMapHelpers.getMap(mapId);
        if (!map) return reject('Map not initialized.');

        const behaviors = new Set(map.behaviors);
        if (enabled) {
          behaviors.add('scrollZoom');
          behaviors.add('pinchZoom');
        } else {
          behaviors.delete('scrollZoom');
          behaviors.delete('pinchZoom');
        }

        map.setBehaviors([...behaviors]);
        resolve();
      } catch (e) {
        reject(e);
      }
    });
  },

  /**
 * Enables/disables map dragging
 * @param {boolean} enabled - Whether to enable dragging
 * @param {string} mapId - ID of target map instance
 * @returns {Promise<void>}
 */
  enableDrag: async function (enabled, mapId) {
    return new Promise((resolve, reject) => {
      try {
        if (!yandexMapHelpers) return reject('yandex_map_helpers.js is not loaded');
        const map = yandexMapHelpers.getMap(mapId);
        if (!map) return reject('Map not initialized.');

        const behaviors = new Set(map.behaviors);
        if (enabled) behaviors.add('drag');
        else behaviors.delete('drag');

        map.setBehaviors([...behaviors]);
        resolve();
      } catch (e) {
        reject(e);
      }
    });
  },

  /**
 * Adds new placemark to the map
 * @param {Array<number>} geometry - [longitude, latitude] coordinates
 * @param {Object} properties - Content properties
 * @param {Object} options - Display options
 * @param {string} mapId - ID of target map instance
 * @param {string} placemarkId - Unique identifier for placemark
 * @returns {Promise<void>}
 */
  addPlacemark: async function (geometry, properties, options, mapId, placemarkId) {
    return new Promise((resolve, reject) => {
      try {
        if (!yandexMapHelpers) return reject('yandex_map_helpers.js is not loaded');
        const map = yandexMapHelpers.getMap(mapId);
        if (!map) return reject('Map not initialized.');
        if (window.placemarks[placemarkId]) return reject('Placemark already exists');

        const record = yandexMapHelpers.createPlacemarkRecord(geometry, properties || {}, options || {}, mapId, placemarkId);
        map.addChild(record.marker);
        window.placemarks[placemarkId] = record;
        resolve();
      } catch (e) {
        reject(e);
      }
    });
  },

  /**
     * Removes a placemark from the map
     * @param {string} placemarkId - ID of the placemark to remove
     * @param {string} mapId - ID of the map instance
     * @returns {Promise<void>}
     */
  removePlacemark: async function (placemarkId, mapId) {
    return new Promise((resolve, reject) => {
      try {
        if (!yandexMapHelpers) return reject('yandex_map_helpers.js is not loaded');
        const map = yandexMapHelpers.getMap(mapId);
        if (!map) return reject('Map not initialized.');

        const record = window.placemarks[placemarkId];
        if (!record) return reject('Placemark not found');

        map.removeChild(record.marker);
        delete window.placemarks[placemarkId];
        resolve();
      } catch (e) {
        reject(e);
      }
    });
  },

  /**
     * Updates the coordinates of an existing placemark
     * @param {string} placemarkId - ID of the placemark to update
     * @param {Array<number>} newGeometry - New [longitude, latitude] coordinates
     * @returns {Promise<void>}
     */
  updatePlacemarkGeometry: async function (placemarkId, newGeometry) {
    return new Promise((resolve, reject) => {
      try {
        const record = window.placemarks[placemarkId];
        if (!record) return reject('Placemark not found');

        record.geometry = yandexMapHelpers.clonePoint(newGeometry);
        record.marker.update({ coordinates: record.geometry });
        resolve();
      } catch (e) {
        reject(e);
      }
    });
  },

  /**
     * Updates the content properties of an existing placemark
     * @param {string} placemarkId - ID of the placemark to update
     * @param {Object} newProperties - New content properties
     * @returns {Promise<void>}
     */
  updatePlacemarkProperties: async function (placemarkId, newProperties) {
    return new Promise((resolve, reject) => {
      try {
        const record = window.placemarks[placemarkId];
        if (!record) return reject('Placemark not found');

        record.properties = yandexMapHelpers.deepClone(newProperties || {});
        yandexMapHelpers.rebuildPlacemark(record);
        resolve();
      } catch (e) {
        reject(e);
      }
    });
  },

  /**
     * Updates the display options of an existing placemark
     * @param {string} placemarkId - ID of the placemark to update
     * @param {Object} newOptions - New display options
     * @returns {Promise<void>}
     */
  updatePlacemarkOptions: async function (placemarkId, newOptions) {
    return new Promise((resolve, reject) => {
      try {
        const record = window.placemarks[placemarkId];
        if (!record) return reject('Placemark not found');

        record.options = yandexMapHelpers.deepClone(newOptions || {});
        yandexMapHelpers.rebuildPlacemark(record);
        resolve();
      } catch (e) {
        reject(e);
      }
    });
  },

  /**
     * Adds a new polygon to the map
     * @param {Array<Array<number>>} geometry - Polygon coordinates array
     * @param {Object} properties - Content properties
     * @param {Object} options - Display options
     * @param {string} mapId - ID of the map instance
     * @param {string} polygonId - Unique ID for the polygon
     * @returns {Promise<void>}
     */
  addPolygon: async function (geometry, properties, options, mapId, polygonId) {
    return new Promise((resolve, reject) => {
      try {
        if (!yandexMapHelpers) return reject('yandex_map_helpers.js is not loaded');
        const map = yandexMapHelpers.getMap(mapId);
        if (!map) return reject('Map not initialized.');
        if (window.polygons[polygonId]) return reject('Polygon already exists');

        const record = yandexMapHelpers.createPolygonRecord(geometry, properties || {}, options || {}, mapId, polygonId);
        map.addChild(record.feature);
        window.polygons[polygonId] = record;
        resolve();
      } catch (e) {
        reject(e);
      }
    });
  },

  /**
     * Removes a polygon from the map
     * @param {string} polygonId - ID of the polygon to remove
     * @param {string} mapId - ID of the map instance
     * @returns {Promise<void>}
     */
  removePolygon: async function (polygonId, mapId) {
    return new Promise((resolve, reject) => {
      try {
        if (!yandexMapHelpers) return reject('yandex_map_helpers.js is not loaded');
        const map = yandexMapHelpers.getMap(mapId);
        if (!map) return reject('Map not initialized.');

        const record = window.polygons[polygonId];
        if (!record) return reject('Polygon not found');

        map.removeChild(record.feature);
        delete window.polygons[polygonId];
        resolve();
      } catch (e) {
        reject(e);
      }
    });
  },

  /**
     * Updates the coordinates of an existing polygon
     * @param {string} polygonId - ID of the polygon to update
     * @param {Array<Array<number>>} newGeometry - New polygon coordinates
     * @returns {Promise<void>}
     */
  updatePolygonGeometry: async function (polygonId, newGeometry) {
    return new Promise((resolve, reject) => {
      try {
        const record = window.polygons[polygonId];
        if (!record) return reject('Polygon not found');

        record.geometry = yandexMapHelpers.clonePolygonGeometry(newGeometry);
        record.feature.update({
          geometry: { type: 'Polygon', coordinates: record.geometry },
        });
        resolve();
      } catch (e) {
        reject(e);
      }
    });
  },

  /**
     * Updates the content properties of an existing polygon
     * @param {string} polygonId - ID of the polygon to update
     * @param {Object} newProperties - New content properties
     * @returns {Promise<void>}
     */
  updatePolygonProperties: async function (polygonId, newProperties) {
    return new Promise((resolve, reject) => {
      try {
        const record = window.polygons[polygonId];
        if (!record) return reject('Polygon not found');

        record.properties = yandexMapHelpers.deepClone(newProperties || {});
        record.feature.update({ properties: record.properties });
        resolve();
      } catch (e) {
        reject(e);
      }
    });
  },

  /**
     * Updates the display options of an existing polygon
     * @param {string} polygonId - ID of the polygon to update
     * @param {Object} newOptions - New display options
     * @returns {Promise<void>}
     */
  updatePolygonOptions: async function (polygonId, newOptions) {
    return new Promise((resolve, reject) => {
      try {
        const record = window.polygons[polygonId];
        if (!record) return reject('Polygon not found');

        record.options = yandexMapHelpers.deepClone(newOptions || {});
        record.feature.update({ style: record.options.style || {} });
        resolve();
      } catch (e) {
        reject(e);
      }
    });
  },

  /**
     * Adds a new polyline to the map
     * @param {Array<Array<number>>} geometry - Polyline coordinates array
     * @param {Object} properties - Content properties
     * @param {Object} options - Display options
     * @param {string} mapId - ID of the map instance
     * @param {string} polylineId - Unique ID for the polyline
     * @returns {Promise<void>}
     */
  addPolyline: async function (geometry, properties, options, mapId, polylineId) {
    return new Promise((resolve, reject) => {
      try {
        if (!yandexMapHelpers) return reject('yandex_map_helpers.js is not loaded');
        const map = yandexMapHelpers.getMap(mapId);
        if (!map) return reject('Map not initialized.');
        if (window.polylines[polylineId]) return reject('Polyline already exists');

        const record = yandexMapHelpers.createPolylineRecord(geometry, properties || {}, options || {}, mapId, polylineId);
        map.addChild(record.feature);
        window.polylines[polylineId] = record;
        resolve();
      } catch (e) {
        reject(e);
      }
    });
  },

  /**
     * Removes a polyline from the map
     * @param {string} polylineId - ID of the polyline to remove
     * @param {string} mapId - ID of the map instance
     * @returns {Promise<void>}
     */
  removePolyline: async function (polylineId, mapId) {
    return new Promise((resolve, reject) => {
      try {
        if (!yandexMapHelpers) return reject('yandex_map_helpers.js is not loaded');
        const map = yandexMapHelpers.getMap(mapId);
        if (!map) return reject('Map not initialized.');

        const record = window.polylines[polylineId];
        if (!record) return reject('Polyline not found');

        map.removeChild(record.feature);
        delete window.polylines[polylineId];
        resolve();
      } catch (e) {
        reject(e);
      }
    });
  },

  /**
     * Updates the coordinates of an existing polyline
     * @param {string} polylineId - ID of the polyline to update
     * @param {Array<Array<number>>} newGeometry - New polyline coordinates
     * @returns {Promise<void>}
     */
  updatePolylineGeometry: async function (polylineId, newGeometry) {
    return new Promise((resolve, reject) => {
      try {
        const record = window.polylines[polylineId];
        if (!record) return reject('Polyline not found');

        record.geometry = yandexMapHelpers.cloneLineGeometry(newGeometry);
        record.feature.update({
          geometry: { type: 'LineString', coordinates: record.geometry },
        });
        resolve();
      } catch (e) {
        reject(e);
      }
    });
  },

  /**
     * Updates the content properties of an existing polyline
     * @param {string} polylineId - ID of the polyline to update
     * @param {Object} newProps - New content properties
     * @returns {Promise<void>}
     */
  updatePolylineProperties: async function (polylineId, newProps) {
    return new Promise((resolve, reject) => {
      try {
        const record = window.polylines[polylineId];
        if (!record) return reject('Polyline not found');

        record.properties = yandexMapHelpers.deepClone(newProps || {});
        record.feature.update({ properties: record.properties });
        resolve();
      } catch (e) {
        reject(e);
      }
    });
  },

  /**
     * Updates the display options of an existing polyline
     * @param {string} polylineId - ID of the polyline to update
     * @param {Object} newOpts - New display options
     * @returns {Promise<void>}
     */
  updatePolylineOptions: async function (polylineId, newOpts) {
    return new Promise((resolve, reject) => {
      try {
        const record = window.polylines[polylineId];
        if (!record) return reject('Polyline not found');

        record.options = yandexMapHelpers.deepClone(newOpts || {});
        record.feature.update({ style: record.options.style || {} });
        resolve();
      } catch (e) {
        reject(e);
      }
    });
  },

  /**
   * Adds a clustered group of placemarks to the map.
   * Lazily imports @yandex/ymaps3-clusterer on first use.
   * @param {Object} clusterData - { id, placemarks[], options }
   * @param {string} mapId - ID of target map instance
   * @returns {Promise<void>}
   */
  addCluster: async function (clusterData, mapId) {
    return new Promise(async (resolve, reject) => {
      try {
        if (!yandexMapHelpers) return reject('yandex_map_helpers.js is not loaded');
        const map = yandexMapHelpers.getMap(mapId);
        if (!map) return reject('Map not initialized.');

        if (!window.ymaps3Clusterer) {
          window.ymaps3.import.registerCdn('https://cdn.jsdelivr.net/npm/{package}', '@yandex/ymaps3-clusterer@latest');
          window.ymaps3Clusterer = await window.ymaps3.import('@yandex/ymaps3-clusterer');
        }
        const { YMapClusterer, clusterByGrid } = window.ymaps3Clusterer;

        // options are embedded in each feature so the marker callback
        // doesn't need a secondary lookup through clusterData.placemarks
        const features = clusterData.placemarks.map((p) => ({
          type: 'Feature',
          id: p.id,
          geometry: { type: 'Point', coordinates: p.geometry },
          properties: p.properties || {},
          options: p.options || {},
        }));

        const clusterer = new YMapClusterer({
          method: clusterByGrid({ gridSize: clusterData.options.gridSize || 64 }),
          ...(clusterData.options.maxZoom != null && { maxZoom: clusterData.options.maxZoom }),
          features,
          marker(feature) {
            const coords = feature.geometry.coordinates;
            return new window.ymaps3.YMapMarker(
              {
                coordinates: coords,
                onClick: () => {
                  if (typeof window._yandexMapPlacemarkTap === 'function') {
                    window._yandexMapPlacemarkTap(feature.id, coords[1], coords[0]);
                  }
                },
              },
              yandexMapHelpers.createPlacemarkElement(feature.properties, feature.options || {}),
            );
          },
          cluster(coordinates, clusterFeatures) {
            let options = { ...clusterData.options };
            let currentTapId = clusterData.id;
            const count = clusterFeatures.length;
            const builderKey = `_yandexMapClusterIconBuilder_${clusterData.id}`;

            if (typeof window[builderKey] === 'function') {
              const ids = clusterFeatures.map((f) => f.id);
              const result = window[builderKey](ids, coordinates[1], coordinates[0]);

              if (result && result._promise) {
                // Async builder — wrapper is invisible until icon is ready.
                // Use visibility:hidden (not opacity:0) — opacity has no effect
                // on display:contents elements per CSS spec.
                const wrapper = document.createElement('div');
                wrapper.style.cssText = 'display:contents;visibility:hidden;';

                result._promise.then((resolved) => {
                  if (!resolved) return;
                  if (resolved.tapId) currentTapId = resolved.tapId;
                  const finalOptions = { ...options, ...resolved };
                  wrapper.appendChild(
                    yandexMapHelpers.createClusterElement(count, finalOptions),
                  );
                  wrapper.style.visibility = 'visible';
                });

                return new window.ymaps3.YMapMarker(
                  {
                    coordinates,
                    onClick: () => {
                      if (typeof window._yandexMapClusterTap === 'function') {
                        window._yandexMapClusterTap(currentTapId, coordinates[1], coordinates[0], count);
                      }
                    },
                  },
                  wrapper,
                );
              }

              if (result) {
                if (result.tapId) currentTapId = result.tapId;
                options = { ...options, ...result };
              }
            }

            return yandexMapHelpers.createClusterMarker(
              coordinates,
              count,
              options,
              currentTapId,
            );
          },
        });

        map.addChild(clusterer);
        window.clusters = window.clusters || {};
        window.clusters[clusterData.id] = { clusterer, mapId, data: clusterData };
        resolve();
      } catch (e) {
        reject(e);
      }
    });
  },

  /**
   * Removes a cluster from the map.
   * @param {string} clusterId - ID of the cluster to remove
   * @param {string} mapId - ID of target map instance
   * @returns {Promise<void>}
   */
  removeCluster: async function (clusterId, mapId) {
    return new Promise((resolve, reject) => {
      try {
        if (!yandexMapHelpers) return reject('yandex_map_helpers.js is not loaded');
        const map = yandexMapHelpers.getMap(mapId);
        if (!map) return reject('Map not initialized.');

        const record = window.clusters?.[clusterId];
        if (!record) return reject('Cluster not found');

        map.removeChild(record.clusterer);
        delete window.clusters[clusterId];
        resolve();
      } catch (e) {
        reject(e);
      }
    });
  },

  /**
   * Shows a pulsing blue user-location dot using browser Geolocation API.
   * Updates position continuously via watchPosition.
   * Fires window._yandexMapUserLocationUpdate(mapId, lat, lon) on each update.
   * @param {string} mapId - ID of target map instance
   * @returns {Promise<void>}
   */
  showUserLocation: async function (mapId) {
    return new Promise((resolve, reject) => {
      try {
        if (!navigator.geolocation) return reject('Geolocation not supported by this browser');
        const map = yandexMapHelpers.getMap(mapId);
        if (!map) return reject('Map not initialized.');

        window.userLocationMarkers = window.userLocationMarkers || {};

        // Remove existing tracker for this map if any
        const old = window.userLocationMarkers[mapId];
        if (old) {
          if (!old.marker._hidden) map.removeChild(old.marker);
          navigator.geolocation.clearWatch(old.watchId);
        }

        const el = yandexMapHelpers.createUserLocationElement();
        const marker = new window.ymaps3.YMapMarker({ coordinates: [0, 0] }, el);
        marker._hidden = true;

        const watchId = navigator.geolocation.watchPosition(
          ({ coords }) => {
            const { latitude: lat, longitude: lon } = coords;
            if (marker._hidden) {
              map.addChild(marker);
              marker._hidden = false;
            }
            marker.update({ coordinates: [lon, lat] });
            if (typeof window._yandexMapUserLocationUpdate === 'function') {
              window._yandexMapUserLocationUpdate(mapId, lat, lon);
            }
          },
          (err) => console.warn('User location error:', err),
          { enableHighAccuracy: true, maximumAge: 0 },
        );

        window.userLocationMarkers[mapId] = { marker, watchId };
        resolve();
      } catch (e) {
        reject(e);
      }
    });
  },

  /**
   * Removes the user-location dot and stops geolocation tracking.
   * @param {string} mapId - ID of target map instance
   * @returns {Promise<void>}
   */
  hideUserLocation: async function (mapId) {
    return new Promise((resolve, reject) => {
      try {
        const map = yandexMapHelpers.getMap(mapId);
        if (!map) return reject('Map not initialized.');

        const record = window.userLocationMarkers?.[mapId];
        if (record) {
          if (!record.marker._hidden) map.removeChild(record.marker);
          navigator.geolocation.clearWatch(record.watchId);
          delete window.userLocationMarkers[mapId];
        }
        resolve();
      } catch (e) {
        reject(e);
      }
    });
  },

  /**
   * Updates the map scheme layer theme and/or customization.
   * Both arguments are optional — pass null to leave unchanged.
   * @param {string|null} theme - Theme name, e.g. 'light' or 'dark'
   * @param {Array|null} customization - Customization rules JSON array
   * @param {string} mapId - ID of target map instance
   * @returns {Promise<void>}
   */
  setTheme: async function (theme, customization, mapId) {
    return new Promise((resolve, reject) => {
      try {
        const schemeLayer = window.yandexMapSchemeLayers?.[mapId];
        if (!schemeLayer) return reject('Scheme layer not found for map: ' + mapId);

        const props = {};
        if (theme != null) props.theme = theme;
        if (customization != null) props.customization = customization;

        schemeLayer.update(props);
        resolve();
      } catch (e) {
        reject(e);
      }
    });
  },

  /**
   * Replaces the placemarks inside an existing cluster.
   * @param {string} clusterId - ID of the cluster to update
   * @param {Object} data - { placemarks[] }
   * @param {string} mapId - ID of target map instance
   * @returns {Promise<void>}
   */
  updateCluster: async function (clusterId, data, _mapId) {
    return new Promise((resolve, reject) => {
      try {
        const record = window.clusters?.[clusterId];
        if (!record) return reject(`Cluster '${clusterId}' not found`);

        record.data.placemarks = data.placemarks;

        const features = data.placemarks.map((p) => ({
          type: 'Feature',
          id: p.id,
          geometry: { type: 'Point', coordinates: p.geometry },
          properties: p.properties || {},
          options: p.options || {},
        }));

        record.clusterer.update({ features });
        resolve();
      } catch (e) {
        reject(e);
      }
    });
  },
};
