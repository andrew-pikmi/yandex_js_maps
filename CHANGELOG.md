## 2.0.0

### Added
- Typed map behaviors via `MapBehavior` enum
- Map event callbacks on widget:
  - `onCameraPositionChanged(CameraPosition position, bool finished)`
  - `onMapTap(PointEntity point)`
  - `onMapLongTap(PointEntity point)`
- Cluster API:
  - `ClusterEntity`, `ClusterOptions`
  - `addCluster`, `removeCluster`, `updateCluster`
- User location API:
  - `showUserLocation({onLocationUpdate})`
  - `hideUserLocation()`
- Runtime map theme updates via `setTheme({theme, customization})`

### Changed
- README rewritten as a clean usage guide (setup + integration + API overview)
- Map initialization now waits for JS init Promise before firing `onMapCreated`
- Public geometry serialization normalized to Yandex format `[lon, lat]`
- JS bridge simplified to JSON/jsify-based interop (removed unused static JS model layer)
- Marker and cluster icons now support raw PNG bytes (`iconBytes`)
- Polygon/polyline styling mapped directly to Yandex `YMapFeature` style object

### Breaking Changes
- Removed geocoding/suggest API:
  - `GeocodeOptions`, `GeocodeResult`, `SuggestOptions`, `SuggestResult`
  - `YandexJsMapController.geocode(...)`, `YandexJsMapController.suggest(...)`
- Removed map option/type abstractions:
  - `MapOptions`, `MapType`, `MapControl`, `MapTypeExtension`
  - `YandexJsMap.mapOptions`
  - `YandexJsMapController.setMapType(...)`
- `MapState` updated:
  - `behaviors` now `List<MapBehavior>?` (was `List<String>?`)
  - `controls` and `type` removed
- Removed `toJs()` API from entities/options/properties and deleted `lib/src/js_models/*`
- Removed balloon fields from properties:
  - `PlacemarkProperties.balloonContent*`
  - `PolygonProperties.balloonContent*`
  - `PolylineProperties.balloonContent*`
- `PlacemarkOptions`, `PolygonOptions`, and `PolylineOptions` now expose only supported/rendered fields for current JS layer

### Migration Notes
- Replace string behaviors with enum values from `MapBehavior`
- Remove usages of `mapOptions`, `setMapType`, `geocode`, and `suggest`
- Re-check object styling options because legacy fields were removed
- Ensure these scripts are connected in `web/index.html`:
  - `yandex_map_helpers.js`
  - `yandex_map_init.js`
  - `yandex_map_controller.js`

## 1.0.1

### Improvements
- Added proper resource cleanup in `dispose()` method
- Improved memory management by destroying map objects
- Updated code formatting rules
- Enhanced documentation

### Changes
- Added strict analysis rules in `analysis_options.yaml`
- Updated README.md with additional usage details
- Changed code formatting command to use 120 chars line length
- Added proper map disposal in `YandexJsMap` widget
- Implemented `destroyYandexMap` function in JS interop

### Fixed
- Potential memory leaks by properly cleaning up:
  - Map instances
  - Placemarks
  - Polygons
  - Polylines

## 1.0.0

- Initial release 🎉
- Full support for Yandex Maps via Flutter Web
- Features:
  - Embed interactive maps
  - Add/Remove/Update placemarks, polygons, and polylines
  - Camera control (move, zoom, bounds)
  - Geocoding and suggest API integration
  - JS interop with custom controllers
