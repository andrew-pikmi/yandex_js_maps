part of '../yandex_js_maps.dart';

// JavaScript interop functions ================================================

/// JS interop: Moves the map camera to specified coordinates
@JS('yandexMapController.moveTo')
external JSPromise moveToJs(
    double lon, double lat, int zoom, int durationMs, String mapId);

/// JS interop: Sets the map zoom level
@JS('yandexMapController.setZoom')
external JSPromise setZoomJs(int zoom, int durationMs, String mapId);

/// JS interop: Zooms the map in by one level
@JS('yandexMapController.zoomIn')
external JSPromise zoomInJs(int durationMs, String mapId);

/// JS interop: Zooms the map out by one level
@JS('yandexMapController.zoomOut')
external JSPromise zoomOutJs(int durationMs, String mapId);

/// JS interop: Gets current zoom level
@JS('yandexMapController.getZoom')
external JSPromise<JSNumber> getZoomJs(String mapId);

/// JS interop: Gets current map center coordinates
@JS('yandexMapController.getCenter')
external JSPromise<JSArray> getCenterJs(String mapId);

/// JS interop: Gets current visible bounds as [swLat, swLon, neLat, neLon]
@JS('yandexMapController.getBounds')
external JSPromise<JSArray> getBoundsJs(String mapId);

/// JS interop: Fits map view to specified bounds
@JS('yandexMapController.fitBounds')
external JSPromise fitBoundsJs(double swLon, double swLat, double neLon,
    double neLat, int durationMs, String mapId);

/// JS interop: Enables/disables scroll zoom interaction
@JS('yandexMapController.enableScrollZoom')
external JSPromise enableScrollZoomJs(bool enabled, String mapId);

/// JS interop: Enables/disables map dragging
@JS('yandexMapController.enableDrag')
external JSPromise enableDragJs(bool enabled, String mapId);

/// JS interop: Adds a placemark to the map
@JS('yandexMapController.addPlacemark')
external JSPromise addPlacemarkJs(JSArray<JSNumber> geometry, JSAny properties,
    JSAny options, String mapId, String placemarkId);

/// JS interop: Removes a placemark from the map
@JS('yandexMapController.removePlacemark')
external JSPromise removePlacemarkJs(String placemarkId, String mapId);

/// JS interop: Updates placemark position
@JS('yandexMapController.updatePlacemarkGeometry')
external JSPromise updatePlacemarkGeometryJs(
    String placemarkId, JSArray<JSNumber> newGeometry);

/// JS interop: Updates placemark properties
@JS('yandexMapController.updatePlacemarkProperties')
external JSPromise updatePlacemarkPropertiesJs(
    String placemarkId, JSAny newProperties);

/// JS interop: Updates placemark visual options
@JS('yandexMapController.updatePlacemarkOptions')
external JSPromise updatePlacemarkOptionsJs(
    String placemarkId, JSAny newOptions);

/// JS interop: Adds a polygon to the map
@JS('yandexMapController.addPolygon')
external JSPromise addPolygonJs(JSArray geometry, JSAny properties,
    JSAny options, String mapId, String polygonId);

/// JS interop: Removes a polygon from the map
@JS('yandexMapController.removePolygon')
external JSPromise removePolygonJs(String polygonId, String mapId);

/// JS interop: Updates polygon geometry
@JS('yandexMapController.updatePolygonGeometry')
external JSPromise updatePolygonGeometryJs(
    String polygonId, JSArray newGeometry);

/// JS interop: Updates polygon properties
@JS('yandexMapController.updatePolygonProperties')
external JSPromise updatePolygonPropertiesJs(
    String polygonId, JSAny newProperties);

/// JS interop: Updates polygon visual options
@JS('yandexMapController.updatePolygonOptions')
external JSPromise updatePolygonOptionsJs(String polygonId, JSAny newOptions);

/// JS interop: Adds a polyline to the map
@JS('yandexMapController.addPolyline')
external JSPromise addPolylineJs(JSArray geometry, JSAny properties,
    JSAny options, String mapId, String polylineId);

/// JS interop: Removes a polyline from the map
@JS('yandexMapController.removePolyline')
external JSPromise removePolylineJs(String polylineId, String mapId);

/// JS interop: Updates polyline geometry
@JS('yandexMapController.updatePolylineGeometry')
external JSPromise updatePolylineGeometryJs(
    String polylineId, JSArray newGeometry);

