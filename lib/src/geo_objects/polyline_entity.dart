part of '../../yandex_js_maps.dart';

/// Represents a linear feature (polyline) that can be displayed on a Yandex Map.
///
/// A polyline consists of a sequence of connected points that form a path,
/// along with visual properties and content for popups and hints.
class PolylineEntity {
  /// Unique identifier for this polyline
  final String id;

  /// Ordered list of points defining the polyline path
  final List<PointEntity> geometry;

  /// Content and informational properties of the polyline
  final PolylineProperties properties;

  /// Visual styling and behavior options
  final PolylineOptions options;

  /// Creates a map polyline with the specified attributes.
  ///
  /// - [geometry] List of points defining the path (required)
  /// - [properties] Content and informational properties
  /// - [options] Visual styling and behavior options
  PolylineEntity({
    required this.geometry,
    this.properties = const PolylineProperties(),
    this.options = const PolylineOptions(),
  }) : id = const Uuid().v4();

  /// Serializes the polyline to JSON format.
  ///
  /// Useful for storage or transmission of polyline data.
  Map<String, dynamic> toJson() => {
        'id': id,
        'geometry': geometry.map((e) => [e.lon, e.lat]).toList(),
        'properties': properties.toJson(),
        'options': options.toJson(),
      };
}
