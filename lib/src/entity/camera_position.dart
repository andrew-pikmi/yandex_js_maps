part of '../../yandex_js_maps.dart';

/// Current camera position of the map.
class CameraPosition {
  /// Geographic coordinates of the map center
  final PointEntity center;

  /// Current zoom level
  final double zoom;

  const CameraPosition({required this.center, required this.zoom});
}
