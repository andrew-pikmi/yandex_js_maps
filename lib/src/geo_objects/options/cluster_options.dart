part of '../../../yandex_js_maps.dart';

/// Configuration options for clustered placemark groups.
///
/// All visual defaults live here — the JS layer is a pure renderer with no hardcoded styles.
class ClusterOptions {
  /// Grid cell size in pixels used for grouping nearby placemarks.
  final int gridSize;

  /// Raw image bytes used as the cluster icon.
  /// Converted to a base64 data URL and rendered as an `<img>` element.
  /// When set, [clusterColor], [borderColor], [borderWidth], [hasShadow] are ignored.
  /// If [showClusterCount] is true, the count is shown as a small badge overlay.
  final Uint8List? iconBytes;

  /// Background fill color of the cluster marker in CSS format (e.g., '#FF0000' or 'ff0000').
  /// Ignored when [iconBytes] is set.
  final String? clusterColor;

  /// Width and height of the cluster marker in pixels.
  final int clusterSize;

  /// Border color of the cluster marker in CSS format.
  /// Ignored when [iconBytes] is set.
  final String borderColor;

  /// Border width of the cluster marker in pixels.
  /// Ignored when [iconBytes] is set.
  final int borderWidth;

  /// Whether the cluster marker has a drop shadow.
  /// Ignored when [iconBytes] is set.
  final bool hasShadow;

  /// Whether to display the count of grouped placemarks inside the cluster marker.
  final bool showClusterCount;

  const ClusterOptions({
    this.gridSize = 64,
    this.iconBytes,
    this.clusterColor,
    this.clusterSize = 36,
    this.borderColor = '#ffffff',
    this.borderWidth = 2,
    this.hasShadow = true,
    this.showClusterCount = true,
  });

  Map<String, dynamic> toJson() {
    final mappedColor = _mapCssColor(clusterColor) ?? '#1e98ff';
    return {
      'gridSize': gridSize,
      if (iconBytes != null)
        'iconDataUrl': 'data:image/png;base64,${base64.encode(iconBytes!)}',
      'clusterColor': mappedColor,
      'clusterSize': clusterSize,
      'borderColor': borderColor,
      'borderWidth': borderWidth,
      'hasShadow': hasShadow,
      'showClusterCount': showClusterCount,
    };
  }

  String? _mapCssColor(String? color) {
    if (color == null) return null;
    final trimmed = color.trim();
    if (trimmed.isEmpty) return null;
    final isHex = RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(trimmed) ||
        RegExp(r'^[0-9a-fA-F]{8}$').hasMatch(trimmed);
    if (isHex) return '#$trimmed';
    return trimmed;
  }
}
