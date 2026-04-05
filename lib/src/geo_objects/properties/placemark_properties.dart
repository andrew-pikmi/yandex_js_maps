part of '../../../yandex_js_maps.dart';

/// Contains content properties for placemark elements on Yandex Maps.
///
/// These properties define the textual content displayed in placemark elements,
/// including icons, hints, and balloon popups.
class PlacemarkProperties {
  /// HTML content displayed inside the placemark icon
  final String? iconContent;

  /// Caption text displayed near the placemark icon
  final String? iconCaption;

  /// Content displayed as browser tooltip on hover
  final String? hintContent;

  /// Creates placemark content properties
  const PlacemarkProperties({
    this.iconContent,
    this.iconCaption,
    this.hintContent,
  });

  /// Serializes properties to JSON format
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (iconContent != null) 'iconContent': iconContent,
      if (iconCaption != null) 'iconCaption': iconCaption,
      if (hintContent != null) 'hintContent': hintContent,
    };
  }
}
