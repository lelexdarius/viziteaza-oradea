import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';

import 'fast_food_detalii_page.dart';
import 'widgets/custom_footer.dart';

// =============================================================
// MODEL FAST-FOOD
// =============================================================
class FastFood {
  final String id;
  final String title;
  final String description;
  final String address;
  final String phone;
  final String schedule;
  final String imagePath;
  final int order;
  final List<GeoPoint>? locations;
  final String locatii;

  FastFood({
    required this.id,
    required this.title,
    required this.description,
    required this.address,
    required this.phone,
    required this.schedule,
    required this.imagePath,
    required this.order,
    this.locations,
    required this.locatii,
  });

  factory FastFood.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    List<GeoPoint> parseLocations(dynamic value) {
      if (value == null) return [];
      if (value is GeoPoint) return [value];
      if (value is List) return value.whereType<GeoPoint>().toList();
      return [];
    }

    return FastFood(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      schedule: data['schedule'] ?? '',
      imagePath: data['imagePath'] ?? '',
      order: data['order'] ?? 0,
      locatii: data['locatii']?.toString() ?? '',
      locations: parseLocations(data['locations']),
    );
  }
}

// =============================================================
// PAGE
// =============================================================
class FastFoodPage extends StatelessWidget {
  const FastFoodPage({Key? key}) : super(key: key);

  static const Color kBrand = Color(0xFF004E64);
  static const Color kBg = Color(0xFFE8F1F4);

  // -------------------------------------------------------------
  // Status logic (păstrat + Non Stop)
  // -------------------------------------------------------------
  static String getStatus(String schedule) {
    if (schedule.isEmpty) return 'variabil';

    final lower = schedule.toLowerCase();

    if (lower.contains('non stop') || lower.contains('non-stop')) {
      return 'deschis';
    }

    final now = DateTime.now();
    final weekday = DateFormat('EEEE', 'ro_RO').format(now).toLowerCase();

    if (lower.contains('difer') ||
        lower.contains('variaz') ||
        lower.contains('funcție') ||
        lower.contains('contact')) {
      return 'variabil';
    }

    final lines = lower.split('\n');
    String? todayLine;

    for (var line in lines) {
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
  // ✅ Floating Pills Header (Apple 2025)
  // -------------------------------------------------------------
  Widget _pillIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
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
              child: Icon(icon, color: iconColor ?? kBrand, size: 20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _titlePillRich({required String left, required String right}) {
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
          child: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
                color: kBrand,
              ),
              children: [
                TextSpan(text: left),
                TextSpan(text: right),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _floatingPillsHeader(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final formattedDate = DateFormat("d MMMM", "ro_RO").format(DateTime.now());

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
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Center(
                      child: _titlePillRich(
                        left: "Fast-Food • ",
                        right: formattedDate,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // ✅ simetrie
                  const SizedBox(width: 42, height: 42),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Empty state
  // -------------------------------------------------------------
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
                child: const Icon(Icons.fastfood_rounded, color: kBrand),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Nu există fast-food-uri disponibile momentan.",
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

  // -------------------------------------------------------------
  // Contact block (modern)
  // -------------------------------------------------------------
  Widget _contactCard() {
    return Container(
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
      child: const Column(
        children: [
          Text(
            "Dacă dorești ca fast-food-ul tău să apară în această listă, contactează-ne la:",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "touroradea@gmail.com",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: kBrand,
              fontWeight: FontWeight.w900,
              fontSize: 12.5,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Build
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // ✅ padding corect: safeTop + toolbar + un mic gap
    final double topPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight + 10;

    // ✅ spațiu pentru footer (să nu acopere ultimul card)
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    final double footerSpace = 90 + bottomInset + 12;

    return Scaffold(
      backgroundColor: kBg,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: _floatingPillsHeader(context),

      body: Stack(
        children: [
          Positioned.fill(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('fast_food')
                  .orderBy('order', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _emptyState(topPadding);
                }

                final fastfoods = snapshot.data!.docs
                    .map((d) => FastFood.fromFirestore(d))
                    .toList();

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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: fastfoods.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.86,
                          ),
                          itemBuilder: (context, index) {
                            return _fastFoodGlassCard(context, fastfoods[index]);
                          },
                        ),
                        const SizedBox(height: 16),
                        _contactCard(),
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

          // ✅ FOOTER floating
          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomFooter(isHome: false),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Card fast-food (păstrat exact)
  // -------------------------------------------------------------
  static Widget _fastFoodGlassCard(BuildContext context, FastFood fastfood) {
    final status = getStatus(fastfood.schedule);

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
          pageBuilder: (_, __, ___) => FastFoodDetaliiPage(fastfood: fastfood),
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

    Widget fallbackImage() => Image.asset(
          'assets/images/imagine_gri.jpg.webp',
          fit: BoxFit.cover,
        );

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
                child: fastfood.imagePath.startsWith('http')
                    ? Image.network(
                        fastfood.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => fallbackImage(),
                      )
                    : (fastfood.imagePath.isNotEmpty
                        ? Image.asset(fastfood.imagePath, fit: BoxFit.cover)
                        : fallbackImage()),
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
                            fastfood.title,
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
                          if (fastfood.locatii.trim().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              fastfood.locatii,
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
