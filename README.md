# Yandex JS Maps for Flutter Web

`yandex_js_maps` is a Flutter Web plugin for embedding and controlling Yandex Maps JavaScript API v3 from Dart.

## Requirements

- Flutter Web (browser runtime)
- Dart `>=3.4.3 <4.0.0`
- Yandex Maps JavaScript API key
- Internet access to load Yandex Maps JS and clusterer package
- Browser geolocation permission for `showUserLocation()`

## 1. Add dependency

```yaml
dependencies:
  yandex_js_maps: ^2.0.0
```

## 2. Connect required JS files

Add these scripts to `web/index.html` before `flutter_bootstrap.js`:

```html
<script src="packages/yandex_js_maps/src/js/yandex_map_helpers.js"></script>
<script src="packages/yandex_js_maps/src/js/yandex_map_init.js"></script>
<script src="packages/yandex_js_maps/src/js/yandex_map_controller.js"></script>
```

## 3. Initialize Yandex Maps API

Call `setMapApi` once before `runApp`:

```dart
import 'package:flutter/material.dart';
import 'package:yandex_js_maps/yandex_js_maps.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await YandexJsMapFactory.setMapApi('YOUR_YANDEX_API_KEY', lang: 'ru_RU');
  runApp(const MyApp());
}
```

## 4. Add map widget

`YandexJsMap` already wraps itself with `Expanded`, so place it inside `Column`, `Row`, or `Flex`.

```dart
import 'package:flutter/material.dart';
import 'package:yandex_js_maps/yandex_js_maps.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  YandexJsMapController? _controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        YandexJsMap(
          mapState: const MapState(
            center: PointEntity(55.751244, 37.618423),
            zoom: 12,
            behaviors: [
              MapBehavior.drag,
              MapBehavior.scrollZoom,
              MapBehavior.pinchZoom,
              MapBehavior.dblClick,
            ],
          ),
          onMapCreated: (controller) => _controller = controller,
          onMapTap: (point) => debugPrint('tap: ${point.lat}, ${point.lon}'),
          onMapLongTap: (point) => debugPrint('long tap: ${point.lat}, ${point.lon}'),
          onCameraPositionChanged: (camera, finished) {
            if (finished) {
              debugPrint('zoom=${camera.zoom}, center=${camera.center.lat},${camera.center.lon}');
            }
          },
        ),
      ],
    );
  }
}
```

## Controller examples

### Placemarks

Marker appearance is controlled by a `PlacemarkStyle` subtype passed to `PlacemarkOptions`:

```dart
// Built-in circle marker
await _controller?.addPlacemark(
  PlacemarkEntity(
    geometry: const PointEntity(55.751244, 37.618423),
    properties: const PlacemarkProperties(hintContent: 'Kremlin'),
    options: const PlacemarkOptions(
      style: PlacemarkCircleStyle(
        iconColor: '#d32f2f',
        iconSize: 28,
      ),
    ),
    userData: {'id': 42, 'name': 'Kremlin'},
    onTap: (point, userData) {
      final data = userData as Map;
      debugPrint('tapped: ${data['name']}');
    },
  ),
);

// Custom image marker (rendered at natural size)
final iconBytes = await _loadPngBytes(); // your Uint8List
await _controller?.addPlacemark(
  PlacemarkEntity(
    geometry: const PointEntity(55.761773, 37.618972),
    options: PlacemarkOptions(
      style: PlacemarkImageStyle(iconBytes: iconBytes),
    ),
    onTap: (point, userData) => debugPrint('custom marker tapped'),
  ),
);
```

### Clusters

Cluster appearance is controlled by a `ClusterStyle` subtype passed to `ClusterOptions`:

