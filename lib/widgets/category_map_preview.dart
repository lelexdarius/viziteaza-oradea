import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:viziteaza_oradea/utils/app_theme.dart';

typedef _ExtractPoints = List<LatLng> Function(Map<String, dynamic> data);
typedef _GetTitle = String Function(Map<String, dynamic> data);
typedef _OnMarkerTap = void Function(BuildContext ctx, QueryDocumentSnapshot doc);

// ─────────────────────────────────────────────────────────────────────────────
// Utility: creează un BitmapDescriptor circular cu iconița Flutter dată
// ─────────────────────────────────────────────────────────────────────────────
Future<BitmapDescriptor> buildCircleMarkerIcon(
  IconData iconData,
  Color bgColor, {
  double size = 88,
}) async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);

  final bgPaint = Paint()..color = bgColor;
  canvas.drawCircle(Offset(size / 2, size / 2), size / 2 - 2, bgPaint);

  final borderPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;
  canvas.drawCircle(Offset(size / 2, size / 2), size / 2 - 2, borderPaint);

  final tp = TextPainter(textDirection: ui.TextDirection.ltr);
  tp.text = TextSpan(
    text: String.fromCharCode(iconData.codePoint),
    style: TextStyle(
      fontSize: size * 0.45,
      fontFamily: iconData.fontFamily,
      package: iconData.fontPackage,
      color: Colors.white,
    ),
  );
  tp.layout();
  tp.paint(canvas, Offset((size - tp.width) / 2, (size - tp.height) / 2));

  final picture = recorder.endRecording();
  final img = await picture.toImage(size.toInt(), size.toInt());
  final bytes = await img.toByteData(format: ImageByteFormat.png);
  return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
}

// ─────────────────────────────────────────────────────────────────────────────
// CategoryMapPreview – hartă compactă cu sincronizare live Firestore
// ─────────────────────────────────────────────────────────────────────────────
class CategoryMapPreview extends StatefulWidget {
  /// Colecția Firestore din care se citesc obiectivele
  final String collection;

  /// Culoarea de fundal a marker-ului
  final Color markerColor;

  /// Iconița marker-ului (Material Icons)
  final IconData markerIcon;

  /// Extrage lista de LatLng dintr-un document Firestore
  final _ExtractPoints extractPoints;

  /// Returnează titlul afișat în InfoWindow
  final _GetTitle getTitle;

  /// Navigare la pagina de detaliu când se apasă pe InfoWindow
  final _OnMarkerTap onMarkerTap;

  const CategoryMapPreview({
    Key? key,
    required this.collection,
    required this.markerColor,
    required this.markerIcon,
    required this.extractPoints,
    required this.getTitle,
    required this.onMarkerTap,
  }) : super(key: key);

  @override
  State<CategoryMapPreview> createState() => _CategoryMapPreviewState();
}

class _CategoryMapPreviewState extends State<CategoryMapPreview> {
  static const Color _kBrand = Color(0xFF004E64);
  BitmapDescriptor? _icon;

  @override
  void initState() {
    super.initState();
    _buildIcon();
  }

  Future<void> _buildIcon() async {
    final icon = await buildCircleMarkerIcon(widget.markerIcon, widget.markerColor);
    if (mounted) setState(() => _icon = icon);
  }