/// JS interop: Updates polyline properties
@JS('yandexMapController.updatePolylineProperties')
external JSPromise updatePolylinePropertiesJs(
    String polylineId, JSAny newProps);

/// JS interop: Updates polyline visual options
@JS('yandexMapController.updatePolylineOptions')
external JSPromise updatePolylineOptionsJs(String polylineId, JSAny newOpts);

/// JS interop: Adds a clustered group of placemarks to the map
@JS('yandexMapController.addCluster')
external JSPromise addClusterJs(JSAny clusterData, String mapId);

/// JS interop: Shows a pulsing user-location dot using browser Geolocation API
@JS('yandexMapController.showUserLocation')
external JSPromise showUserLocationJs(String mapId);

/// JS interop: Hides the user-location dot and stops geolocation tracking
@JS('yandexMapController.hideUserLocation')
external JSPromise hideUserLocationJs(String mapId);

/// JS interop: Removes a cluster from the map
@JS('yandexMapController.removeCluster')
external JSPromise removeClusterJs(String clusterId, String mapId);

/// JS interop: Updates the placemarks of an existing cluster
@JS('yandexMapController.updateCluster')
external JSPromise updateClusterJs(String clusterId, JSAny data, String mapId);

/// JS interop: Updates map scheme layer theme and/or customization
@JS('yandexMapController.setTheme')
external JSPromise setThemeJs(JSAny? theme, JSAny? customization, String mapId);

// Dart Controller Class =======================================================

/// Controller class for interacting with Yandex Maps JavaScript API.
///
/// Provides a Dart-friendly interface to manage map state and map objects.
/// All methods return Futures that complete when
/// the corresponding JavaScript operation finishes.
class YandexJsMapController {
  YandexJsMapController._(this._mapId);

  /// Internal map identifier used for DOM element reference
  final String _mapId;

  final List<PlacemarkEntity> _placemarks = [];
  final List<PolygonEntity> _polygons = [];
  final List<PolylineEntity> _polylines = [];
  final List<String> _clusterIds = [];

  List<PlacemarkEntity> get placemarks => List.unmodifiable(_placemarks);
  List<PolygonEntity> get polygons => List.unmodifiable(_polygons);
  List<PolylineEntity> get polylines => List.unmodifiable(_polylines);

  // Tap callbacks are stored in static Dart Maps keyed by entity ID.
  // A single JS dispatcher per type routes click events from the JS layer to Dart.
  static final Map<String, (void Function(PointEntity, Object?), Object?)>
      _placemarkTapCallbacks = {};
  static final Map<String, (void Function(PointEntity, int, Object?), Object?)>
      _clusterTapCallbacks = {};
  static final Map<String, void Function(PointEntity)> _userLocationCallbacks =
      {};
  static final Map<String, Set<String>> _clusterPlacemarkIds = {};
  static final Map<String, Set<String>> _builderTapIds = {};
  static bool _placemarkDispatcherReady = false;
  static bool _clusterDispatcherReady = false;
  static bool _userLocationDispatcherReady = false;

  void _ensurePlacemarkDispatcher() {
    if (_placemarkDispatcherReady) return;
    _placemarkDispatcherReady = true;
    js.context['_yandexMapPlacemarkTap'] =
        js.allowInterop((String id, dynamic lat, dynamic lon) {
      final entry = _placemarkTapCallbacks[id];
      if (entry != null) {
        entry.$1(
          PointEntity((lat as num).toDouble(), (lon as num).toDouble()),
          entry.$2,
        );
      }
    });
  }

  void _ensureClusterDispatcher() {
    if (_clusterDispatcherReady) return;
    _clusterDispatcherReady = true;
    js.context['_yandexMapClusterTap'] =
        js.allowInterop((String id, dynamic lat, dynamic lon, dynamic count) {
      final entry = _clusterTapCallbacks[id];
      if (entry != null) {
        entry.$1(
          PointEntity((lat as num).toDouble(), (lon as num).toDouble()),
          (count as num).toInt(),
          entry.$2,
        );
      }
    });
  }

  void _ensureUserLocationDispatcher() {
    if (_userLocationDispatcherReady) return;
    _userLocationDispatcherReady = true;
    js.context['_yandexMapUserLocationUpdate'] =
        js.allowInterop((String mapId, dynamic lat, dynamic lon) {
      _userLocationCallbacks[mapId]?.call(
        PointEntity((lat as num).toDouble(), (lon as num).toDouble()),
      );
    });
  }

