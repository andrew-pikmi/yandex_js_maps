import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:yandex_js_maps/yandex_js_maps.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await YandexJsMapFactory.setMapApi(
    'YOUR_MAP_API_KEY',
    lang: 'en_US',
  );
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapDemoPage(),
    );
  }
}

// ─── Root page ───────────────────────────────────────────────────────────────

class MapDemoPage extends StatefulWidget {
  const MapDemoPage({super.key});

  @override
  State<MapDemoPage> createState() => _MapDemoPageState();
}

class _MapDemoPageState extends State<MapDemoPage> {
  String _lastEvent = 'Tap the map, marker or cluster to see events here';

  void _log(String message) {
    debugPrint(message);
    setState(() => _lastEvent = message);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Yandex JS Maps Example'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Markers'),
              Tab(text: 'Clusters'),
              Tab(text: 'Polygons'),
              Tab(text: 'Polylines'),
              Tab(text: 'Camera'),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                _lastEvent,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _MarkersTab(onEvent: _log),
                  _ClustersTab(onEvent: _log),
                  _PolygonsTab(onEvent: _log),
                  _PolylinesTab(onEvent: _log),
                  _CameraTab(onEvent: _log),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Markers Tab ─────────────────────────────────────────────────────────────
// Demonstrates: addPlacemark · removePlacemark · zoomIn · zoomOut
//               setTheme · showUserLocation · hideUserLocation
//               onMapTap · onMapLongTap · onCameraPositionChanged
//               MapBehavior · PlacemarkOptions.iconBytes (canvas-rendered pin)
//               userData — arbitrary Dart object passed through onTap

class _MarkersTab extends StatefulWidget {
  const _MarkersTab({required this.onEvent});
  final void Function(String) onEvent;

