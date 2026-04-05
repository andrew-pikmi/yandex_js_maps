part of '../../../yandex_js_maps.dart';

/// Contains content properties for polygon elements on Yandex Maps.
///
/// These properties define the textual content displayed in polygon elements,
/// including hints and balloon popups when interacting with the shape.
class PolygonProperties {
  /// Stored in YMapFeature properties for custom use
  final String? hintContent;

  /// Creates polygon content properties
  const PolygonProperties({
    this.hintContent,
  });

  /// Serializes properties to JSON format
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (hintContent != null) 'hintContent': hintContent,
    };
  }
}
