part of '../../yandex_js_maps.dart';

/// Represents a polygon shape that can be displayed on a Yandex Map.
///
/// A polygon consists of one or more contours (outer boundary and optional holes),
/// along with visual properties and content for popups and hints.
class PolygonEntity {
  /// Unique identifier for this polygon
  final String id;

  /// List of contours defining the polygon shape
  ///
  /// The first contour is the outer boundary, subsequent contours
  /// represent holes in the polygon
  final List<List<PointEntity>> geometry;

  /// Content and informational properties of the polygon
  final PolygonProperties properties;

  /// Visual styling and behavior options
  final PolygonOptions options;

  /// Creates a map polygon with the specified attributes.
  ///
  /// - [geometry] List of contours defining the shape (required)
  /// - [properties] Content and informational properties
  /// - [options] Visual styling and behavior options
  PolygonEntity({
    required this.geometry,
    this.properties = const PolygonProperties(),
    this.options = const PolygonOptions(),
  }) : id = const Uuid().v4();

  /// Serializes the polygon to JSON format.
  ///
  /// Useful for storage or transmission of polygon data.
  Map<String, dynamic> toJson() => {
        'id': id,
        'geometry':
            geometry.map((e) => e.map((e) => [e.lon, e.lat]).toList()).toList(),
        'properties': properties.toJson(),
        'options': options.toJson(),
      };
}
