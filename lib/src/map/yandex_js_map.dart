part of '../../yandex_js_maps.dart';

/// The primary widget for embedding Yandex Maps in a Flutter Web application.
///
/// This widget creates an interactive map instance and provides a controller
/// for programmatic map manipulation. It handles the integration between
/// Flutter and Yandex Maps JavaScript API.
class YandexJsMap extends StatefulWidget {
  /// Creates a Yandex Maps widget instance.
  ///
  /// [onMapCreated] callback is required and provides the controller instance.
  /// Other parameters provide initial configuration for the map.
  const YandexJsMap({
    super.key,
    required this.onMapCreated,
    this.mapState = const MapState(),
    this.onCameraPositionChanged,
    this.onMapTap,
    this.onMapLongTap,
  });

  /// The initial view state of the map
  final MapState mapState;

  /// Called on every camera update.
  /// [finished] is true when the camera has stopped moving.
  final void Function(CameraPosition position, bool finished)?
      onCameraPositionChanged;

  /// Called when the user taps on an empty area of the map (not on a geo object).
  final void Function(PointEntity point)? onMapTap;

  /// Called on long press (touch hold ≥500ms) or right-click on an empty map area.
  final void Function(PointEntity point)? onMapLongTap;

  /// Callback that provides the [YandexJsMapController] instance
  /// when the map is fully initialized and ready for interaction.
  /// Fires only after JS initialization completes.
  final void Function(YandexJsMapController controller) onMapCreated;

  @override
  State<YandexJsMap> createState() => _YandexJsMapState();
}

/// The state class for [YandexJsMap] widget.
///
/// Handles:
/// - Map element initialization
/// - Platform view registration
/// - Controller creation
class _YandexJsMapState extends State<YandexJsMap> {
  /// Controller instance for map interaction
  late final YandexJsMapController controller;

  /// Unique identifier for this map instance
  final mapId = const Uuid().v4();

  /// Completes when the JS initYandexMap Promise resolves
  final _readyCompleter = Completer<void>();

  @override
  void initState() {
    super.initState();

    // Register a platform view for embedding the Yandex Map HTML element
    ui_web.platformViewRegistry.registerViewFactory(
      'yandex-map-html-$mapId',
      (int viewId) {
        // Create container div for the map
        final divId = 'yandex-map-div-$mapId';
        final element = html.DivElement()
          ..id = divId
          ..style.width = '100%'
          ..style.height = '100%';

        // Convert Dart objects to JavaScript-compatible formats
        final jsState = js.JsObject.jsify(widget.mapState.toJson());

        // Build callbacks object for camera and input listeners
        final jsCallbacks = js.JsObject(js.context['Object']);

        final onCameraChanged = widget.onCameraPositionChanged;
        if (onCameraChanged != null) {
          jsCallbacks['onCameraPositionChanged'] = js.allowInterop(
            (dynamic lat, dynamic lon, dynamic zoom, bool finished) {
              onCameraChanged(
                CameraPosition(
                  center: PointEntity(
                      (lat as num).toDouble(), (lon as num).toDouble()),
                  zoom: (zoom as num).toDouble(),
                ),
                finished,
              );
            },
          );
        }

        final onTap = widget.onMapTap;
        if (onTap != null) {
          jsCallbacks['onMapTap'] = js.allowInterop(
            (dynamic lat, dynamic lon) {
              onTap(PointEntity(
                  (lat as num).toDouble(), (lon as num).toDouble()));
            },
          );
        }

        final onLongTap = widget.onMapLongTap;
        if (onLongTap != null) {
          jsCallbacks['onMapLongTap'] = js.allowInterop(
            (dynamic lat, dynamic lon) {
              onLongTap(PointEntity(
                  (lat as num).toDouble(), (lon as num).toDouble()));
            },
          );
        }

        // Initialize the Yandex Map through JavaScript interop.
        // initYandexMap returns a JS Promise; wire Dart Completer via dart:js .then()
        // to avoid dart:js_util.promiseToFuture incompatibility with JsObject wrappers.
        final initPromise = js.context.callMethod(
            'initYandexMap', [divId, jsState, jsCallbacks]) as js.JsObject;

        initPromise.callMethod('then', [
          js.allowInterop((dynamic _) {
            if (!_readyCompleter.isCompleted) _readyCompleter.complete();
          }),
          js.allowInterop((dynamic e) {
            if (!_readyCompleter.isCompleted) {
              _readyCompleter
                  .completeError(e?.toString() ?? 'initYandexMap failed');
            }
          }),
        ]);

        // Create controller instance
        controller = YandexJsMapController._init(divId);

        return element;
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    final placemarksIds =
        js.JsArray.from(controller.placemarks.map((e) => e.id));
    final polygonsIds = js.JsArray.from(controller.polygons.map((e) => e.id));
    final polylinesIds = js.JsArray.from(controller.polylines.map((e) => e.id));
    js.context.callMethod('destroyYandexMap',
        ['yandex-map-div-$mapId', placemarksIds, polygonsIds, polylinesIds]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      viewType: 'yandex-map-html-$mapId',

      /// Call onMapCreated only after JS initialization completes
      onPlatformViewCreated: (_) {
        _readyCompleter.future.then((_) => widget.onMapCreated(controller));
      },
    );
  }
}
