// walk_detalii_page.dart
import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:viziteaza_oradea/home.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Pagina NEPUBLICATĂ în meniu.
/// O folosești doar din Trasee (ex. "Plimbare la Palatul Vulturul Negru").
class WalksDetaliiPage extends StatefulWidget {
  /// Recomandat: trimite docId-ul din Firestore (cel mai sigur).
  final String? walkId;

  /// Alternativ: dacă nu ai docId, poți trimite titlul exact și facem query.
  final String? title;

  const WalksDetaliiPage({
    Key? key,
    this.walkId,
    this.title,
  }) : super(key: key);

  @override
  State<WalksDetaliiPage> createState() => _WalksDetaliiPageState();
}

class _WalksDetaliiPageState extends State<WalksDetaliiPage> {
  // -------------------------------------------------------------
  // THEME
  // -------------------------------------------------------------
  static const Color kBrand = Color(0xFF004E64);
  static const Color kBg = Color(0xFFE8F1F4);

  static const Color kAccent = Color(0xFFF2A019);
  static const Color kInk = Color(0xFF0F1F2A);

  // -------------------------------------------------------------
  // UI state
  // -------------------------------------------------------------
  int _carouselIndex = 0;
  final PageController _pageController = PageController();

  // ✅ IMPORTANT: cache pentru Future ca să nu refacă fetch la fiecare setState
  late final Future<_WalkModel> _walkFuture;

