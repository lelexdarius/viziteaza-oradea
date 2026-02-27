import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';

import 'cafenea_detalii_page.dart';
import 'widgets/custom_footer.dart';

// =============================================================
// MODEL
// =============================================================
class Cafenea {
  final String id;
  final String title;
  final String description;
  final String imagePath;
  final String phone;
  final String schedule;
  final String locatii;
  final List<GeoPoint>? locations;

  // ✅ NOU: Recomandat
  final bool recomandat;

  Cafenea({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.phone,
    required this.schedule,
    this.locations,
    required this.locatii,
    required this.recomandat,
  });

  factory Cafenea.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>? ?? {});

    List<GeoPoint> parseLocations(dynamic value) {
      if (value == null) return [];
      if (value is GeoPoint) return [value];
      if (value is List) return value.whereType<GeoPoint>().toList();
      return [];
    }

    bool parseBool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) {
        final s = v.trim().toLowerCase();
        return s == 'true' || s == '1' || s == 'da' || s == 'yes';
      }
      return false;
    }

    // ✅ Dacă nu există field-ul "Recomandat", devine false automat.
    final bool recomandat = parseBool(data['Recomandat']);

    return Cafenea(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imagePath: data['imagePath'] ?? '',
      phone: data['phone'] ?? '',
      schedule: data['schedule'] ?? '',
      locations: parseLocations(data['locations']),
      locatii: data['locatii']?.toString() ?? '',
      recomandat: recomandat,
    );
  }
}

// =============================================================
// PAGE
// =============================================================
class CafenelePage extends StatefulWidget {
  const CafenelePage({Key? key}) : super(key: key);

  static const Color kBrand = Color(0xFF004E64);
  static const Color kBg = Color(0xFFE8F1F4);

  @override
  State<CafenelePage> createState() => _CafenelePageState();

  // -------------------------------------------------------------
  // Status logic (cu ziua curentă)
  // -------------------------------------------------------------
  static String getStatus(String schedule) {
    if (schedule.isEmpty) return 'variabil';

    final now = DateTime.now();
    final weekday = DateFormat('EEEE', 'ro_RO').format(now).toLowerCase();
    final lower = schedule.toLowerCase();

    if (lower.contains('difer') ||
        lower.contains('variaz') ||
        lower.contains('funcție') ||
        lower.contains('contact')) {
      return 'variabil';
    }

    final lines = lower.split('\n');
    String? todayLine;
    for (final line in lines) {
      if (line.contains(weekday)) {
        todayLine = line;
        break;
      }
    }

    final textToParse = todayLine ?? lower;

    final match = RegExp(r'(\d{1,2}[:.]\d{2})\s*-\s*(\d{1,2}[:.]\d{2})')
        .firstMatch(textToParse);
    if (match == null) return 'variabil';

    try {
      final open = _parseTime(match.group(1)!);
      final close = _parseTime(match.group(2)!);
      final nowMinutes = now.hour * 60 + now.minute;

      if (close < open) {
        if (nowMinutes >= open || nowMinutes <= close) return 'deschis';
      }

      return (nowMinutes >= open && nowMinutes <= close) ? 'deschis' : 'închis';
    } catch (_) {
      return 'variabil';
    }
  }

  static int _parseTime(String time) {
    final parts = time.replaceAll('.', ':').split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return h * 60 + m;
  }

