part of '../../yandex_js_maps.dart';

/// A group of placemarks that are automatically clustered based on zoom level.
///
/// Uses the ymaps3 `@yandex/ymaps3-clusterer` package internally.
class ClusterEntity {
  /// Unique identifier for this cluster group
  final String id;

  /// Placemarks to include in this cluster
  final List<PlacemarkEntity> placemarks;

  /// Visual and behavior options for the cluster
  final ClusterOptions options;

  /// Called when the user taps the cluster marker.
  /// [point] is the geographic center of the cluster.
  /// [count] is the number of grouped placemarks.
  /// Not serialized — wired up via JS callback registry.
  final void Function(PointEntity point, int count)? onTap;

  ClusterEntity({
    required this.placemarks,
    this.options = const ClusterOptions(),
    this.onTap,
    String? id,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'placemarks': placemarks.map((p) => p.toJson()).toList(),
        'options': options.toJson(),
      };
}