  @override
  void initState() {
    super.initState();
    _walkFuture = _loadWalk();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------
  // BACK: normal (înapoi la pagina anterioară)
  // -------------------------------------------------------------
  void _goBack() {
    if (!mounted) return;

    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
      return;
    }

    // fallback (dacă ai ajuns aici “direct”)
    nav.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => HomePage()),
      (r) => false,
    );
  }

  // -------------------------------------------------------------
  // Firestore fetch
  // -------------------------------------------------------------
  Future<_WalkModel> _loadWalk() async {
    final col = FirebaseFirestore.instance.collection('walks');

    if (widget.walkId != null && widget.walkId!.trim().isNotEmpty) {
      final doc = await col.doc(widget.walkId!.trim()).get();
      if (!doc.exists) {
        throw Exception("Nu am găsit plimbarea (id invalid).");
      }
      return _WalkModel.fromDoc(doc);
    }

    final t = (widget.title ?? "").trim();
    if (t.isEmpty) {
      throw Exception("Nu ai trimis nici walkId, nici title.");
    }

    final qs = await col.where('title', isEqualTo: t).limit(1).get();
    if (qs.docs.isEmpty) {
      throw Exception("Nu am găsit plimbarea în Firestore: „$t”.");
    }

    return _WalkModel.fromDoc(qs.docs.first);
  }

  // -------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------
  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  /// ✅ iOS -> Apple Maps, Android -> Google Maps
  Future<void> _openExternalMaps(_WalkModel w) async {
    final lat = w.lat;
    final lng = w.lng;

    if (lat != null && lng != null) {
      final encodedTitle = Uri.encodeComponent(w.title);

      final googleUrl = Uri.parse(
        "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=walking",
      );

      final appleUrl = Uri.parse(
        "http://maps.apple.com/?daddr=$lat,$lng&q=$encodedTitle&dirflg=w",
      );

      if (Platform.isIOS) {
        if (await canLaunchUrl(appleUrl)) {
          await launchUrl(appleUrl, mode: LaunchMode.externalApplication);
          return;
        }
        if (await canLaunchUrl(googleUrl)) {
          await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
          return;
        }
      } else {
        if (await canLaunchUrl(googleUrl)) {
          await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
          return;
        }
        if (await canLaunchUrl(appleUrl)) {
          await launchUrl(appleUrl, mode: LaunchMode.externalApplication);
          return;
        }
      }

      _toast("Nu pot deschide aplicația Maps.");
      return;
    }

    // fallback: mapLink dacă nu există coordonate
    final link = w.mapLink?.trim();
    if (link != null && link.isNotEmpty) {
      final uri = Uri.tryParse(link);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }

    _toast("Nu există coordonate/link pentru Maps.");
  }

  // -------------------------------------------------------------
  // AppBar glass
  // -------------------------------------------------------------
  PreferredSizeWidget _glassAppBar(String title) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: AppBar(
            backgroundColor: Colors.white.withOpacity(0.18),
            elevation: 0,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.only(left: 6, right: 12),
              child: Row(
                children: [
                  _iconPillButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: _goBack,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.70),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.55),
                            width: 1,
                          ),
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
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            color: kBrand,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const SizedBox(width: 42, height: 42),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconPillButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.white.withOpacity(0.35),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withOpacity(0.6)),
              ),
              child: Icon(icon, color: kBrand, size: 20),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // UI blocks
  // -------------------------------------------------------------
  Widget _sectionTitle(String t) {
    return Text(
      t,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: kInk.withOpacity(0.92),
      ),
    );
  }

  Widget _chip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: kBrand.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kBrand.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: kBrand),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: kBrand,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBrand.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  // -------------------------------------------------------------
  // ✅ CAROUSEL (fără reload/blank)
  // Cheia este: Future cached + gaplessPlayback + overlays IgnorePointer
  // -------------------------------------------------------------
  Widget _carousel(_WalkModel w) {
    final images = w.images;

    if (images.isEmpty) {
      return _card(
        child: SizedBox(
          height: 220,
          child: Center(
            child: Icon(
              Icons.photo_outlined,
              size: 48,
              color: kBrand.withOpacity(0.55),
            ),
          ),
        ),
      );
    }

    return _card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 240,
          child: Stack(
            children: [
              PageView.builder(
                key: const PageStorageKey("walk_images_carousel"),
                controller: _pageController,
                itemCount: images.length,
                physics: const PageScrollPhysics(),
                onPageChanged: (i) => setState(() => _carouselIndex = i),
                itemBuilder: (_, i) {
                  final url = images[i];
                  final isNetwork = url.startsWith('http://') || url.startsWith('https://');

                  final err = Container(
                    color: kBrand.withOpacity(0.08),
                    child: const Center(
                      child: Icon(Icons.broken_image_rounded, color: kBrand, size: 40),
                    ),
                  );

                  return isNetwork
                      ? CachedNetworkImage(imageUrl:
                          url,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.medium,
                          placeholder: (_, __) => Container(color: const Color(0xFFE8F1F4)),
                          errorWidget: (_, __, ___) => err,
                        )
                      : Image.asset(
                          url,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          filterQuality: FilterQuality.medium,
                        );
                },
              ),

              // gradient jos (nu blochează swipe)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  ignoring: true,
                  child: Container(
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.55),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // indicator (nu blochează swipe)
              Positioned(
                left: 14,
                right: 14,
                bottom: 10,
                child: IgnorePointer(
                  ignoring: true,
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: List.generate(images.length, (i) {
                            final active = i == _carouselIndex;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 6),
                              width: active ? 16 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: active ? kAccent : Colors.white.withOpacity(0.65),
                                borderRadius: BorderRadius.circular(99),
                              ),
                            );
                          }),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white.withOpacity(0.22)),
                        ),
                        child: Text(
                          "${_carouselIndex + 1}/${images.length}",
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
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
    );
  }

  // -------------------------------------------------------------
  // ✅ MAP (pan/zoom în ScrollView)
  // -------------------------------------------------------------
  Widget _mapCard(_WalkModel w) {
    if (w.lat == null || w.lng == null) {
      return _card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kBrand.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.map_outlined, color: kBrand, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Harta nu este disponibilă pentru această plimbare (lipsește coordonata).",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.2,
                    fontWeight: FontWeight.w700,
                    color: kInk.withOpacity(0.70),
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final target = LatLng(w.lat!, w.lng!);

    return _card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(
                children: [
                  const Icon(Icons.map_rounded, color: kBrand, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Hartă",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color: kInk.withOpacity(0.86),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _openExternalMaps(w),
                    child: const Text(
                      "Deschide în Maps",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w900,
                        color: kBrand,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 260,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: target, zoom: 15.2),
                zoomControlsEnabled: false,
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
                },
                markers: {
                  Marker(
                    markerId: const MarkerId("walk"),
                    position: target,
                    infoWindow: InfoWindow(
                      title: w.title,
                      snippet: w.address ?? "",
                      onTap: () => _openExternalMaps(w),
                    ),
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bullets(String title, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return _card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
                color: kInk.withOpacity(0.88),
              ),
            ),
            const SizedBox(height: 10),
            ...items.map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: kAccent.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        e,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: kInk.withOpacity(0.75),
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Build
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 14;

    return WillPopScope(
      // ✅ NU mai apelăm pop aici (altfel riscăm recursie)
      // Lăsăm sistemul să facă pop normal.
      onWillPop: () async => true,
      child: Scaffold(
        backgroundColor: kBg,
        extendBodyBehindAppBar: true,
        body: FutureBuilder<_WalkModel>(
          // ✅ FUTURE CACHED -> fără reload la swipe
          future: _walkFuture,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snap.hasError) {
              return Scaffold(
                backgroundColor: kBg,
                appBar: _glassAppBar("Plimbare"),
                body: Padding(
                  padding: EdgeInsets.only(top: topPadding, left: 16, right: 16),
                  child: _card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.error_outline_rounded, color: Colors.red, size: 22),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              snap.error.toString(),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: kInk.withOpacity(0.80),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            final w = snap.data!;

            return Scaffold(
              backgroundColor: kBg,
              extendBodyBehindAppBar: true,
              appBar: _glassAppBar(w.title),
              body: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: topPadding,
                  left: 16,
                  right: 16,
                  bottom: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _carousel(w),
                    const SizedBox(height: 12),

                    _card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              w.title,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: kInk.withOpacity(0.92),
                                height: 1.1,
                              ),
                            ),
                            if ((w.address ?? "").trim().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.place_rounded, size: 16, color: kInk.withOpacity(0.55)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      w.address!.trim(),
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: kInk.withOpacity(0.60),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if ((w.duration ?? "").trim().isNotEmpty)
                                  _chip(icon: Icons.schedule_rounded, label: w.duration!.trim()),
                                if (w.distanceKm != null && w.distanceKm! > 0)
                                  _chip(icon: Icons.straighten_rounded, label: "${w.distanceKm!.toStringAsFixed(1)} km"),
                                if ((w.difficulty ?? "").trim().isNotEmpty)
                                  _chip(icon: Icons.trending_up_rounded, label: w.difficulty!.trim()),
                                if ((w.bestTime ?? "").trim().isNotEmpty)
                                  _chip(icon: Icons.wb_sunny_rounded, label: w.bestTime!.trim()),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if ((w.description ?? "").trim().isNotEmpty)
                              Text(
                                w.description!.trim(),
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13.8,
                                  height: 1.45,
                                  fontWeight: FontWeight.w600,
                                  color: kInk.withOpacity(0.78),
                                ),
                              ),
                            const SizedBox(height: 10),

                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kBrand,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () => _openExternalMaps(w),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.directions_walk_rounded, color: Colors.white, size: 20),
                                    SizedBox(width: 10),
                                    Text(
                                      "Pornește plimbarea",
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
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

                    const SizedBox(height: 14),
                    _sectionTitle("Hartă"),
                    const SizedBox(height: 10),
                    _mapCard(w),

                    const SizedBox(height: 14),
                    _bullets("Puncte de interes", w.highlights),
                    const SizedBox(height: 10),
                    _bullets("Sfaturi rapide", w.tips),

                    const SizedBox(height: 18),
                    Center(
                      child: Text(
                        "— Tour Oradea © 2025 —",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// =============================================================
// MODEL (local)
// =============================================================
class _WalkModel {
  final String id;
  final String title;
  final String? description;
  final List<String> images;

  final String? address;
  final String? duration;
  final double? distanceKm;
  final String? difficulty;
  final String? bestTime;

  final List<String> tips;
  final List<String> highlights;

  final double? lat;
  final double? lng;
  final String? mapLink;

  _WalkModel({
    required this.id,
    required this.title,
    this.description,
    required this.images,
    this.address,
    this.duration,
    this.distanceKm,
    this.difficulty,
    this.bestTime,
    required this.tips,
    required this.highlights,
    this.lat,
    this.lng,
    this.mapLink,
  });

  static List<String> _listStr(dynamic v) {
    if (v == null) return [];
    if (v is List) {
      return v.map((e) => (e ?? "").toString()).where((s) => s.trim().isNotEmpty).toList();
    }
    return [];
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    final s = v.toString().trim().replaceAll(',', '.');
    return double.tryParse(s);
  }

  factory _WalkModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};

    final title = (d['title'] ?? '').toString().trim();
    if (title.isEmpty) {
      throw Exception("Documentul walks/${doc.id} nu are câmpul 'title'.");
    }

    return _WalkModel(
      id: doc.id,
      title: title,
      description: (d['description'] ?? d['descriere'])?.toString(),
      images: _listStr(d['images'] ?? d['imageUrls'] ?? d['gallery']),
      address: (d['address'] ?? d['locatie'] ?? d['location'])?.toString(),
      duration: (d['duration'] ?? d['durata'])?.toString(),
      distanceKm: _toDouble(d['distanceKm'] ?? d['distance'] ?? d['distantaKm']),
      difficulty: (d['difficulty'] ?? d['dificultate'])?.toString(),
      bestTime: (d['bestTime'] ?? d['recomandat'])?.toString(),
      tips: _listStr(d['tips'] ?? d['sfaturi']),
      highlights: _listStr(d['highlights'] ?? d['puncteInteres']),
      lat: _toDouble(d['lat'] ?? d['latitude']),
      lng: _toDouble(d['lng'] ?? d['longitude']),
      mapLink: (d['mapLink'] ?? d['mapsLink'] ?? d['link'])?.toString(),
    );
  }
}
