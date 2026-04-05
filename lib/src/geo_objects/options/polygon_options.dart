part of '../../../yandex_js_maps.dart';

/// Configuration options for customizing the appearance of polygons on Yandex Maps.
///
/// All color/opacity/width values map directly to the ymaps3 YMapFeature style object.
class PolygonOptions {
  /// Fill color in CSS format (e.g., '#FF0000' or 'ff0000')
  final String? fillColor;

  /// Fill opacity (0.0 to 1.0)
  final double? fillOpacity;

  /// Whether to fill the polygon
  final bool fill;

  /// Stroke/border color in CSS format
  final String? strokeColor;

  /// Stroke opacity (0.0 to 1.0)
  final double? strokeOpacity;

  /// Stroke width in pixels
  final int? strokeWidth;

  /// Whether to show outline
  final bool outline;

  /// z-index for render order
  final int? zIndex;

  /// Creates polygon customization options
  const PolygonOptions({
    this.fillColor,
    this.fillOpacity,
    this.fill = true,
    this.strokeColor,
    this.strokeOpacity,
    this.strokeWidth,
    this.outline = true,
    this.zIndex,
  });

  /// Serializes options to JSON format (style object for YMapFeature)
  Map<String, dynamic> toJson() {
    final mappedFillColor = _mapCssColor(fillColor) ?? '#1e98ff';
    final mappedStrokeColor = _mapCssColor(strokeColor) ?? '#1e98ff';
    final resolvedFillOpacity = fillOpacity ?? 0.35;
    final resolvedStrokeOpacity = strokeOpacity ?? 1;
    final resolvedStrokeWidth = strokeWidth ?? 2;

    final style = <String, dynamic>{
      'fill':
          fill ? _toRgba(mappedFillColor, resolvedFillOpacity) : 'transparent',
      'stroke': outline
          ? [
              {
                'color': mappedStrokeColor,
                'width': resolvedStrokeWidth,
                'opacity': resolvedStrokeOpacity,
              }
            ]
          : [],
      if (zIndex != null) 'zIndex': zIndex,
    };

    return <String, dynamic>{'style': style};
  }

  String _toRgba(String color, double opacity) {
    final clampedOpacity = opacity.clamp(0, 1).toDouble();
    final hexMatch = RegExp(r'^#([0-9a-fA-F]{6})$').firstMatch(color);
    if (hexMatch == null) return color;
    final hex = hexMatch.group(1)!;
    final red = int.parse(hex.substring(0, 2), radix: 16);
    final green = int.parse(hex.substring(2, 4), radix: 16);
    final blue = int.parse(hex.substring(4, 6), radix: 16);
    return 'rgba($red, $green, $blue, $clampedOpacity)';
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