  /// Internal initializer used by the factory to create controller instances
  static YandexJsMapController _init(String id) => YandexJsMapController._(id);

  // Map View Operations ======================================================

  /// Moves the map camera to the specified [point] with optional [zoom] level.
  ///
  /// - [point] The target geographic coordinates
  /// - [zoom] The desired zoom level (default: 10)
  /// - [durationMs] Animation duration in milliseconds (default: 300)
  Future<void> moveTo(PointEntity point,
      {int zoom = 10, int durationMs = 300}) async {
    await moveToJs(point.lon, point.lat, zoom, durationMs, _mapId).toDart;
  }

  /// Sets the map zoom level.
  ///
  /// - [zoom] The target zoom level
  /// - [durationMs] Animation duration in milliseconds (default: 300)
  Future<void> setZoom(int zoom, {int durationMs = 300}) async =>
      await setZoomJs(zoom, durationMs, _mapId).toDart;

  /// Zooms in the map by one level.
  ///
  /// - [durationMs] Animation duration in milliseconds (default: 300)
  Future<void> zoomIn({int durationMs = 300}) async =>
      await zoomInJs(durationMs, _mapId).toDart;

  /// Zooms out the map by one level.
  ///
  /// - [durationMs] Animation duration in milliseconds (default: 300)
  Future<void> zoomOut({int durationMs = 300}) async =>
      await zoomOutJs(durationMs, _mapId).toDart;

  /// Gets the current zoom level of the map.
  Future<int> getZoom() async =>
      (await getZoomJs(_mapId).toDart).toDartDouble.round();

  /// Gets the current center coordinates of the map view.
  ///
  /// Return [PointEntity] with current center coordinates, or null if unavailable
  Future<PointEntity?> getCenter() async {
    final result = (await getCenterJs(_mapId).toDart) as List;
    if (result.length == 2) {
      final lat = (result[0] as num).toDouble();
      final lon = (result[1] as num).toDouble();
      return PointEntity(lat, lon);
    }
    return null;
  }

  /// Gets the current visible bounds of the map.
  ///
  /// Returns `[southWest, northEast]` or `null` if unavailable.
  Future<List<PointEntity>?> getBounds() async {
    final result = (await getBoundsJs(_mapId).toDart) as List;
    if (result.length == 4) {
      return [
        PointEntity(
            (result[0] as num).toDouble(), (result[1] as num).toDouble()),
        PointEntity(
            (result[2] as num).toDouble(), (result[3] as num).toDouble()),
      ];
    }
    return null;
  }

  /// Adjusts the map view to contain the specified bounding box.
  ///
  /// - [southWest] The south-west corner of the bounding box
  /// - [northEast] The north-east corner of the bounding box
  /// - [durationMs] Animation duration in milliseconds (default: 300)
  Future<void> fitBounds(PointEntity southWest, PointEntity northEast,
          {int durationMs = 300}) async =>
      await fitBoundsJs(southWest.lon, southWest.lat, northEast.lon,
              northEast.lat, durationMs, _mapId)
          .toDart;

  /// Enables or disables zooming via mouse scroll/touch pinch.
  ///
  /// - [enabled] Whether to enable scroll zoom interaction
  Future<void> enableScrollZoom(bool enabled) async =>
      await enableScrollZoomJs(enabled, _mapId).toDart;

  /// Enables or disables dragging the map with mouse/touch.
  ///
  /// - [enabled] Whether to enable drag interaction
  Future<void> enableDrag(bool enabled) async =>
      await enableDragJs(enabled, _mapId).toDart;

  // Placemark Operations =====================================================

  /// Adds a new placemark to the map.
  ///
  /// - [placemark] The placemark entity to add
  Future<void> addPlacemark(PlacemarkEntity placemark) async {
    if (placemark.onTap != null) {
      _ensurePlacemarkDispatcher();
      _placemarkTapCallbacks[placemark.id] =
          (placemark.onTap!, placemark.userData);
    }
    await addPlacemarkJs(
      placemark.geometry.toJs(),
      _jsify(placemark.properties.toJson()),
      _jsify(placemark.options.toJson()),
      _mapId,
      placemark.id,
    ).toDart;
    _placemarks.add(placemark);
  }

