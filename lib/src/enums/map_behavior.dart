part of '../../yandex_js_maps.dart';

/// Enumeration of map interaction behaviors.
///
/// Used when configuring [MapState.behaviors].
enum MapBehavior {
  /// Allows map dragging
  drag('drag'),

  /// Allows zooming with mouse wheel
  scrollZoom('scrollZoom'),

  /// Allows pinch-to-zoom gestures
  pinchZoom('pinchZoom'),

  /// Allows zooming by double click
  dblClick('dblClick'),

  /// Allows map tilting by mouse
  mouseTilt('mouseTilt'),

  /// Allows map rotation by mouse
  mouseRotate('mouseRotate'),

  /// Allows one-finger zoom on touch devices
  oneFingerZoom('oneFingerZoom'),

  /// Allows panning and tilting interactions
  panTilt('panTilt'),

  /// Allows rotation with pinch gesture
  pinchRotate('pinchRotate'),

  /// Enables magnifier interaction mode
  magnifier('magnifier');

  final String value;

  const MapBehavior(this.value);
}