  @override
  State<_MarkersTab> createState() => _MarkersTabState();
}

class _MarkersTabState extends State<_MarkersTab> {
  YandexJsMapController? _ctrl;
  bool _darkTheme = false;
  bool _locationOn = false;
  String? _kremlinId;
  PointEntity? _currentLocation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ControlBar(children: [
          _MapIconButton(
            icon: Icons.add,
            tooltip: 'Zoom in',
            onPressed: _ctrl == null ? null : () => _ctrl!.zoomIn(),
          ),
          _MapIconButton(
            icon: Icons.remove,
            tooltip: 'Zoom out',
            onPressed: _ctrl == null ? null : () => _ctrl!.zoomOut(),
          ),
          _MapIconButton(
            icon: _darkTheme ? Icons.light_mode : Icons.dark_mode,
            tooltip:
                _darkTheme ? 'Switch to Light theme' : 'Switch to Dark theme',
            onPressed: _ctrl == null
                ? null
                : () async {
                    final next = _darkTheme ? 'light' : 'dark';
                    await _ctrl!.setTheme(theme: next);
                    setState(() => _darkTheme = !_darkTheme);
                    widget.onEvent('Theme → $next');
                  },
          ),
          _MapIconButton(
            icon: _locationOn ? Icons.location_off : Icons.my_location,
            tooltip: _locationOn ? 'Hide my location' : 'Show my location',
            onPressed: _ctrl == null
                ? null
                : () async {
                    if (_locationOn) {
                      await _ctrl!.hideUserLocation();
                      setState(() => _locationOn = false);
                      widget.onEvent('User location hidden');
                    } else {
                      await _ctrl!.showUserLocation(
                        onLocationUpdate: (p) {
                          setState(() => _currentLocation = p);
                          widget.onEvent('My location: ${_fmt(p)}');
                        },
                      );
                      setState(() => _locationOn = true);
                      widget.onEvent('User location tracking started');
                    }
                  },
          ),
          _MapIconButton(
            icon: Icons.navigation,
            tooltip: 'Move to my location',
            onPressed: _currentLocation == null || _ctrl == null
                ? null
                : () => _ctrl!.moveTo(_currentLocation!, zoom: 15),
          ),
          const _Divider(),
          _MapIconButton(
            icon: Icons.delete_outline,
            tooltip: 'Remove Kremlin marker',
            onPressed: _kremlinId == null || _ctrl == null
                ? null
                : () async {
                    await _ctrl!.removePlacemark(_kremlinId!);
                    setState(() => _kremlinId = null);
                    widget.onEvent('Kremlin marker removed');
                  },
          ),
        ]),
        YandexJsMap(
          mapState: const MapState(
            center: PointEntity(55.751244, 37.618423),
            zoom: 12,
            behaviors: [
              MapBehavior.drag,
              MapBehavior.scrollZoom,
              MapBehavior.pinchZoom,
              MapBehavior.dblClick,
            ],
          ),
          onMapTap: (p) => widget.onEvent('Map tap: ${_fmt(p)}'),
          onMapLongTap: (p) => widget.onEvent('Long tap: ${_fmt(p)}'),
          onCameraPositionChanged: (pos, finished) {
            if (finished) {
              widget.onEvent(
                'Camera: ${_fmt(pos.center)}, zoom ${pos.zoom.toStringAsFixed(1)}',
              );
            }
          },
          onMapCreated: (ctrl) {
            setState(() => _ctrl = ctrl);
            unawaited(_addMarkers(ctrl));
          },
        ),
      ],
    );
  }

  Future<void> _addMarkers(YandexJsMapController ctrl) async {
    final kremlinIcon = await _renderToPng(
      (c, s) => _paintMarkerPin(c, s, const Color(0xFFD32F2F)),
      48,
      48,
    );
    final theaterIcon = await _renderToPng(
      (c, s) => _paintMarkerPin(c, s, const Color(0xFF1976D2)),
      48,
      48,
    );

    // userData is any Dart object — cast it back to your type in onTap.
    final kremlin = PlacemarkEntity(
      geometry: const PointEntity(55.751244, 37.618423),
      properties: const PlacemarkProperties(hintContent: 'Kremlin'),
      options:
          PlacemarkOptions(style: PlacemarkImageStyle(iconBytes: kremlinIcon)),
      userData: {'name': 'Kremlin', 'type': 'landmark', 'rating': 5},
      onTap: (p, userData) {
        final data = userData as Map;
        widget.onEvent(
          'Marker "${data['name']}" · type: ${data['type']} · rating: ${data['rating']}',
        );
      },
    );
    final theater = PlacemarkEntity(
      geometry: const PointEntity(55.761773, 37.618972),
      properties: const PlacemarkProperties(hintContent: 'Bolshoy Theatre'),
      options:
          PlacemarkOptions(style: PlacemarkImageStyle(iconBytes: theaterIcon)),
      userData: {'name': 'Bolshoy Theatre', 'type': 'culture', 'rating': 5},
      onTap: (p, userData) {
        final data = userData as Map;
        widget.onEvent(
          'Marker "${data['name']}" · type: ${data['type']} · rating: ${data['rating']}',
        );
      },
    );

    await ctrl.addPlacemark(kremlin);
    await ctrl.addPlacemark(theater);
    if (mounted) setState(() => _kremlinId = kremlin.id);
  }
}

// ─── Clusters Tab ────────────────────────────────────────────────────────────
// Demonstrates: addCluster · removeCluster · userData in placemarks
//               clusterIconBuilder — dynamic icon based on cluster contents:
//                 all restaurants → orange, all hotels → blue, mixed → purple

class _ClustersTab extends StatefulWidget {
  const _ClustersTab({required this.onEvent});
  final void Function(String) onEvent;

  @override
  State<_ClustersTab> createState() => _ClustersTabState();
}

