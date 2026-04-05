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

```dart
await _controller?.moveTo(const PointEntity(55.751244, 37.618423), zoom: 14);
await _controller?.zoomIn();
await _controller?.setTheme(theme: 'dark');

await _controller?.addPlacemark(
  PlacemarkEntity(
    geometry: const PointEntity(55.751244, 37.618423),
    properties: const PlacemarkProperties(hintContent: 'Kremlin'),
    options: const PlacemarkOptions(iconColor: 'd32f2f', iconSize: 28),
    onTap: (point) => debugPrint('placemark tap: ${point.lat}, ${point.lon}'),
  ),
);

await _controller?.addCluster(
  ClusterEntity(
    placemarks: [
      PlacemarkEntity(geometry: const PointEntity(55.751244, 37.618423)),
      PlacemarkEntity(geometry: const PointEntity(55.752244, 37.619423)),
    ],
    options: const ClusterOptions(gridSize: 80, clusterSize: 40),
  ),
);

await _controller?.showUserLocation(
  onLocationUpdate: (point) => debugPrint('me: ${point.lat}, ${point.lon}'),
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