  /// Removes a placemark from the map.
  ///
  /// - [placemarkId] The ID of the placemark to remove
  Future<void> removePlacemark(String placemarkId) async {
    _placemarkTapCallbacks.remove(placemarkId);
    await removePlacemarkJs(placemarkId, _mapId).toDart;
    _placemarks.removeWhere((e) => e.id == placemarkId);
  }

  /// Updates the position of an existing placemark.
  ///
  /// - [placemarkId] The ID of the placemark to update
  /// - [newGeometry] The new geographic coordinates
  Future<void> updatePlacemarkGeometry(
          String placemarkId, PointEntity newGeometry) async =>
      await updatePlacemarkGeometryJs(placemarkId, newGeometry.toJs()).toDart;

  /// Updates the properties (e.g. data fields) of a placemark.
  ///
  /// - [placemarkId] The ID of the placemark to update
  /// - [newProperties] The new properties object
  Future<void> updatePlacemarkProperties(
          String placemarkId, PlacemarkProperties newProperties) async =>
      await updatePlacemarkPropertiesJs(
              placemarkId, _jsify(newProperties.toJson()))
          .toDart;

  /// Updates the visual options (e.g. icon, color) of a placemark.
  ///
  /// - [placemarkId] The ID of the placemark to update
  /// - [newOptions] The new visual options
  Future<void> updatePlacemarkOptions(
          String placemarkId, PlacemarkOptions newOptions) async =>
      await updatePlacemarkOptionsJs(placemarkId, _jsify(newOptions.toJson()))
          .toDart;

  // Polygon Operations =======================================================

  /// Adds a new polygon to the map.
  ///
  /// - [polygon] The polygon entity to add
  Future<void> addPolygon(PolygonEntity polygon) async {
    final jsGeometry = polygon.geometry
        .map((ring) => ring.map((point) => point.toJs()).toList().toJS)
        .toList()
        .toJS;
    await addPolygonJs(
      jsGeometry,
      _jsify(polygon.properties.toJson()),
      _jsify(polygon.options.toJson()),
      _mapId,
      polygon.id,
    ).toDart;
    _polygons.add(polygon);
  }

  /// Removes a polygon from the map.
  ///
  /// - [polygonId] The ID of the polygon to remove
  Future<void> removePolygon(String polygonId) async {
    await removePolygonJs(polygonId, _mapId).toDart;
    _polygons.removeWhere((e) => e.id == polygonId);
  }

  /// Updates the geometry (vertex coordinates) of a polygon.
  ///
  /// - [polygonId] The ID of the polygon to update
  /// - [newGeometry] The new array of coordinate rings
  Future<void> updatePolygonGeometry(
      String polygonId, List<List<PointEntity>> newGeometry) async {
    final jsGeometry = newGeometry
        .map((ring) => ring.map((point) => point.toJs()).toList().toJS)
        .toList()
        .toJS;
    await updatePolygonGeometryJs(polygonId, jsGeometry).toDart;
  }

  /// Updates the properties (e.g. data fields) of a polygon.
  ///
  /// - [polygonId] The ID of the polygon to update
  /// - [newProperties] The new properties object
  Future<void> updatePolygonProperties(
          String polygonId, PolygonProperties newProperties) async =>
      await updatePolygonPropertiesJs(polygonId, _jsify(newProperties.toJson()))
          .toDart;

  /// Updates the visual options (e.g. fill color, stroke) of a polygon.
  ///
  /// - [polygonId] The ID of the polygon to update
  /// - [newOptions] The new visual options
  Future<void> updatePolygonOptions(
          String polygonId, PolygonOptions newOptions) async =>
      await updatePolygonOptionsJs(polygonId, _jsify(newOptions.toJson()))
          .toDart;

  // Polyline Operations ======================================================

  /// Adds a new polyline to the map.
  ///
  /// - [polyline] The polyline entity to add
  Future<void> addPolyline(PolylineEntity polyline) async {
    final jsGeometry =
        polyline.geometry.map((point) => point.toJs()).toList().toJS;
    await addPolylineJs(
      jsGeometry,
      _jsify(polyline.properties.toJson()),
      _jsify(polyline.options.toJson()),
      _mapId,
      polyline.id,
    ).toDart;
    _polylines.add(polyline);
  }