class _ClustersTabState extends State<_ClustersTab> {
  YandexJsMapController? _ctrl;
  String? _clusterId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ControlBar(children: [
          _MapIconButton(
            icon: Icons.layers_clear,
            tooltip: 'Remove cluster',
            onPressed: _clusterId == null || _ctrl == null
                ? null
                : () async {
                    await _ctrl!.removeCluster(_clusterId!);
                    setState(() => _clusterId = null);
                    widget.onEvent('Cluster removed');
                  },
          ),
        ]),
        YandexJsMap(
          mapState: const MapState(
            center: PointEntity(55.755864, 37.617698),
            zoom: 10,
          ),
          onMapTap: (p) => widget.onEvent('Cluster map tap: ${_fmt(p)}'),
          onMapCreated: (ctrl) {
            setState(() => _ctrl = ctrl);
            unawaited(_addCluster(ctrl));
          },
        ),
      ],
    );
  }

  Future<void> _addCluster(YandexJsMapController ctrl) async {
    // Pre-render the three possible cluster icons asynchronously,
    // then use the cached bytes synchronously in clusterIconBuilder.
    final iconRestaurant = await _renderToPng(
      (c, s) => _paintClusterIcon(c, s, const Color(0xFFE65100)), // orange
      48, 48,
    );
    final iconHotel = await _renderToPng(
      (c, s) => _paintClusterIcon(c, s, const Color(0xFF1565C0)), // blue
      48, 48,
    );
    final iconMixed = await _renderToPng(
      (c, s) => _paintClusterIcon(c, s, const Color(0xFF6A1B9A)), // purple
      48, 48,
    );

    // Placemarks carry userData with a 'category' field.
    final placemarks = [
      PlacemarkEntity(
        geometry: const PointEntity(55.751244, 37.618423),
        properties: const PlacemarkProperties(hintContent: 'Cafe Pushkin'),
        userData: {'name': 'Cafe Pushkin', 'category': 'restaurant'},
      ),
      PlacemarkEntity(
        geometry: const PointEntity(55.752244, 37.619423),
        properties: const PlacemarkProperties(hintContent: 'Varvarка Bar'),
        userData: {'name': 'Varvarка Bar', 'category': 'restaurant'},
      ),
      PlacemarkEntity(
        geometry: const PointEntity(55.753244, 37.620423),
        properties: const PlacemarkProperties(hintContent: 'Hotel Metropol'),
        userData: {'name': 'Hotel Metropol', 'category': 'hotel'},
      ),
      PlacemarkEntity(
        geometry: const PointEntity(55.754244, 37.621423),
        properties: const PlacemarkProperties(hintContent: 'Hotel National'),
        userData: {'name': 'Hotel National', 'category': 'hotel'},
      ),
      PlacemarkEntity(
        geometry: const PointEntity(55.755244, 37.622423),
        properties: const PlacemarkProperties(hintContent: 'Selfie Restaurant'),
        userData: {'name': 'Selfie Restaurant', 'category': 'restaurant'},
      ),
      PlacemarkEntity(
        geometry: const PointEntity(55.756244, 37.623423),
        properties: const PlacemarkProperties(hintContent: 'Four Seasons'),
        userData: {'name': 'Four Seasons', 'category': 'hotel'},
      ),
    ];

    final cluster = ClusterEntity(
      placemarks: placemarks,
      options: ClusterOptions(
        gridSize: 80,
        // ClusterBuilderStyle receives exactly the placemarks in this cluster.
        // Icons are pre-rendered above; the builder just picks the right one.
        style: ClusterBuilderStyle(
          builder: (clusterPlacemarks) {
            final categories = clusterPlacemarks
                .map((p) => (p.userData as Map)['category'] as String)
                .toSet();
            if (categories.length == 1) {
              return categories.first == 'restaurant'
                  ? iconRestaurant
                  : iconHotel;
            }
            return iconMixed;
          },
        ),
      ),
      userData: {'zone': 'city-center'},
      onTap: (p, count, userData) {
        final data = userData as Map;
        widget.onEvent(
          'Cluster zone "${data['zone']}" · $count points · ${_fmt(p)}',
        );
      },
    );

    await ctrl.addCluster(cluster);
    if (mounted) setState(() => _clusterId = cluster.id);
  }
}

// ─── Polygons Tab ─────────────────────────────────────────────────────────────

