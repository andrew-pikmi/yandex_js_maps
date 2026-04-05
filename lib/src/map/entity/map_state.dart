part of '../../../yandex_js_maps.dart';

/// Defines the initial state and configuration for a Yandex Map instance.
///
/// This class specifies how the map should be displayed when first loaded,
/// including viewport position, zoom level, and UI controls.
class MapState {
  /// Geographic coordinates for the map's initial center point
  final PointEntity center;

  /// Optional bounding box to constrain the map view
  ///
  /// When specified, the map will fit to show this area.
  /// Typically contains southwest and northeast points.
  final List<PointEntity>? bounds;

  /// Initial zoom level (0-23)
  final int zoom;

  /// Enabled map interaction behaviors
  ///
  final List<MapBehavior>? behaviors;

  /// Margins around the map viewport in pixels [top, right, bottom, left]
  final List<double>? margin;

  /// Creates map initial state configuration
  ///
  /// - [center] Initial map center coordinates (defaults to Moscow)
  /// - [bounds] Optional bounding box for constrained view
  /// - [zoom] Initial zoom level (default 10)
  /// - [behaviors] Enabled interaction behaviors
  /// - [margin] Viewport margins in pixels
  const MapState({
    this.center = const PointEntity(55.75, 37.62),
    this.bounds,
    this.zoom = 10,
    this.behaviors = const [],
    this.margin,
  });

  /// Serializes the map state to JSON format
  Map<String, dynamic> toJson() {
    return {
      'center': [center.lon, center.lat],
      if (bounds != null) 'bounds': bounds?.map((e) => [e.lon, e.lat]).toList(),
      'zoom': zoom,
      'behaviors': behaviors?.map((e) => e.value).toList(),
      if (margin != null) 'margin': margin,
    };
  }
}
