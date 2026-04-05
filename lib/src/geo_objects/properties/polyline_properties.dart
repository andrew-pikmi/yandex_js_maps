part of '../../../yandex_js_maps.dart';

/// Contains content properties for polyline elements on Yandex Maps.
///
/// These properties define the textual content displayed when interacting with
/// polylines, including hints and balloon popups.
class PolylineProperties {
  /// Stored in YMapFeature properties for custom use
  final String? hintContent;

  /// Creates polyline content properties
  const PolylineProperties({
    this.hintContent,
  });

  /// Serializes properties to JSON format
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (hintContent != null) 'hintContent': hintContent,
    };
  }
}