  Set<Marker> _buildMarkers(
    List<QueryDocumentSnapshot> docs,
    BuildContext ctx,
  ) {
    final markers = <Marker>{};
    int id = 0;
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final points = widget.extractPoints(data);
      final title = widget.getTitle(data);
      for (final point in points) {
        final mid = '${widget.collection}_$id';
        id++;
        markers.add(Marker(
          markerId: MarkerId(mid),
          position: point,
          icon: _icon ?? BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: title,
            snippet: 'Atinge pentru detalii',
            onTap: () => widget.onMarkerTap(ctx, doc),
          ),
        ));
      }
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 14),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => _CategoryFullScreenMap(
              collection: widget.collection,
              markerColor: widget.markerColor,
              markerIcon: widget.markerIcon,
              extractPoints: widget.extractPoints,
              getTitle: widget.getTitle,
              onMarkerTap: widget.onMarkerTap,
            ),
          ),
        ),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(widget.collection)
                  .snapshots(),
              builder: (ctx, snapshot) {
                final markers =
                    snapshot.hasData && _icon != null
                        ? _buildMarkers(snapshot.data!.docs, ctx)
                        : <Marker>{};
                return Stack(
                  children: [
                    AbsorbPointer(
                      child: GoogleMap(
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(47.0722, 21.9217),
                          zoom: 13,
                        ),
                        markers: markers,
                        zoomControlsEnabled: false,
                        myLocationButtonEnabled: false,
                        compassEnabled: false,
                        mapToolbarEnabled: false,
                        liteModeEnabled: false,
                        onMapCreated: (controller) =>
                            AppTheme.applyMapStyle(controller),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: _kBrand.withOpacity(0.90),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fullscreen, color: Colors.white, size: 14),
                            SizedBox(width: 5),
                            Text(
                              'Extinde harta',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Harta full-screen pentru o categorie specifică
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryFullScreenMap extends StatefulWidget {
  final String collection;
  final Color markerColor;
  final IconData markerIcon;
  final _ExtractPoints extractPoints;
  final _GetTitle getTitle;
  final _OnMarkerTap onMarkerTap;

  const _CategoryFullScreenMap({
    required this.collection,
    required this.markerColor,
    required this.markerIcon,
    required this.extractPoints,
    required this.getTitle,
    required this.onMarkerTap,
  });

  @override
  State<_CategoryFullScreenMap> createState() =>
      _CategoryFullScreenMapState();
}

class _CategoryFullScreenMapState extends State<_CategoryFullScreenMap> {
  static const Color _kBrand = Color(0xFF004E64);
  BitmapDescriptor? _icon;
  Position? _userPosition;
  bool _locationEnabled = false;

  @override
  void initState() {
    super.initState();
    _buildIcon();
    _tryGetLocation();
  }

  Future<void> _buildIcon() async {
    final icon = await buildCircleMarkerIcon(widget.markerIcon, widget.markerColor, size: 96);
    if (mounted) setState(() => _icon = icon);
  }

  Future<void> _tryGetLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );
        if (mounted) {
          setState(() {
            _userPosition = pos;
            _locationEnabled = true;
          });
        }
      }
    } catch (_) {}
  }

  String _snippet(double lat, double lng) {
    final pos = _userPosition;
    if (pos == null) return 'Atinge pentru detalii';
    final m = Geolocator.distanceBetween(pos.latitude, pos.longitude, lat, lng);
    return m < 1000
        ? '${m.round()} m distanță • Atinge'
        : '${(m / 1000).toStringAsFixed(1)} km distanță • Atinge';
  }

  Set<Marker> _buildMarkers(
    List<QueryDocumentSnapshot> docs,
    BuildContext ctx,
  ) {
    if (_icon == null) return {};
    final markers = <Marker>{};
    int id = 0;
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final points = widget.extractPoints(data);
      final title = widget.getTitle(data);
      for (final point in points) {
        final mid = '${widget.collection}_fs_$id';
        id++;
        markers.add(Marker(
          markerId: MarkerId(mid),
          position: point,
          icon: _icon!,
          infoWindow: InfoWindow(
            title: title,
            snippet: _snippet(point.latitude, point.longitude),
            onTap: () => widget.onMarkerTap(ctx, doc),
          ),
        ));
      }
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(widget.collection)
                .snapshots(),
            builder: (ctx, snapshot) {
              final markers = snapshot.hasData
                  ? _buildMarkers(snapshot.data!.docs, ctx)
                  : <Marker>{};
              return GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(47.0722, 21.9217),
                  zoom: 14,
                ),
                markers: markers,
                myLocationEnabled: _locationEnabled,
                myLocationButtonEnabled: _locationEnabled,
                zoomControlsEnabled: true,
                mapToolbarEnabled: false,
                onMapCreated: (controller) =>
                    AppTheme.applyMapStyle(controller),
              );
            },
          ),
          if (_icon == null)
            Container(
              color: Colors.white.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: _kBrand),
              ),
            ),
          // Buton X
          Positioned(
            top: topPad + 12,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.20),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.close, color: Colors.black87, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
