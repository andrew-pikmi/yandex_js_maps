part of '../../../../yandex_js_maps.dart';

abstract interface class MapObjectImageStyle {
  final Uint8List iconBytes;
  final ({int width, int height})? iconSize;

  const MapObjectImageStyle({
    required this.iconBytes,
    this.iconSize,
  });
}