  /// Removes a polyline from the map.
  ///
  /// - [polylineId] The ID of the polyline to remove
  Future<void> removePolyline(String polylineId) async {
    await removePolylineJs(polylineId, _mapId).toDart;
    _polylines.removeWhere((e) => e.id == polylineId);
  }

  /// Updates the geometry (vertex coordinates) of a polyline.
  ///
  /// - [polylineId] The ID of the polyline to update
  /// - [newGeom] The new array of coordinates
  Future<void> updatePolylineGeometry(
      String polylineId, List<PointEntity> newGeom) async {
    final jsGeometry = newGeom.map((point) => point.toJs()).toList().toJS;
    await updatePolylineGeometryJs(polylineId, jsGeometry).toDart;
  }

  /// Updates the properties (e.g. data fields) of a polyline.
  ///
  /// - [polylineId] The ID of the polyline to update
  /// - [props] The new properties object
  Future<void> updatePolylineProperties(
          String polylineId, PolylineProperties props) async =>
      await updatePolylinePropertiesJs(polylineId, _jsify(props.toJson()))
          .toDart;

  /// Updates the visual options (e.g. color, width) of a polyline.
  ///
  /// - [polylineId] The ID of the polyline to update
  /// - [opts] The new visual options
  Future<void> updatePolylineOptions(
          String polylineId, PolylineOptions opts) async =>
      await updatePolylineOptionsJs(polylineId, _jsify(opts.toJson())).toDart;

  // Cluster Operations =======================================================

  /// Adds a clustered group of placemarks to the map.
  ///
  /// Placemarks are automatically grouped based on zoom level using
  /// the ymaps3 `@yandex/ymaps3-clusterer` package.
  Future<void> addCluster(ClusterEntity cluster) async {
    if (cluster.onTap != null) {
      _ensureClusterDispatcher();
      _clusterTapCallbacks[cluster.id] = (cluster.onTap!, cluster.userData);
    }
    // Register individual placemark tap callbacks for markers inside the cluster
    _ensurePlacemarkDispatcher();
    final pmIds = <String>{};
    for (final p in cluster.placemarks) {
      pmIds.add(p.id);
      if (p.onTap != null) {
        _placemarkTapCallbacks[p.id] = (p.onTap!, p.userData);
      }
    }
    _clusterPlacemarkIds[cluster.id] = pmIds;

    if (cluster.options.style is ClusterBuilderStyle) {
      final builderStyle = cluster.options.style as ClusterBuilderStyle;
      final placemarkMap = {for (final p in cluster.placemarks) p.id: p};
      _ensureClusterDispatcher();
      js.context['_yandexMapClusterIconBuilder_${cluster.id}'] =
          js.allowInterop((dynamic idsArray, dynamic lat, dynamic lon) {
        final idList = (js_util.dartify(idsArray)! as List).cast<String>();
        final points = idList
            .map((id) => placemarkMap[id])
            .whereType<PlacemarkEntity>()
            .toList();
        final location = PointEntity(
          (lat as num).toDouble(),
          (lon as num).toDouble(),
        );

        final resultOrFuture = builderStyle.builder(points, location);
        if (resultOrFuture is Future<ClusterAppearance>) {
          // Async path — build a native JS Promise via dart:js only.
          // Mixing dart:js_util.jsify with dart:js_interop's .toJS causes the
          // resolved value to cross the boundary as a Dart wrapper, so JS
          // spread ({ ...options, ...resolved }) silently copies nothing.
          js.JsFunction? resolvePromise;
          final jsPromise = js.JsObject(
            js.context['Promise'] as js.JsFunction,
            [
              js.allowInterop((dynamic resolve, dynamic _) {
                resolvePromise = resolve as js.JsFunction;
              }),
            ],
          );
          resultOrFuture.then((a) {
            resolvePromise?.apply([
              js.JsObject.jsify(_serializeAppearance(a, cluster.id, idList)),
            ]);
          });
          return js.JsObject.jsify({'_promise': jsPromise});
        }
        // Sync path — dart:js JsObject.jsify is unwrapped correctly by
        // allowInterop; dart:js_util.jsify is not.
        return js.JsObject.jsify(
            _serializeAppearance(resultOrFuture, cluster.id, idList));
      });
    }
    await addClusterJs(_jsify(cluster.toJson()), _mapId).toDart;
    _clusterIds.add(cluster.id);
  }

