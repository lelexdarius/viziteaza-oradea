import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

// FAVORITE SERVICE
import 'models/favorite_item.dart';
import 'services/favorite_service.dart';

import 'muzee_page.dart';
import 'widgets/custom_footer.dart';

class MuzeuDetaliiPage extends StatefulWidget {
  final Muzeu muzeu;

  const MuzeuDetaliiPage({Key? key, required this.muzeu}) : super(key: key);

  @override
  State<MuzeuDetaliiPage> createState() => _MuzeuDetaliiPageState();
}

class _MuzeuDetaliiPageState extends State<MuzeuDetaliiPage> {
  static const Color kBrand = Color(0xFF004E64);
  static const Color kBg = Color(0xFFE8F1F4);

  GoogleMapController? _mapController;
  bool _isMapExpanded = false;

  bool isFavorite = false;

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
    _checkLocationPermission();
    _loadFavoriteState();
  }

  Future<void> _loadFavoriteState() async {
    final fav = await FavoriteService.isFavorite(widget.muzeu.title);
    if (!mounted) return;
    setState(() => isFavorite = fav);
  }

  Future<void> _toggleFavorite() async {
    final m = widget.muzeu;

    final item = FavoriteItem(
      id: m.title,
      type: "muzeu",
      data: {
        "title": m.title,
        "description": m.description,
        "imagePath": m.imagePath,
        "address": m.address,
        "phone": m.phone,
        "schedule": m.schedule,
        "type": m.type,
        "latitude": m.latitude,
        "longitude": m.longitude,
        "order": m.order,
      },
    );

    await FavoriteService.toggleFavorite(item);
    if (!mounted) return;
    setState(() => isFavorite = !isFavorite);
  }

  // -------------------------------------------------------------
  // ✅ UI helpers (Apple 2025 - “buline”)
  // -------------------------------------------------------------
  Widget _pillIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    String? semanticsLabel,
  }) {
    return Semantics(
      label: semanticsLabel,
      button: true,
      child: ClipRRect(
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
                child: Icon(icon, color: iconColor ?? kBrand, size: 20),
              ),
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
                    semanticsLabel: "Înapoi",
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Center(child: _titlePill(title))),
                  const SizedBox(width: 10),
                  _pillIconButton(
                    icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                    iconColor: Colors.red,
                    semanticsLabel: "Favorite",
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

  // -------------------------------------------------------------
  // ✅ Info “chips” (2025)
  // -------------------------------------------------------------
  Widget _infoChip({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    final chip = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
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
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.6,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withOpacity(0.78),
                  height: 1.35,
                ),
                children: [
                  TextSpan(
                    text: "$label\n",
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: kBrand,
                      fontSize: 12.8,
                      height: 1.2,
                    ),
                  ),
                  TextSpan(text: value.isNotEmpty ? value : "-"),
                ],
              ),
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded,
                color: Colors.black.withOpacity(0.35)),
          ],
        ],
      ),
    );

    if (onTap == null) return chip;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: chip,
    );
  }

  // -------------------------------------------------------------
  // ✅ Primary button (2025)
  // -------------------------------------------------------------
  Widget _primaryButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: kBrand.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: kBrand),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: kBrand,
                ),
              ),
            ),
            const Icon(Icons.open_in_new_rounded, color: kBrand, size: 18),
          ],
        ),
      ),
    );
  }

  Future<void> _openDirections(LatLng dest) async {
    final lat = dest.latitude;
    final lng = dest.longitude;

    final Uri url = Platform.isIOS
        ? Uri.parse("http://maps.apple.com/?daddr=$lat,$lng&dirflg=d")
        : Uri.parse("https://www.google.com/maps/dir/?api=1&destination=$lat,$lng");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nu s-a putut deschide harta.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final muzeu = widget.muzeu;

    final LatLng locatieMuzeu = LatLng(
      muzeu.latitude ?? 47.0563,
      muzeu.longitude ?? 21.9267,
    );

    final markers = <Marker>{
      Marker(
        markerId: MarkerId(muzeu.title),
        position: locatieMuzeu,
        infoWindow: InfoWindow(
          title: muzeu.title,
          snippet: "Click pentru traseu",
          onTap: () => _openDirections(locatieMuzeu),
        ),
      ),
    };

    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 10;

    // ✅ spațiu real pentru footer floating (ca să nu intre scroll-ul sub el)
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final footerSpace = 90 + bottomInset + 12;

    return Scaffold(
      backgroundColor: kBg,

      // ✅ fără bandă albă sub footer
      extendBody: true,
      extendBodyBehindAppBar: true,

      appBar: _floatingPillsHeader(context, muzeu.title),

      body: Stack(
        children: [
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
                  // -------------------------------------------------
                  // ✅ HERO cu gradient + label tip “glass”
                  // -------------------------------------------------
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(
                      children: [
                        SizedBox(
                          height: 250,
                          width: double.infinity,
                          child: Image.network(
                            muzeu.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/images/imagine_gri.jpg.webp',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.62),
                                  Colors.black.withOpacity(0.18),
                                  Colors.transparent,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.22),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.35),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      muzeu.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18.5,
                                        height: 1.12,
                                        shadows: [
                                          Shadow(
                                            offset: Offset(0, 1),
                                            blurRadius: 10,
                                            color: Colors.black54,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "🏛️ ${muzeu.type}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Colors.white.withOpacity(0.90),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.14),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // -------------------------------------------------
                  // ✅ Descriere în card alb
                  // -------------------------------------------------
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
                    child: Text(
                      muzeu.description.isNotEmpty
                          ? muzeu.description
                          : "Descriere indisponibilă momentan.",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13.8,
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withOpacity(0.78),
                        height: 1.55,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // -------------------------------------------------
                  // ✅ Chips info (adresă/telefon/program)
                  // -------------------------------------------------
                  _infoChip(
                    icon: Icons.location_on_outlined,
                    label: "Adresă",
                    value: muzeu.address,
                    onTap: () => _openDirections(locatieMuzeu),
                  ),
                  const SizedBox(height: 10),
                  _infoChip(
                    icon: Icons.phone_rounded,
                    label: "Telefon",
                    value: muzeu.phone,
                    onTap: muzeu.phone.isNotEmpty
                        ? () async {
                            final Uri url = Uri.parse("tel:${muzeu.phone}");
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          }
                        : null,
                  ),
                  const SizedBox(height: 10),
                  _infoChip(
                    icon: Icons.access_time_rounded,
                    label: "Program",
                    value: muzeu.schedule,
                  ),

                  const SizedBox(height: 14),

                  // -------------------------------------------------
                  // ✅ Buton “Traseu”
                  // -------------------------------------------------
                  _primaryButton(
                    icon: Icons.directions_rounded,
                    text: "Deschide traseul",
                    onTap: () => _openDirections(locatieMuzeu),
                  ),

                  const SizedBox(height: 18),

                  // -------------------------------------------------
                  // ✅ Hartă (cu label mic)
                  // -------------------------------------------------
                  Text(
                    "📍 Vezi locația pe hartă",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                      color: kBrand,
                    ),
                  ),
                  const SizedBox(height: 10),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      height: 260,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: kBrand.withOpacity(0.12)),
                      ),
                      child: Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: locatieMuzeu,
                              zoom: 14,
                            ),
                            markers: markers,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            zoomControlsEnabled: false,
                            onMapCreated: (c) => _mapController = c,
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
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.55),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.18),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.open_in_full,
                                          color: Colors.white, size: 14),
                                      SizedBox(width: 6),
                                      Text(
                                        "Mărește harta",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
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

                  const SizedBox(height: 34),

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
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),

          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomFooter(isHome: true),
          ),

          // 🔵 Harta fullscreen (peste tot)
          if (_isMapExpanded)
            AnimatedOpacity(
              opacity: 1,
              duration: const Duration(milliseconds: 200),
              child: Container(
                color: Colors.black54,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: 0.55,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: locatieMuzeu,
                                zoom: 14,
                              ),
                              markers: markers,
                              myLocationEnabled: true,
                              myLocationButtonEnabled: true,
                              zoomControlsEnabled: true,
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
        ],
      ),
    );
  }
}
