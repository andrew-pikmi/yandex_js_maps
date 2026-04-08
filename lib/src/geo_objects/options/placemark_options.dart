part of '../../../yandex_js_maps.dart';

/// Configuration options for customizing the appearance and behavior of a placemark.
class PlacemarkOptions {
  /// Visual style of the marker icon.
  /// Defaults to [PlacemarkCircleStyle] with built-in circle appearance.
  final PlacemarkStyle style;

  /// Whether the placemark can be dragged.
  final bool draggable;

  /// Whether the placemark is visible.
  final bool visible;

  /// Cursor style when hovering.
  final String cursor;

  const PlacemarkOptions({
    PlacemarkStyle? style,
    this.draggable = false,
    this.visible = true,
    this.cursor = 'pointer',
  }) : style = style ?? const PlacemarkCircleStyle();

  Map<String, dynamic> toJson() => {
        ...style.toJson(),
        'draggable': draggable,
        'visible': visible,
        'cursor': cursor,
      };
}