  static Map<String, dynamic> _serializeAppearance(
    ClusterAppearance appearance,
    String clusterId,
    List<String> placemarkIds,
  ) {
    final result = <String, dynamic>{};
    if (appearance.style != null) {
      result.addAll(appearance.style!.toJson());
    }
    if (appearance.onTap != null) {
      final sortedIds = List<String>.from(placemarkIds)..sort();
      final tapId = '${clusterId}_${sortedIds.join(',')}';
      _clusterTapCallbacks[tapId] = (appearance.onTap!, appearance.userData);
      (_builderTapIds[clusterId] ??= {}).add(tapId);
      result['tapId'] = tapId;
    }
    return result;
  }

  /// Removes a cluster group from the map.
  Future<void> removeCluster(String clusterId) async {
    _clusterTapCallbacks.remove(clusterId);
    _clusterPlacemarkIds
        .remove(clusterId)
        ?.forEach(_placemarkTapCallbacks.remove);
    _builderTapIds.remove(clusterId)?.forEach(_clusterTapCallbacks.remove);
    js.context.deleteProperty('_yandexMapClusterIconBuilder_$clusterId');
    await removeClusterJs(clusterId, _mapId).toDart;
    _clusterIds.remove(clusterId);
  }

  void dispose() {
    for (final p in _placemarks) {
      _placemarkTapCallbacks.remove(p.id);
    }
    for (final clusterId in _clusterIds) {
      _clusterTapCallbacks.remove(clusterId);
      _clusterPlacemarkIds
          .remove(clusterId)
          ?.forEach(_placemarkTapCallbacks.remove);
      _builderTapIds.remove(clusterId)?.forEach(_clusterTapCallbacks.remove);
      js.context.deleteProperty('_yandexMapClusterIconBuilder_$clusterId');
    }
    _userLocationCallbacks.remove(_mapId);
  }

  /// Replaces the placemarks inside an existing cluster.
  Future<void> updateCluster(
      String clusterId, List<PlacemarkEntity> newPlacemarks) async {
    // Clean old placemark tap callbacks and register new ones
    _clusterPlacemarkIds[clusterId]?.forEach(_placemarkTapCallbacks.remove);
    _ensurePlacemarkDispatcher();
    final pmIds = <String>{};
    for (final p in newPlacemarks) {
      pmIds.add(p.id);
      if (p.onTap != null) {
        _placemarkTapCallbacks[p.id] = (p.onTap!, p.userData);
      }
    }
    _clusterPlacemarkIds[clusterId] = pmIds;

    await updateClusterJs(
      clusterId,
      _jsify({'placemarks': newPlacemarks.map((p) => p.toJson()).toList()}),
      _mapId,
    ).toDart;
  }

  // User Location Operations =================================================

  /// Shows a pulsing blue dot at the device's current GPS position.
  ///
  /// Position is tracked continuously via the browser Geolocation API.
  /// - [onLocationUpdate] optional callback fired on every position update.
  Future<void> showUserLocation(
      {void Function(PointEntity)? onLocationUpdate}) async {
    if (onLocationUpdate != null) {
      _ensureUserLocationDispatcher();
      _userLocationCallbacks[_mapId] = onLocationUpdate;
    }
    await showUserLocationJs(_mapId).toDart;
  }

  /// Removes the user-location dot and stops geolocation tracking.
  Future<void> hideUserLocation() async {
    _userLocationCallbacks.remove(_mapId);
    await hideUserLocationJs(_mapId).toDart;
  }

  /// Updates the map scheme layer theme and/or customization.
  ///
  /// Both parameters are optional — pass null to leave that aspect unchanged.
  ///
  /// [theme] — theme name, e.g. `'light'` or `'dark'`.
  /// [customization] — list of customization rule objects (Yandex Maps
  /// customization JSON format). Pass null to keep the current customization.
  Future<void> setTheme({
    String? theme,
    List<Map<String, dynamic>>? customization,
  }) async {
    final jsTheme = theme != null ? js_util.jsify(theme) as JSAny : null;
    final jsCustomization =
        customization != null ? js_util.jsify(customization) as JSAny : null;
    await setThemeJs(jsTheme, jsCustomization, _mapId).toDart;
  }

  JSAny _jsify(Map<String, dynamic> value) => js_util.jsify(value) as JSAny;
}
