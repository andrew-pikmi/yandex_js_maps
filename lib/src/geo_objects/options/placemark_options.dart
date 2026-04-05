part of '../../../yandex_js_maps.dart';

/// Configuration options for customizing the appearance and behavior of placemarks.
///
/// All visual defaults live here — the JS layer is a pure renderer with no hardcoded styles.
class PlacemarkOptions {
  /// Raw image bytes used as the marker icon.
  /// Converted to a base64 data URL and rendered as an `<img>` element.
  /// When set, [iconColor], [borderColor], [borderWidth], [hasShadow] are ignored.
  final Uint8List? iconBytes;

  /// Background fill color of the default circle icon in CSS format (e.g., '#FF0000' or 'ff0000').
  /// Ignored when [iconBytes] is set.
  final String? iconColor;

  /// Width and height of the marker icon in pixels.
  final int iconSize;

  /// Border color of the default circle icon in CSS format.
  /// Ignored when [iconBytes] is set.
  final String borderColor;

  /// Border width of the default circle icon in pixels.
  /// Ignored when [iconBytes] is set.
  final int borderWidth;

  /// Whether the default circle icon has a drop shadow.
  /// Ignored when [iconBytes] is set.
  final bool hasShadow;

  /// Whether the placemark can be dragged.
  final bool draggable;

  /// Whether the placemark is visible.
  final bool visible;

  /// Cursor style when hovering.
  final String cursor;

  const PlacemarkOptions({
    this.iconBytes,
    this.iconColor,
    this.iconSize = 20,
    this.borderColor = '#ffffff',
    this.borderWidth = 2,
    this.hasShadow = true,
    this.draggable = false,
    this.visible = true,
    this.cursor = 'pointer',
  });

  Map<String, dynamic> toJson() {
    final mappedColor = _mapCssColor(iconColor);
    return <String, dynamic>{
      if (iconBytes != null)
        'iconDataUrl': 'data:image/png;base64,${base64.encode(iconBytes!)}',
      if (mappedColor != null) 'iconColor': mappedColor,
      'iconSize': iconSize,
      'borderColor': borderColor,
      'borderWidth': borderWidth,
      'hasShadow': hasShadow,
      'draggable': draggable,
      'visible': visible,
      'cursor': cursor,
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
