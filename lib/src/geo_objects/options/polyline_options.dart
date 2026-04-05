part of '../../../yandex_js_maps.dart';

/// Configuration options for customizing the appearance of polylines on Yandex Maps.
///
/// All values map directly to the ymaps3 YMapFeature style object.
class PolylineOptions {
  /// Stroke color in CSS format (e.g., '#FF0000' or 'ff0000')
  final String? strokeColor;

  /// Stroke opacity (0.0 to 1.0)
  final double strokeOpacity;

  /// Stroke width in pixels
  final int strokeWidth;

  /// z-index for render order
  final int? zIndex;

  /// Creates polyline customization options
  const PolylineOptions({
    this.strokeColor,
    this.strokeOpacity = 1.0,
    this.strokeWidth = 1,
    this.zIndex,
  });

  /// Serializes options to JSON format (style object for YMapFeature)
  Map<String, dynamic> toJson() {
    final mappedStrokeColor = _mapCssColor(strokeColor) ?? '#1e98ff';

    final style = <String, dynamic>{
      'stroke': [
        {
          'color': mappedStrokeColor,
          'width': strokeWidth,
          'opacity': strokeOpacity,
        }
      ],
      if (zIndex != null) 'zIndex': zIndex,
    };

    return <String, dynamic>{'style': style};
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
