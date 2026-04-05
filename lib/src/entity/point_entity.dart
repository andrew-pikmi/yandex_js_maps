part of '../../yandex_js_maps.dart';

/// Represents a geographic point defined by latitude and longitude coordinates.
///
/// This class is used throughout the API to specify locations on the map.
/// The coordinates follow the WGS84 standard used by most mapping systems.
class PointEntity {
  /// The latitude coordinate in decimal degrees.
  ///
  /// Valid range: -90.0 to 90.0 (South to North)
  final double lat;

  /// The longitude coordinate in decimal degrees.
  ///
  /// Valid range: -180.0 to 180.0 (West to East)
  final double lon;

  /// Creates a geographic point with the specified coordinates.
  ///
  /// - [lat] The latitude value between -90.0 and 90.0
  /// - [lon] The longitude value between -180.0 and 180.0
  const PointEntity(this.lat, this.lon);

  /// Converts the point to a JavaScript-compatible array format.
  ///
  /// Used for interoperability with the Yandex Maps JavaScript API.
  /// Returns a JS array where first element is longitude and second is latitude.
  JSArray<JSNumber> toJs() => [lon.toJS, lat.toJS].toJS;
}