```dart
// Built-in circle cluster
await _controller?.addCluster(
  ClusterEntity(
    placemarks: [
      PlacemarkEntity(geometry: const PointEntity(55.751244, 37.618423)),
      PlacemarkEntity(geometry: const PointEntity(55.752244, 37.619423)),
    ],
    options: const ClusterOptions(
      gridSize: 80,
      maxZoom: 14, // stop clustering above zoom 14
      style: ClusterCircleStyle(color: '#1565C0', size: 40),
    ),
    userData: {'zone': 'center'},
    onTap: (point, count, userData) {
      final data = userData as Map;
      debugPrint('cluster zone "${data['zone']}" · $count points');
    },
  ),
);

// Custom image cluster
final clusterIcon = await _renderClusterIcon();
await _controller?.addCluster(
  ClusterEntity(
    placemarks: [...],
    options: ClusterOptions(
      style: ClusterImageStyle(iconBytes: clusterIcon),
    ),
  ),
);

// Dynamic icon based on cluster contents
// Icons must be pre-rendered asynchronously and cached before addCluster is called,
// because the builder is invoked synchronously by the JS clusterer.
final iconA = await _renderIconA();
final iconB = await _renderIconB();

await _controller?.addCluster(
  ClusterEntity(
    placemarks: [
      PlacemarkEntity(
        geometry: const PointEntity(55.751244, 37.618423),
        userData: {'category': 'restaurant'},
      ),
      PlacemarkEntity(
        geometry: const PointEntity(55.752244, 37.619423),
        userData: {'category': 'hotel'},
      ),
    ],
    options: ClusterOptions(
      style: ClusterBuilderStyle(
        builder: (clusterPlacemarks) {
          final categories = clusterPlacemarks
              .map((p) => (p.userData as Map)['category'] as String)
              .toSet();
          return categories.length == 1 && categories.first == 'restaurant'
              ? iconA
              : iconB;
        },
      ),
    ),
  ),
);
```

### Camera

```dart
await _controller?.moveTo(const PointEntity(55.751244, 37.618423), zoom: 14);
await _controller?.zoomIn();
await _controller?.setTheme(theme: 'dark');
```

## Style classes

### PlacemarkStyle

| Class | Description |
|---|---|
| `PlacemarkCircleStyle` | Built-in circle. Fields: `iconColor`, `iconSize`, `borderColor`, `borderWidth`, `hasShadow` |
| `PlacemarkImageStyle` | Custom image from `Uint8List`. Rendered at natural size. |

### ClusterStyle

| Class | Description |
|---|---|
| `ClusterCircleStyle` | Built-in circle. Fields: `color`, `size`, `borderColor`, `borderWidth`, `hasShadow` |
| `ClusterImageStyle` | Custom image from `Uint8List`. Rendered at natural size. |
| `ClusterBuilderStyle` | Dynamic icon. `builder` receives the exact `List<PlacemarkEntity>` in the current cluster. Must return `Uint8List` synchronously — pre-render async icons before calling `addCluster`. |

## userData

Both `PlacemarkEntity` and `ClusterEntity` accept `userData: Object?`. It is not serialized to JS — it is stored in Dart and passed back to `onTap` as the last argument. Cast to your type inside the callback.

```dart
PlacemarkEntity(
  geometry: ...,
  userData: myModel,
  onTap: (point, userData) {
    final model = userData as MyModel;
  },
);
```

## API overview

- Camera: `moveTo`, `setZoom`, `zoomIn`, `zoomOut`, `getZoom`, `getCenter`, `getBounds`, `fitBounds`
- Interaction: `enableScrollZoom`, `enableDrag`
- Placemarks: `addPlacemark`, `removePlacemark`, `updatePlacemarkGeometry`, `updatePlacemarkProperties`, `updatePlacemarkOptions`
- Polygons: `addPolygon`, `removePolygon`, `updatePolygonGeometry`, `updatePolygonProperties`, `updatePolygonOptions`
- Polylines: `addPolyline`, `removePolyline`, `updatePolylineGeometry`, `updatePolylineProperties`, `updatePolylineOptions`
- Clusters: `addCluster`, `removeCluster`, `updateCluster`
- Extra: `showUserLocation`, `hideUserLocation`, `setTheme`

## Example app

A full demo is available in [`example/lib/main.dart`](example/lib/main.dart).

## Notes

- Package supports only Flutter Web.
- `YandexJsMapFactory.setMapApi()` should be called once at app startup.
- API key should be stored securely for your environment (CI/CD secrets, env config, etc.).
