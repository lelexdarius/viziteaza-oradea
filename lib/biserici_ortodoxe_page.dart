import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'widgets/custom_footer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:viziteaza_oradea/services/app_state.dart';
import 'package:viziteaza_oradea/utils/app_theme.dart';

class BisericiOrtodoxePage extends StatelessWidget {
  const BisericiOrtodoxePage({Key? key}) : super(key: key);

  static const Color kBrand = Color(0xFF004E64);
  static const Color kBg = Color(0xFFE8F1F4);

  // -------------------------------------------------------------
  // ✅ UI helpers (Apple 2025 - "buline" sus)
  // -------------------------------------------------------------
  Widget _pillIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = AppState.instance.isDarkMode;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: isDark ? Colors.black : Colors.white.withOpacity(0.55),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isDark ? Colors.white : Colors.white.withOpacity(0.60),
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
              child: Icon(icon, color: isDark ? Colors.white : kBrand, size: 20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _titlePill(String text) {
    final isDark = AppState.instance.isDarkMode;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.black : Colors.white.withOpacity(0.70),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: isDark ? Colors.white : Colors.white.withOpacity(0.55), width: 1),
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
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : kBrand,
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
                  Expanded(child: Center(child: _titlePill(title))),
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

  // ✅ Helper: ia text safe din map (acceptă și chei alternative)
  String _pickString(
    Map<String, dynamic> data,
    List<String> keys, {
    String fallback = "",
  }) {
    for (final k in keys) {
      final v = data[k];
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight + 10;

    final bottomInset = MediaQuery.of(context).padding.bottom;
    final footerSpace = 90 + bottomInset + 12;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: _floatingPillsHeader(context, "Biserici Ortodoxe"),
      body: Stack(
        children: [
          Positioned.fill(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('biserici_ortodoxe')
                  .orderBy('order')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "Nu există biserici disponibile momentan.",
                      style: TextStyle(fontSize: 16, color: AppTheme.textSecondary(context)),
                    ),
                  );
                }

                // ✅ FIX: normalizare titlu + fallback
                final churches = snapshot.data!.docs.map((doc) {
                  final data = (doc.data() as Map<String, dynamic>?) ?? {};

                  final title = _pickString(
                    data,
                    const ["title", "titlu", "name", "nume"],
                    fallback: "Biserică",
                  );

                  final address = _pickString(
                    data,
                    const ["address", "adresa", "locatie", "location"],
                    fallback: "-",
                  );

                  final schedule = _pickString(
                    data,
                    const ["schedule", "program"],
                    fallback: "-",
                  );

                  final imagePath = _pickString(
                    data,
                    const ["imagePath", "image", "img", "banner"],
                    fallback: "",
                  );

                  return {
                    "title": title,
                    "address": address,
                    "schedule": schedule,
                    "imagePath": imagePath,
                  };
                }).toList();

                return SingleChildScrollView(
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
                      const SizedBox(height: 16),
                      ...churches.map(
                        (c) => _ChurchCard(
                          title: (c['title'] ?? "Biserică").toString(),
                          address: (c['address'] ?? "-").toString(),
                          schedule: (c['schedule'] ?? "-").toString(),
                          imagePath: (c['imagePath'] ?? "").toString(),
                        ),
                      ),
                      const SizedBox(height: 34),
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 6),
                        child: Center(
                          child: Text(
                            "— Tour Oradea © 2025 —",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: AppTheme.textSecondary(context),
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                );
              },
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomFooter(isHome: true),
          ),
        ],
      ),
    );
  }
}

// ---------- CARD (stil 2025) ----------
class _ChurchCard extends StatelessWidget {
  static const Color kBrand = Color(0xFF004E64);

  final String title;
  final String address;
  final String schedule;
  final String imagePath;

  const _ChurchCard({
    required this.title,
    required this.address,
    required this.schedule,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Guard extra: dacă cumva vine gol, afișăm fallback
    final safeTitle = title.trim().isEmpty ? "Biserică" : title.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBrand.withOpacity(0.10), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: imagePath.trim().isNotEmpty
                  ? CachedNetworkImage(imageUrl:
                      imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorWidget: (_, __, ___) => Image.asset(
                        'assets/images/imagine_gri.jpg.webp',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : Image.asset(
                      'assets/images/imagine_gri.jpg.webp',
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    safeTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary(context),
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_outlined,
                          color: AppTheme.accentGlobal, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          address,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary(context),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.isDarkGlobal
                          ? const Color(0xFF1B3A2A)
                          : const Color(0xFFEAF5F2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF2E7D32).withOpacity(0.18),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.access_time,
                            size: 18,
                            color: AppTheme.isDarkGlobal
                                ? Colors.green[300]
                                : Colors.green[800]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Program: $schedule",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.2,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.isDarkGlobal
                                  ? Colors.green[300]
                                  : Colors.green[800],
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
