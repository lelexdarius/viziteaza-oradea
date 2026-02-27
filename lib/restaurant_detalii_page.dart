import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:viziteaza_oradea/models/restaurant_model.dart';
import 'widgets/custom_footer.dart';
import 'models/favorite_item.dart';
import 'services/favorite_service.dart';

class RestaurantDetaliiPage extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetaliiPage({Key? key, required this.restaurant})
      : super(key: key);

  @override
  State<RestaurantDetaliiPage> createState() => _RestaurantDetaliiPageState();
}

class _RestaurantDetaliiPageState extends State<RestaurantDetaliiPage> {
  static const Color kBrand = Color(0xFF004E64);
  static const Color kBg = Color(0xFFE8F1F4);

  GoogleMapController? _mapController;
  bool _isMapExpanded = false;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _loadFavorite();
  }

  void _loadFavorite() async {
    isFavorite = await FavoriteService.isFavorite(widget.restaurant.id);
    if (mounted) setState(() {});
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
    }
  }

  // -------------------------------------------------------------
  // ✅ PILL BUTTONS + TITLE PILL (ca la Cafenele/FastFood)
  // -------------------------------------------------------------
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
                border: Border.all(
                  color: Colors.white.withOpacity(0.60),
                  width: 1,
                ),
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

  Widget _titlePill(String text) {
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
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              color: kBrand,
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _floatingPillsHeader(BuildContext context, String title) {
    final safeTop = MediaQuery.of(context).padding.top;

    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: SizedBox(
        height: kToolbarHeight + safeTop,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            Positioned(
              top: safeTop,
              left: 10,
              right: 10,
              height: kToolbarHeight,
              child: Row(
                children: [
                  _pillIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Center(child: _titlePill(title)),
                  ),
                  const SizedBox(width: 10),
                  _pillIconButton(
                    icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                    iconColor: Colors.red,
                    onTap: () async {
                      final r = widget.restaurant;

                      final item = FavoriteItem(
                        id: r.id,
                        type: "restaurant",
                        data: {
                          "id": r.id,
                          "title": r.title,
                          "description": r.description,
                          "address": r.address,
                          "phone": r.phone,
                          "schedule": r.schedule,
                          "imagePath": r.imagePath,
                          "order": r.order,
                          "locations": r.locations
                              ?.map((loc) => {
                                    "lat": loc.latitude,
                                    "lng": loc.longitude,
                                  })
                              .toList(),
                          "linkMenu": r.linkMenu,
                        },
                      );

                      await FavoriteService.toggleFavorite(item);
                      _loadFavorite();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // ✅ CARD UI HELPERS (alb premium)
  // -------------------------------------------------------------
  Widget _whiteCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(14),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBrand.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _infoRowCard(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: kBrand.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: kBrand, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: kBrand,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.80),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // MAP UTILS
  // -------------------------------------------------------------
  void _fitAllMarkers(Set<Marker> markers) async {
    if (_mapController == null || markers.isEmpty) return;
    final bounds =
        _boundsFromPositions(markers.map((m) => m.position).toList());
    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 70),
    );
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
      const double d = 0.001;
      return LatLngBounds(
        southwest: LatLng(minLat - d, minLng - d),
        northeast: LatLng(maxLat + d, maxLng + d),
      );
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.restaurant;

    // ✅ spațiu real pentru footer floating (ca să nu intre scroll-ul sub el)
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final footerSpace = 90 + bottomInset + 12;

    // === Date pentru hartă ===
    final List<GeoPoint> locs = (r.locations ?? []);
    final initialPosition = locs.isNotEmpty
        ? LatLng(locs.first.latitude, locs.first.longitude)
        : const LatLng(47.05, 21.92); // fallback Oradea

    final markers = locs
        .map(
          (g) => Marker(
            markerId: MarkerId('${g.latitude}_${g.longitude}_${r.title}'),
            position: LatLng(g.latitude, g.longitude),
            infoWindow: InfoWindow(
              title: r.title,
              snippet: "Click pentru traseu",
              onTap: () async {
                final lat = g.latitude;
                final lng = g.longitude;

                Uri url;

                if (Platform.isIOS) {
                  url = Uri.parse(
                      "http://maps.apple.com/?daddr=$lat,$lng&dirflg=d");
                } else {
                  url = Uri.parse(
                      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng");
                }

                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Nu s-a putut deschide harta.")),
                  );
                }
              },
            ),
          ),
        )
        .toSet();

    final topPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight + 10;

    return Scaffold(
      backgroundColor: kBg,
      extendBodyBehindAppBar: true,
      extendBody: true,

      // ✅ header cu “buline” + titlu pill (fără background bar)
      appBar: _floatingPillsHeader(context, r.title),

      body: Stack(
        children: [
          // ✅ CONȚINUT (scroll) cu spațiu jos pentru footer
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                top: topPadding,
                left: 16,
                right: 16,
                bottom: footerSpace,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === Imagine banner ===
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      r.imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 230,
                      errorBuilder: (context, error, stack) {
                        return Image.asset(
                          'assets/images/imagine_gri.jpg.webp',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 230,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ✅ Card: titlu + descriere (în chenar alb)
                  _whiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.title,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18.8,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          r.description,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.8,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.78),
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ====== BUTON MENIU ONLINE (păstrat funcțional, stilizat)
                  GestureDetector(
                    onTap: () async {
                      if (r.linkMenu != null && r.linkMenu!.isNotEmpty) {
                        final Uri url = Uri.parse(r.linkMenu!);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url,
                              mode: LaunchMode.externalApplication);
                        } else {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Nu s-a putut deschide meniul."),
                            ),
                          );
                        }
                      } else {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Meniul nu este disponibil momentan."),
                          ),
                        );
                      }
                    },
                    child: _whiteCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: const Row(
                        children: [
                          Icon(Icons.restaurant_menu, color: kBrand),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Vezi meniul online",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w800,
                                color: kBrand,
                                fontSize: 15.5,
                              ),
                            ),
                          ),
                          Icon(Icons.open_in_new, color: kBrand),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ✅ Card info: adresă/telefon/program
                  _whiteCard(
                    child: Column(
                      children: [
                        _infoRowCard(
                            Icons.location_on_outlined, "Adresă", r.address),
                        _infoRowCard(Icons.phone, "Telefon", r.phone),
                        _infoRowCard(Icons.access_time, "Program", r.schedule),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ✅ Titlu hartă (păstrat)
                  const Text(
                    "📍 Vezi locațiile pe hartă:",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.6,
                      fontWeight: FontWeight.w900,
                      color: kBrand,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Hartă mică (păstrată funcțional)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: kBrand.withOpacity(0.12)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 18,
                            offset: const Offset(0, 12),
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
                              await Future.delayed(
                                  const Duration(milliseconds: 100));
                              _fitAllMarkers(markers);
                            },
                          ),
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () =>
                                    setState(() => _isMapExpanded = true),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 10,
                            bottom: 10,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.35),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.18),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.open_in_full,
                                          size: 16, color: Colors.white),
                                      SizedBox(width: 6),
                                      Text(
                                        "Deschide harta",
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.white,
                                          fontSize: 12.2,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

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
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // ✅ Footer fix “deasupra” conținutului
          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomFooter(isHome: true),
          ),

          // Hartă mare (expandată) - păstrată funcțional
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
                      heightFactor: 0.5,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
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
                                myLocationButtonEnabled: true,
                                myLocationEnabled: true,
                                zoomControlsEnabled: true,
                                mapType: MapType.normal,
                                onMapCreated: (controller) async {
                                  _mapController = controller;
                                  await Future.delayed(
                                      const Duration(milliseconds: 120));
                                  _fitAllMarkers(markers);
                                },
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: ClipOval(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 10, sigmaY: 10),
                                    child: Material(
                                      color: Colors.black.withOpacity(0.45),
                                      child: InkWell(
                                        onTap: () => setState(
                                            () => _isMapExpanded = false),
                                        child: const SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                        ),
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
}