class _PolygonsTab extends StatelessWidget {
  const _PolygonsTab({required this.onEvent});
  final void Function(String) onEvent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        YandexJsMap(
          mapState: const MapState(
            center: PointEntity(55.751, 37.616),
            zoom: 12,
          ),
          polygons: [
            PolygonEntity(
              geometry: const [
                [
                  PointEntity(55.742, 37.600),
                  PointEntity(55.758, 37.602),
                  PointEntity(55.760, 37.628),
                  PointEntity(55.744, 37.632),
                ],
              ],
              properties: const PolygonProperties(hintContent: 'Test polygon'),
              options: const PolygonOptions(
                fillColor: '2e7d32',
                fillOpacity: 0.28,
                strokeColor: '1b5e20',
                strokeWidth: 3,
              ),
            ),
          ],
          onMapTap: (p) => onEvent('Polygon map tap: ${_fmt(p)}'),
          onMapCreated: (_) {},
        ),
      ],
    );
  }
}

// ─── Polylines Tab ───────────────────────────────────────────────────────────

class _PolylinesTab extends StatelessWidget {
  const _PolylinesTab({required this.onEvent});
  final void Function(String) onEvent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        YandexJsMap(
          mapState: const MapState(
            center: PointEntity(55.752, 37.624),
            zoom: 12,
          ),
          polylines: [
            PolylineEntity(
              geometry: const [
                PointEntity(55.745, 37.607),
                PointEntity(55.750, 37.617),
                PointEntity(55.756, 37.630),
                PointEntity(55.761, 37.643),
              ],
              properties: const PolylineProperties(hintContent: 'Route'),
              options: const PolylineOptions(
                strokeColor: 'f57c00',
                strokeWidth: 4,
                strokeOpacity: 0.95,
              ),
            ),
          ],
          onMapTap: (p) => onEvent('Polyline map tap: ${_fmt(p)}'),
          onMapCreated: (_) {},
        ),
      ],
    );
  }
}

// ─── Camera Tab ──────────────────────────────────────────────────────────────

class _CameraTab extends StatefulWidget {
  const _CameraTab({required this.onEvent});
  final void Function(String) onEvent;

  @override
  State<_CameraTab> createState() => _CameraTabState();
}

class _CameraTabState extends State<_CameraTab> {
  YandexJsMapController? _ctrl;
  bool _scrollZoom = true;
  bool _drag = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ElevatedButton(
                onPressed: _ctrl == null
                    ? null
                    : () => _ctrl!.moveTo(
                          const PointEntity(55.751244, 37.618423),
                          zoom: 15,
                        ),
                child: const Text('→ Kremlin'),
              ),
              ElevatedButton(
                onPressed: _ctrl == null
                    ? null
                    : () => _ctrl!.moveTo(
                          const PointEntity(55.755864, 37.617698),
                          zoom: 11,
                        ),
                child: const Text('→ Moscow'),
              ),
              ElevatedButton(
                onPressed: _ctrl == null
                    ? null
                    : () => _ctrl!.fitBounds(
                          const PointEntity(55.57, 37.27),
                          const PointEntity(55.92, 37.97),
                        ),
                child: const Text('Fit Moscow'),
              ),
              ElevatedButton(
                onPressed: _ctrl == null
                    ? null
                    : () async {
                        final zoom = await _ctrl!.getZoom();
                        widget.onEvent('Current zoom: $zoom');
                      },
                child: const Text('Get Zoom'),
              ),
              ElevatedButton(
                onPressed: _ctrl == null
                    ? null
                    : () async {
                        final center = await _ctrl!.getCenter();
                        if (center != null) {
                          widget.onEvent('Center: ${_fmt(center)}');
                        }
                      },
                child: const Text('Get Center'),
              ),
              ElevatedButton(
                onPressed: _ctrl == null
                    ? null
                    : () async {
                        final bounds = await _ctrl!.getBounds();
                        if (bounds != null && bounds.length == 2) {
                          widget.onEvent(
                            'Bounds SW:${_fmt(bounds[0])} NE:${_fmt(bounds[1])}',
                          );
                        }
                      },
                child: const Text('Get Bounds'),
              ),
              ElevatedButton(
                onPressed: _ctrl == null
                    ? null
                    : () async {
                        final next = !_scrollZoom;
                        await _ctrl!.enableScrollZoom(next);
                        setState(() => _scrollZoom = next);
                        widget.onEvent('Scroll zoom: ${next ? "on" : "off"}');
                      },
                child: Text('Scroll Zoom: ${_scrollZoom ? "ON" : "OFF"}'),
              ),
              ElevatedButton(
                onPressed: _ctrl == null
                    ? null
                    : () async {
                        final next = !_drag;
                        await _ctrl!.enableDrag(next);
                        setState(() => _drag = next);
                        widget.onEvent('Drag: ${next ? "on" : "off"}');
                      },
                child: Text('Drag: ${_drag ? "ON" : "OFF"}'),
              ),
            ],
          ),
        ),
        YandexJsMap(
          mapState: const MapState(
            center: PointEntity(55.755864, 37.617698),
            zoom: 11,
          ),
          onCameraPositionChanged: (pos, finished) {
            if (finished) {
              widget.onEvent(
                'Camera: ${_fmt(pos.center)}, zoom ${pos.zoom.toStringAsFixed(1)}',
              );
            }
          },
          onMapTap: (p) => widget.onEvent('Camera tab tap: ${_fmt(p)}'),
          onMapCreated: (ctrl) {
            setState(() => _ctrl = ctrl);
          },
        ),
      ],
    );
  }
}

