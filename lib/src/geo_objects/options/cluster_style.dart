part of '../../../yandex_js_maps.dart';

/// Defines the visual appearance of a cluster marker.
///
/// Use [ClusterCircleStyle] for the built-in circle marker,
/// or [ClusterImageStyle] for a custom image rendered at its natural size.
sealed class ClusterStyle {
  const ClusterStyle();
  Map<String, dynamic> toJson();
}

/// Built-in circle cluster marker style.
class ClusterCircleStyle extends ClusterStyle {
  /// Fill color in CSS format (e.g. '#FF0000' or 'ff0000').
  final String color;

  /// Diameter of the circle in pixels.
  final int size;

  /// Border color in CSS format.
  final String borderColor;

  /// Border width in pixels.
  final int borderWidth;

  /// Whether the circle has a drop shadow.
  final bool hasShadow;

  const ClusterCircleStyle({
    this.color = '#1e98ff',
    this.size = 36,
    this.borderColor = '#ffffff',
    this.borderWidth = 2,
    this.hasShadow = true,
  });

  @override
  Map<String, dynamic> toJson() => {
        'clusterColor': _cssColor(color),
        'clusterSize': size,
        'borderColor': _cssColor(borderColor),
        'borderWidth': borderWidth,
        'hasShadow': hasShadow,
      };
}

/// Custom image cluster marker style.
/// The image is rendered at its natural size — no scaling applied.
class ClusterImageStyle extends ClusterStyle {
  /// Raw image bytes, encoded as a base64 data URL and passed to JS.
  final Uint8List iconBytes;

  ClusterImageStyle({required this.iconBytes});

  @override
  Map<String, dynamic> toJson() => {
        'iconDataUrl': 'data:image/png;base64,${base64.encode(iconBytes)}',
      };
}

/// Dynamic cluster icon built per-cluster based on its contents.
///
/// [builder] is called synchronously by the JS clusterer each time a cluster
/// is rendered. It receives exactly the [PlacemarkEntity] objects grouped into
/// that specific cluster and must return image bytes for the icon.
///
/// Not serialized — registered as a synchronous JS callback in the controller.
class ClusterBuilderStyle extends ClusterStyle {
  final Uint8List Function(List<PlacemarkEntity> clusterPlacemarks) builder;

  ClusterBuilderStyle({required this.builder});

  /// Nothing to serialize — the builder is registered as a JS callback separately.
  @override
  Map<String, dynamic> toJson() => {};
}
