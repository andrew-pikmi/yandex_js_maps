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
/// By default the image is rendered at its natural size.
/// Use [iconSize] to set an explicit display size in logical pixels.
class ClusterImageStyle extends ClusterStyle {
  /// Raw image bytes, encoded as a base64 data URL and passed to JS.
  final Uint8List iconBytes;

  /// Logical display size for the cluster icon in pixels.
  /// If null the image renders at its natural (intrinsic) dimensions.
  final ({int width, int height})? iconSize;

  ClusterImageStyle({required this.iconBytes, this.iconSize});

  @override
  Map<String, dynamic> toJson() => {
        'iconDataUrl': 'data:image/png;base64,${base64.encode(iconBytes)}',
        if (iconSize != null) 'iconWidth': iconSize!.width,
        if (iconSize != null) 'iconHeight': iconSize!.height,
      };
}

/// Per-cluster appearance returned by [ClusterBuilderStyle.builder].
///
/// Allows setting icon, userData, and onTap individually for each
/// rendered cluster — similar to the mobile Yandex Maps SDK.
class ClusterAppearance {
  /// Visual style for this cluster marker.
  /// Use [ClusterImageStyle] or [ClusterCircleStyle].
  final ClusterStyle? style;

  /// Arbitrary data attached to this specific cluster visual.
  /// Available in [onTap] callback.
  final Object? userData;

  /// Called when the user taps this specific cluster marker.
  final void Function(PointEntity point, int count, Object? userData)? onTap;

  const ClusterAppearance({this.style, this.userData, this.onTap});
}

/// Dynamic cluster icon built per-cluster based on its contents.
///
/// [builder] is called by the JS clusterer each time a cluster is rendered.
/// It receives exactly the [PlacemarkEntity] objects grouped into that
/// specific cluster and returns a [ClusterAppearance] with icon, userData,
/// and onTap for that cluster.
///
/// The builder may return synchronously or as a [Future]. Async builders
/// run concurrently — the cluster marker is hidden until the builder resolves.
///
/// Not serialized — registered as a JS callback in the controller.
class ClusterBuilderStyle extends ClusterStyle {
  final FutureOr<ClusterAppearance> Function(
      List<PlacemarkEntity> clusterPlacemarks) builder;

  ClusterBuilderStyle({required this.builder});

  /// Nothing to serialize — the builder is registered as a JS callback separately.
  @override
  Map<String, dynamic> toJson() => {};
}