// ─── Shared UI ───────────────────────────────────────────────────────────────

class _ControlBar extends StatelessWidget {
  const _ControlBar({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(children: children),
    );
  }
}

class _MapIconButton extends StatelessWidget {
  const _MapIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onPressed,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 24,
      child: VerticalDivider(width: 16, thickness: 1),
    );
  }
}

// ─── Canvas helpers ──────────────────────────────────────────────────────────

/// Async render — use when the caller can await (e.g. in initState / onMapCreated).
Future<Uint8List> _renderToPng(
  void Function(Canvas, Size) paint,
  int width,
  int height,
) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(
    recorder,
    Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
  );
  paint(canvas, Size(width.toDouble(), height.toDouble()));
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

/// Location pin: large arc top + pointed tip anchored at bottom-center.
void _paintMarkerPin(Canvas canvas, Size size, Color color) {
  final cx = size.width / 2;
  final r = size.width * 0.30;
  final cy = r + 2;
  final tipY = size.height - 2;
  final leftX = cx - r * 0.55;
  final rightX = cx + r * 0.55;
  final joinY = cy + r * 0.80;

  final path = Path()
    ..moveTo(leftX, joinY)
    ..arcToPoint(
      Offset(rightX, joinY),
      radius: Radius.circular(r),
      clockwise: false,
      largeArc: true,
    )
    ..lineTo(cx, tipY)
    ..close();

  // Drop shadow
  canvas.drawPath(
    path.shift(const Offset(0, 2)),
    Paint()
      ..color = Colors.black.withOpacity(0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
  );
  // Fill
  canvas.drawPath(path, Paint()..color = color);
  // White inner dot
  canvas.drawCircle(Offset(cx, cy), r * 0.35, Paint()..color = Colors.white);
}

/// Three circles arranged in equilateral triangle — suggests grouped items.
void _paintClusterIcon(Canvas canvas, Size size, Color color) {
  final r = size.width * 0.25;
  final cx = size.width / 2;
  final cy = size.height / 2;
  final d = r * 0.9;

  final positions = [
    Offset(cx, cy - d),
    Offset(cx - d * 0.87, cy + d * 0.5),
    Offset(cx + d * 0.87, cy + d * 0.5),
  ];

  final fill = Paint()..color = color;
  final stroke = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  for (final c in positions) {
    canvas.drawCircle(c, r, fill);
  }
  for (final c in positions) {
    canvas.drawCircle(c, r, stroke);
  }
}

// ─── Utilities ───────────────────────────────────────────────────────────────

String _fmt(PointEntity p) =>
    'lat=${p.lat.toStringAsFixed(5)}, lon=${p.lon.toStringAsFixed(5)}';
