part of '../../../yandex_js_maps.dart';

/// Configuration options for a clustered placemark group.
class ClusterOptions {
  /// Grid cell size in pixels used for grouping nearby placemarks.
  /// Larger values produce more aggressive clustering.
  final int gridSize;

  /// Zoom level above which clustering stops and individual markers are shown.
  /// Null means cluster at all zoom levels.
  final int? maxZoom;

  /// Whether to display the count of grouped placemarks on the cluster marker.
  final bool showClusterCount;

  /// Visual style of the cluster marker.
  /// Defaults to [ClusterCircleStyle] with built-in circle appearance.
  final ClusterStyle style;

  const ClusterOptions({
    this.gridSize = 64,
    this.maxZoom,
    this.showClusterCount = true,
    this.style = const ClusterCircleStyle(),
  });

  Map<String, dynamic> toJson() => {
        'gridSize': gridSize,
        if (maxZoom != null) 'maxZoom': maxZoom,
        'showClusterCount': showClusterCount,
        ...style.toJson(),
      };
}
