import 'package:flutter/material.dart'; // 👈 necesar pentru gestureRecognizers
import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:viziteaza_oradea/cafenele_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'widgets/custom_footer.dart';
import 'dart:io';
import 'services/favorite_service.dart';
import 'models/favorite_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CafeneaDetaliiPage extends StatefulWidget {
  final Cafenea cafe;

  const CafeneaDetaliiPage({Key? key, required this.cafe}) : super(key: key);

  @override
  State<CafeneaDetaliiPage> createState() => _CafeneaDetaliiPageState();
}

class _CafeneaDetaliiPageState extends State<CafeneaDetaliiPage> {
  bool isFavorite = false;
  GoogleMapController? _mapController;
  bool _isMapExpanded = false;

  // 👉 pentru hint favorit
  bool _showFavoriteHint = false;
  bool _hintDismissed = false;

  static const Color kBrand = Color(0xFF004E64);
  static const Color kBg = Color(0xFFE8F1F4);

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFavorite();
    _checkLocationPermission();
    _loadHintStatus();
  }

  Future<void> _loadFavorite() async {
    isFavorite = await FavoriteService.isFavorite(widget.cafe.id);
    if (mounted) setState(() {});
  }

  // 👉 încarcă din telefon dacă hint-ul a fost deja închis
  Future<void> _loadHintStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _hintDismissed = prefs.getBool("favorite_hint_dismissed") ?? false;

    if (!_hintDismissed) {
      // mic delay ca să pară mai „natural”
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _showFavoriteHint = true);
      });
    }
  }

  // 👉 când utilizatorul apasă OK sau X
  Future<void> _dismissHint() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("favorite_hint_dismissed", true);
    if (mounted) setState(() => _showFavoriteHint = false);
  }

  @override
  Widget build(BuildContext context) {
    final cafe = widget.cafe;
    final locations = cafe.locations ?? [];

    final double safeTop = MediaQuery.of(context).padding.top;
    final double headerHeight = kToolbarHeight;
    final double topPadding = safeTop + headerHeight + 12;

    final initialPosition = locations.isNotEmpty
        ? LatLng(locations.first.latitude, locations.first.longitude)
        : const LatLng(47.05, 21.92); // fallback Oradea

    final markers = locations
        .map(
          (loc) => Marker(
            markerId: MarkerId('${loc.latitude}_${loc.longitude}_${cafe.title}'),
            position: LatLng(loc.latitude, loc.longitude),
            infoWindow: InfoWindow(
              title: cafe.title,
              snippet: "Click pentru Traseu",
              onTap: () async {
                final lat = loc.latitude;
                final lng = loc.longitude;

                Uri url;

                if (Platform.isIOS) {
                  // Apple Maps - nativ
                  url = Uri.parse("http://maps.apple.com/?daddr=$lat,$lng&dirflg=d");
                } else {
                  // Android - Google Maps
                  url = Uri.parse(
                    "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng",
                  );
                }

                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ),
        )
        .toSet();

    // ✅ spațiu real pentru footer floating (ca să nu intre scroll-ul sub el)
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final footerSpace = 90 + bottomInset + 12;

    return Scaffold(
      backgroundColor: kBg,
      extendBodyBehindAppBar: true,
      extendBody: true,

      // ✅ NU AppBar. Header “floating” în Stack.
      body: Stack(
        children: [
          // ====== CONTENT ======
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                top: topPadding,
                left: 18,
                right: 18,
                bottom: footerSpace,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ====== IMAGINE CAFENEA ======
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: cafe.imagePath.startsWith('http')
                        ? CachedNetworkImage(imageUrl: 
                            cafe.imagePath,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 250,
                            placeholder: (_, __) => Container(color: const Color(0xFFE8F1F4)),
                            errorWidget: (context, error, stackTrace) {
                              return const SizedBox(
                                height: 250,
                                child: Center(
                                  child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            cafe.imagePath,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 250,
                          ),
                  ),

                  const SizedBox(height: 14),

                  // ✅ CARD ALB: locații + descriere + telefon + program
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kBrand.withOpacity(0.08)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (cafe.locatii.isNotEmpty) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.location_on_outlined,
                                  color: kBrand.withOpacity(0.95), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  cafe.locatii,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black.withOpacity(0.78),
                                    fontWeight: FontWeight.w600,
                                    height: 1.25,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(height: 1, color: Colors.black.withOpacity(0.08)),
                          const SizedBox(height: 12),
                        ],
                        Text(
                          cafe.description,
                          style: TextStyle(
                            fontSize: 15.5,
                            color: Colors.black.withOpacity(0.78),
                            height: 1.55,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Divider(height: 1, color: Colors.black.withOpacity(0.08)),
                        const SizedBox(height: 10),
                        _buildInfoRow(Icons.phone, "Telefon:", cafe.phone),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.access_time, "Program:", cafe.schedule),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ====== HARTA ======
                  Text(
                    "📍 Vezi locațiile pe hartă:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: kBrand,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 12),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: kBrand.withOpacity(0.18)),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      height: 280,
                      child: Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: initialPosition,
                              zoom: 13,
                            ),
                            markers: markers,
                            myLocationButtonEnabled: true,
                            myLocationEnabled: true,
                            zoomControlsEnabled: false,
                            mapType: MapType.normal,
                            onMapCreated: (controller) async {
                              _mapController = controller;
                              await Future.delayed(const Duration(milliseconds: 100));
                              _fitAllMarkers(markers);
                            },
                          ),
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => setState(() => _isMapExpanded = true),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 10,
                            bottom: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: kBrand.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.14),
                                    blurRadius: 12,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.open_in_full, size: 16, color: Colors.white),
                                  SizedBox(width: 7),
                                  Text(
                                    "Deschide harta",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.5,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Center(
                    child: Text(
                      "— Tour Oradea © 2025 —",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ====== HEADER FLOATING CU “BULINE” (stil inițial) ======
          Positioned(
            top: safeTop,
            left: 0,
            right: 0,
            height: headerHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  _pillIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: Center(
                      child: _titlePill(cafe.title),
                    ),
                  ),

                  const SizedBox(width: 10),

                  _pillIconButton(
                    icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                    iconColor: Colors.red,
                    onTap: () async {
                      final item = FavoriteItem(
                        id: widget.cafe.id,
                        type: "cafenea",
                        data: {
                          "id": widget.cafe.id,
                          "title": widget.cafe.title,
                          "description": widget.cafe.description,
                          "imagePath": widget.cafe.imagePath,
                          "phone": widget.cafe.phone,
                          "schedule": widget.cafe.schedule,
                          "locatii": widget.cafe.locatii,
                          "locations": (widget.cafe.locations ?? [])
                              .map((loc) => {"lat": loc.latitude, "lng": loc.longitude})
                              .toList(),
                        },
                      );

                      await FavoriteService.toggleFavorite(item);
                      await _loadFavorite();
                    },
                  ),
                ],
              ),
            ),
          ),

          // ✅ Footer floating
          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomFooter(isHome: true),
          ),

          // ===== POPUP FAVORITE (sus dreapta, lângă inimă) =====
          if (_showFavoriteHint)
            Positioned(
              top: safeTop + headerHeight + 6,
              right: 12,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                tween: Tween(begin: 0, end: 1),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset((1 - value) * 16, 0),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: _favoriteHintBox(),
              ),
            ),

          // ====== HARTA MARE (fullscreen compact) ======
          if (_isMapExpanded)
            AnimatedOpacity(
              opacity: 1,
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: () => setState(() => _isMapExpanded = false),
                child: Container(
                  color: Colors.black54,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: 0.55,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: initialPosition,
                                  zoom: 13,
                                ),
                                markers: markers,
                                myLocationEnabled: true,
                                myLocationButtonEnabled: true,
                                zoomControlsEnabled: true,
                                mapType: MapType.normal,
                                onMapCreated: (controller) async {
                                  _mapController = controller;
                                  await Future.delayed(const Duration(milliseconds: 120));
                                  _fitAllMarkers(markers);
                                },
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: ClipOval(
                                  child: Material(
                                    color: Colors.black.withOpacity(0.55),
                                    child: InkWell(
                                      onTap: () => setState(() => _isMapExpanded = false),
                                      child: const SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: Icon(Icons.close, color: Colors.white, size: 22),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ====== UI: buton “bulină” (stil inițial) ======
  Widget _pillIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = kBrand,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.white.withOpacity(0.55),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withOpacity(0.60), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
          ),
        ),
      ),
    );
  }

  // ====== UI: “bulina” titlu (stil inițial) ======
  Widget _titlePill(String title) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.70),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.55), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              color: kBrand,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  // ===== Popup mic, elegant, cu săgeată spre inimă =====
  Widget _favoriteHintBox() {
    return Material(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 230,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Știai că…",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: kBrand,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Poți salva această cafenea la Favorite atingând simbolul inimă.",
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    color: Colors.black87,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: kBrand),
                      onPressed: _dismissHint,
                      child: const Text("OK"),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: _dismissHint,
                      child: const Icon(Icons.close, size: 18, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: -8,
            right: 22,
            child: Transform.rotate(
              angle: 3.14 / 4,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: kBrand.withOpacity(0.95), size: 20),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15.2,
            fontWeight: FontWeight.w900,
            color: kBrand,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15.2,
              color: Colors.black.withOpacity(0.78),
              fontFamily: 'Poppins',
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ====== Utils ======
  void _fitAllMarkers(Set<Marker> markers) async {
    if (_mapController == null || markers.isEmpty) return;
    final bounds = _boundsFromPositions(markers.map((m) => m.position).toList());
    await _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
  }

  LatLngBounds _boundsFromPositions(List<LatLng> positions) {
    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;

    for (final p in positions) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    if (positions.length == 1) {
      const double delta = 0.001;
      return LatLngBounds(
        southwest: LatLng(minLat - delta, minLng - delta),
        northeast: LatLng(maxLat + delta, maxLng + delta),
      );
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}
