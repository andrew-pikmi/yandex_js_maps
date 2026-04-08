part of '../../../yandex_js_maps.dart';

// Shared CSS color normalizer — accessible to all parts of this library.
// Accepts '#rrggbb', 'rrggbb', '#rrggbbaa', 'rrggbbaa', or any CSS color string.
String _cssColor(String color) {
  final trimmed = color.trim();
  final isHex = RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(trimmed) ||
      RegExp(r'^[0-9a-fA-F]{8}$').hasMatch(trimmed);
  return isHex ? '#$trimmed' : trimmed;
}

/// Defines the visual appearance of a placemark icon.
///
/// Use [PlacemarkCircleStyle] for the built-in circle marker,
/// or [PlacemarkImageStyle] for a custom image rendered at its natural size.
sealed class PlacemarkStyle {
  const PlacemarkStyle();
  Map<String, dynamic> toJson();
}

/// Built-in circle marker style.
class PlacemarkCircleStyle extends PlacemarkStyle {
  /// Fill color in CSS format (e.g. '#FF0000' or 'ff0000').
  final String iconColor;

  /// Diameter of the circle in pixels.
  final int iconSize;

  /// Border color in CSS format.
  final String borderColor;

  /// Border width in pixels.
  final int borderWidth;

  /// Whether the circle has a drop shadow.
  final bool hasShadow;

  const PlacemarkCircleStyle({
    this.iconColor = '#1e98ff',
    this.iconSize = 20,
    this.borderColor = '#ffffff',
    this.borderWidth = 2,
    this.hasShadow = true,
  });

  @override
  Map<String, dynamic> toJson() => {
        'iconColor': _cssColor(iconColor),
        'iconSize': iconSize,
        'borderColor': _cssColor(borderColor),
        'borderWidth': borderWidth,
        'hasShadow': hasShadow,
      };
}

/// Custom image marker style.
/// By default the image is rendered at its natural size.
/// Use [iconSize] to set an explicit display size in logical pixels
/// (useful when the image was rendered at device pixel ratio).
class PlacemarkImageStyle extends PlacemarkStyle
    implements MapObjectImageStyle {
  /// Raw image bytes, encoded as a base64 data URL and passed to JS.
  @override
  final Uint8List iconBytes;

  /// Logical display size for the icon in pixels.
  /// If null the image renders at its natural (intrinsic) dimensions.
  @override
  final ({int width, int height})? iconSize;

  const PlacemarkImageStyle({
    required this.iconBytes,
    this.iconSize,
  });

  @override
  Map<String, dynamic> toJson() => {
        'iconDataUrl': 'data:image/png;base64,${base64.encode(iconBytes)}',
        if (iconSize != null) 'iconWidth': iconSize!.width,
        if (iconSize != null) 'iconHeight': iconSize!.height,
      };
}