  // -------------------------------------------------------------
  // ✅ HEADER FLOATING CU “BULINE”
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
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _floatingPillsHeader(BuildContext context) {
    final formattedDate = DateFormat("d MMMM", "ro_RO").format(DateTime.now());
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
                      child: _titlePill("Cafenele • $formattedDate"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const SizedBox(width: 42, height: 42),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(double topPadding) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.88),
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
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: kBrand.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.info_outline_rounded, color: kBrand),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Nu există cafenele disponibile momentan.",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.2,
                    fontWeight: FontWeight.w700,
                    color: Colors.black.withOpacity(0.72),
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CafenelePageState extends State<CafenelePage> {
  // ✅ NOU: toggle între Toate / Recomandate
  bool _showRecommended = false;

  Widget _filterToggle() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.60),
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
          child: Row(
            children: [
              Expanded(
                child: _segButton(
                  label: "Toate",
                  selected: !_showRecommended,
                  onTap: () => setState(() => _showRecommended = false),
                  icon: Icons.grid_view_rounded,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _segButton(
                  label: "Recomandate",
                  selected: _showRecommended,
                  onTap: () => setState(() => _showRecommended = true),
                  icon: Icons.star_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _segButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    final bg = selected
        ? CafenelePage.kBrand.withOpacity(0.12)
        : Colors.transparent;

    final textColor = selected
        ? CafenelePage.kBrand
        : CafenelePage.kBrand.withOpacity(0.70);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? CafenelePage.kBrand.withOpacity(0.18)
                  : Colors.white.withOpacity(0.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: textColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.8,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Build
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // ✅ spațiu sub header
    final double topPadding = kToolbarHeight + 80;

    // ✅ spațiu sub footer
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    final double footerSpace = 18 + 90 + (bottomInset > 0 ? bottomInset : 0);

    return Scaffold(
      backgroundColor: CafenelePage.kBg,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: widget._floatingPillsHeader(context),
      body: Stack(
        children: [
          Positioned.fill(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('cafenele')
                  .orderBy('order', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return widget._emptyState(topPadding);
                }

                final allCafenele = snapshot.data!.docs
                    .map((d) => Cafenea.fromFirestore(d))
                    .toList();

                // ✅ Filtru: Toate / Recomandate
                final visible = _showRecommended
                    ? allCafenele.where((c) => c.recomandat == true).toList()
                    : allCafenele;

                if (visible.isEmpty) {
                  // dacă nu sunt recomandate marcate
                  return MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        top: topPadding,
                        left: 16,
                        right: 16,
                        bottom: footerSpace,
                      ),
                      child: Column(
                        children: [
                          _filterToggle(),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.88),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: CafenelePage.kBrand.withOpacity(0.10),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 14,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: CafenelePage.kBrand.withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.star_outline_rounded,
                                    color: CafenelePage.kBrand,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Momentan nu există cafenele marcate ca recomandate.",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14.2,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black.withOpacity(0.72),
                                      height: 1.25,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          Center(
                            child: Text(
                              "— Tour Oradea © 2025 —",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
                  );
                }

                return MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      top: topPadding,
                      left: 16,
                      right: 16,
                      bottom: footerSpace,
                    ),
                    child: Column(
                      children: [
                        // ✅ NOU: butoanele sus
                        _filterToggle(),
                        const SizedBox(height: 14),

                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: visible.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.86,
                          ),
                          itemBuilder: (context, index) {
                            return _cafeGlassCard(context, visible[index]);
                          },
                        ),
                        const SizedBox(height: 22),
                        Center(
                          child: Text(
                            "— Tour Oradea © 2025 —",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomFooter(isHome: false),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Card (Apple 2025) — RESTUL NEMODIFICAT
  // -------------------------------------------------------------
  static Widget _cafeGlassCard(BuildContext context, Cafenea cafe) {
    final status = CafenelePage.getStatus(cafe.schedule);

    Color statusColor;
    Color statusBg;
    IconData statusIcon;

    switch (status) {
      case 'deschis':
        statusColor = const Color(0xFF137A3A);
        statusBg = const Color(0xFFDCF6E6);
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'închis':
        statusColor = const Color(0xFFB42318);
        statusBg = const Color(0xFFFDE2E0);
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = Colors.black.withOpacity(0.55);
        statusBg = Colors.white.withOpacity(0.72);
        statusIcon = Icons.timelapse_rounded;
    }

    void openDetails() {
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 220),
          reverseTransitionDuration: const Duration(milliseconds: 220),
          pageBuilder: (_, __, ___) => CafeneaDetaliiPage(cafe: cafe),
          transitionsBuilder: (_, anim, __, child) {
            final curved = CurvedAnimation(
              parent: anim,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
                child: child,
              ),
            );
          },
        ),
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: openDetails,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              Positioned.fill(
                child: cafe.imagePath.startsWith('http')
                    ? Image.network(cafe.imagePath, fit: BoxFit.cover)
                    : Image.asset(cafe.imagePath, fit: BoxFit.cover),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.65),
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
                top: 10,
                left: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.55),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: statusColor.withOpacity(0.25),
                              ),
                            ),
                            child: Icon(statusIcon, size: 14, color: statusColor),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11.2,
                              fontWeight: FontWeight.w900,
                              color: statusColor,
                              height: 1.0,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
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
                        children: [
                          Text(
                            cafe.title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14.8,
                              height: 1.12,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 8,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (cafe.locatii.trim().isNotEmpty)
                            Text(
                              cafe.locatii,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.white.withOpacity(0.86),
                                fontWeight: FontWeight.w700,
                                fontSize: 11.8,
                                height: 1.05,
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
      ),
    );
  }
}
