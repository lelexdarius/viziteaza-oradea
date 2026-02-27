import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

// ⭐ Favorite
import 'models/favorite_item.dart';
import 'services/favorite_service.dart';

// ✅ FOOTER
import 'widgets/custom_footer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StrandDetaliiPage extends StatefulWidget {
  final String title;
  final String description;
  final String address;
  final String schedule;
  final String price;
  final String phone;
  final double? latitude;
  final double? longitude;
  final List<String> images;

  const StrandDetaliiPage({
    super.key,
    required this.title,
    required this.description,
    required this.address,
    required this.schedule,
    required this.price,
    required this.phone,
    this.latitude,
    this.longitude,
    required this.images,
  });

  @override
  State<StrandDetaliiPage> createState() => _StrandDetaliiPageState();
}

class _StrandDetaliiPageState extends State<StrandDetaliiPage> {
  static const Color kBrand = Color(0xFF004E64);

  final PageController _pageController = PageController();
  int _currentPage = 0;

  GoogleMapController? _mapController;
  bool _isMapExpanded = false;

  bool _isFav = false;
  bool _loadingFav = true;

  @override
  void initState() {
    super.initState();
    _autoScrollImages();
    _checkLocationPermission();
    _loadFavorite();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

  // ⭐ FAVORITE ITEM
  FavoriteItem get _favoriteItem => FavoriteItem(
        id: widget.title,
        type: "strand",
        data: {
          "id": widget.title,
          "title": widget.title,
          "description": widget.description,
          "address": widget.address,
          "schedule": widget.schedule,
          "price": widget.price,
          "phone": widget.phone,
          "latitude": widget.latitude,
          "longitude": widget.longitude,
          "images": widget.images,
        },
      );

  Future<void> _loadFavorite() async {
    final fav = await FavoriteService.isFavorite(_favoriteItem.id);
    if (!mounted) return;
    setState(() {
      _isFav = fav;
      _loadingFav = false;
    });
  }

  Future<void> _toggleFavorite() async {
    await FavoriteService.toggleFavorite(_favoriteItem);
    await _loadFavorite();
  }

  void _autoScrollImages() async {
    while (mounted && widget.images.isNotEmpty) {
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) return;

      final next = (_currentPage + 1) % widget.images.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

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

    const double delta = 0.001;

    return LatLngBounds(
      southwest: LatLng(minLat - delta, minLng - delta),
      northeast: LatLng(maxLat + delta, maxLng + delta),
    );
  }

  // -------------------------------------------------------------
  // ✅ UI helpers (Apple 2025 - “buline”)
  // -------------------------------------------------------------
  Widget _pillIconButton({
    required IconData icon,
    required VoidCallback onTap,
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
                border:
                    Border.all(color: Colors.white.withOpacity(0.60), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, color: kBrand, size: 20),
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

  PreferredSizeWidget _floatingPillsHeader(BuildContext context) {
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
                    child: Center(
                      child: _titlePill(widget.title),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _loadingFav
                      ? const SizedBox(
                          width: 42,
                          height: 42,
                          child: Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : _pillIconButton(
                          icon: _isFav ? Icons.favorite : Icons.favorite_border,
                          onTap: _toggleFavorite,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;

    // ✅ spațiu real pentru footer floating (ca să nu intre scroll-ul sub el)
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final footerSpace = 90 + bottomInset + 12;

    final LatLng initialPosition =
        (widget.latitude != null && widget.longitude != null)
            ? LatLng(widget.latitude!, widget.longitude!)
            : const LatLng(47.05, 21.92);

    final Set<Marker> markers =
        (widget.latitude != null && widget.longitude != null)
            ? {
                Marker(
                  markerId: MarkerId(widget.title),
                  position: LatLng(widget.latitude!, widget.longitude!),
                ),
              }
            : {};

    return Scaffold(
      backgroundColor: const Color(0xFFE0F7FA),
      extendBodyBehindAppBar: true,
      extendBody: true,

      // ✅ “buline” sus: back + titlu + favorite
      appBar: _floatingPillsHeader(context),

      body: Stack(
        children: [
          // ✅ CONȚINUT (scroll) cu spațiu jos pentru footer
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                top: topPadding,
                bottom: footerSpace, // ✅ important
              ),
              child: Column(
                children: [
                  _buildImagesCarousel(),
                  const SizedBox(height: 16),
                  _buildInfoSection(initialPosition, markers),
                ],
              ),
            ),
          ),

          // ✅ Footer fix “deasupra” conținutului (gol în spate)
          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomFooter(isHome: true),
          ),

          // ✅ Harta fullscreen peste tot (inclusiv peste footer)
          if (_isMapExpanded) _buildExpandedMap(initialPosition, markers),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // 🔵 CARUSEL IMAGINI
  // ------------------------------------------------------------
  Widget _buildImagesCarousel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.images.isNotEmpty ? widget.images.length : 1,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final imageUrl = widget.images.isNotEmpty
                    ? widget.images[index]
                    : "https://via.placeholder.com/400x200.png";

                return CachedNetworkImage(imageUrl: 
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorWidget: (_, __, ___) =>
                      const Center(child: Icon(Icons.broken_image, size: 50)),
                );
              },
            ),

            // ⭐ Buline indicator
            if (widget.images.length > 1)
              Positioned(
                bottom: 10,
                child: Row(
                  children: List.generate(
                    widget.images.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _currentPage == index ? 10 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? const Color(0xFF004E64)
                            : Colors.white70,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // 🔵 SECTIUNEA DE INFORMATII
  // ------------------------------------------------------------
  Widget _buildInfoSection(LatLng initialPosition, Set<Marker> markers) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Titlu + descriere într-un “chenar” alb (stil Apple)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18.5,
                    fontWeight: FontWeight.w900,
                    color: kBrand,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.description.isNotEmpty
                      ? widget.description
                      : "Detalii indisponibile momentan.",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.8,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.80),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                _infoRow(Icons.location_on_outlined, widget.address),
                _infoRow(Icons.access_time, widget.schedule),
                _infoRow(Icons.attach_money, widget.price, isPrice: true),
                if (widget.phone.isNotEmpty) _infoRow(Icons.phone, widget.phone),
              ],
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            "📍 Vezi locația pe hartă:",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: kBrand,
            ),
          ),
          const SizedBox(height: 10),

          // Hartă mică
          _buildSmallMap(initialPosition, markers),

          const SizedBox(height: 46),
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
    );
  }

  // ------------------------------------------------------------
  // 🔵 HARTA MICĂ
  // ------------------------------------------------------------
  Widget _buildSmallMap(LatLng initialPosition, Set<Marker> markers) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(color: kBrand.withOpacity(0.20)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: initialPosition, zoom: 13),
              markers: markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              mapType: MapType.normal,
              onMapCreated: (controller) async {
                _mapController = controller;
                if (markers.isNotEmpty) {
                  await Future.delayed(const Duration(milliseconds: 150));
                  _fitAllMarkers(markers);
                }
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
              right: 8,
              bottom: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.open_in_full, size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      "Deschide harta",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // 🔵 HARTA MARE
  // ------------------------------------------------------------
  Widget _buildExpandedMap(LatLng initialPosition, Set<Marker> markers) {
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 180),
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
                        initialCameraPosition:
                            CameraPosition(target: initialPosition, zoom: 13),
                        markers: markers,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: true,
                        mapType: MapType.normal,
                        onMapCreated: (controller) async {
                          _mapController = controller;
                          if (markers.isNotEmpty) {
                            await Future.delayed(
                                const Duration(milliseconds: 150));
                            _fitAllMarkers(markers);
                          }
                        },
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: ClipOval(
                          child: Material(
                            color: Colors.black.withOpacity(0.55),
                            child: InkWell(
                              onTap: () =>
                                  setState(() => _isMapExpanded = false),
                              child: const SizedBox(
                                width: 40,
                                height: 40,
                                child: Icon(Icons.close,
                                    color: Colors.white, size: 22),
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
    );
  }

  // ------------------------------------------------------------
  // 🔵 INFO ROW
  // ------------------------------------------------------------
  Widget _infoRow(IconData icon, String text, {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kBrand, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.6,
                color: isPrice ? const Color(0xFF2E7D32) : Colors.black87,
                fontWeight: isPrice ? FontWeight.w800 : FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
