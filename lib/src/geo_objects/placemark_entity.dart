part of '../../yandex_js_maps.dart';

/// Represents a marker (placemark) that can be displayed on a Yandex Map.
///
/// A placemark consists of a geographic location, visual properties,
/// and content that appears in popups and hints.
class PlacemarkEntity {
  /// Unique identifier for this placemark
  final String id;

  /// Geographic coordinates where the placemark is positioned
  final PointEntity geometry;

  /// Content and informational properties of the placemark
  final PlacemarkProperties properties;

  /// Visual styling and behavior options
  final PlacemarkOptions options;

  /// Called when the user taps this placemark.
  /// Not serialized — wired up via JS callback registry.
  final void Function(PointEntity point)? onTap;

  PlacemarkEntity({
    required this.geometry,
    this.properties = const PlacemarkProperties(),
    this.options = const PlacemarkOptions(),
    this.onTap,
  }) : id = const Uuid().v4();

  /// Serializes the placemark to JSON format.
  ///
  /// Useful for storage or transmission of placemark data.
  Map<String, dynamic> toJson() => {
        'id': id,
        'geometry': [geometry.lon, geometry.lat],
        'properties': properties.toJson(),
        'options': options.toJson(),
      };
}
