import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'stranduri_detalii_page.dart';
import 'widgets/custom_footer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:viziteaza_oradea/widgets/category_map_preview.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:viziteaza_oradea/utils/app_theme.dart';
import 'package:viziteaza_oradea/services/app_state.dart';

class StranduriPage extends StatelessWidget {
  const StranduriPage({super.key});

  static const Color kBrand = Color(0xFF004E64);
  static const Color kBg = Color(0xFFE8F1F4);

  // -------------------------------------------------------------
  // ✅ UI helpers (Apple 2025 - "buline")
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
                      child: _titlePill("AquaParkuri din Oradea"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // păstrăm simetria (ca în celelalte pagini)
                  const SizedBox(width: 42, height: 42),
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
    final double topPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight + 10;

    // ✅ spațiu real pentru footer floating (ca să nu intre scroll-ul sub el)
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final footerSpace = 90 + bottomInset + 12;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      extendBodyBehindAppBar: true,
      extendBody: true,

      // ✅ AppBar cu "buline" (ca la celelalte pagini)
      appBar: _floatingPillsHeader(context),

      // 🔹 Conținut + footer floating
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.isDarkGlobal
                    ? null
                    : const LinearGradient(
                        colors: [
                          Color(0xFFB2EBF2),
                          Color(0xFFE0F7FA),
                          Color(0xFFFFFFFF),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                color: AppTheme.isDarkGlobal ? Colors.black : null,
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('stranduri')
                    .orderBy('order', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        "Nu există ștranduri disponibile momentan.",
                        style: TextStyle(fontSize: 16, color: AppTheme.textSecondary(context)),
                      ),
                    );
                  }

                  final stranduri = snapshot.data!.docs;

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      top: topPadding + 10,
                      bottom: footerSpace,
                    ),
                    itemCount: stranduri.length + 2,
                    itemBuilder: (context, index) {
                      // index 0 = harta
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CategoryMapPreview(
                            collection: 'stranduri',
                            markerColor: const Color(0xFF0288D1),
                            markerIcon: Icons.pool,
                            extractPoints: (data) {
                              final lat = (data['latitude'] is num) ? (data['latitude'] as num).toDouble() : null;
                              final lng = (data['longitude'] is num) ? (data['longitude'] as num).toDouble() : null;
                              if (lat != null && lng != null) return [LatLng(lat, lng)];
                              return [];
                            },
                            getTitle: (data) => data['title']?.toString() ?? 'AquaPark',
                            onMarkerTap: (ctx, doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              Navigator.push(ctx, MaterialPageRoute(
                                builder: (_) => StrandDetaliiPage(
                                  title: data['title'] ?? '',
                                  description: data['description'] ?? '',
                                  address: data['address'] ?? '',
                                  schedule: data['schedule'] ?? '',
                                  price: data['price'] ?? '',
                                  phone: data['phone'] ?? '',
                                  latitude: (data['latitude'] is num) ? (data['latitude'] as num).toDouble() : null,
                                  longitude: (data['longitude'] is num) ? (data['longitude'] as num).toDouble() : null,
                                  images: List<String>.from(data['images'] ?? []),
                                ),
                              ));
                            },
                          ),
                        );
                      }
                      // index 1..stranduri.length = cardurile
                      if (index <= stranduri.length) {
                        final data = stranduri[index - 1].data() as Map<String, dynamic>;
                        return _buildImprovedCard(context, data);
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 20),
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
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ),

          // ✅ Footer fix "deasupra" conținutului (fără bandă albă)
          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomFooter(isHome: true),
          ),
        ],
      ),
    );
  }

  // ---------- CARD STRAND ----------
  Widget _buildImprovedCard(BuildContext context, Map<String, dynamic> data) {
    // Luăm prima imagine din listă, dacă există
    final List<String> images = List<String>.from(data["images"] ?? const []);
    final String? firstImage = images.isNotEmpty ? images.first : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // 🔹 Imagine + text principal
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: firstImage != null && firstImage.startsWith("http")
                      ? CachedNetworkImage(imageUrl: 
                          firstImage,
                          width: 120,
                          height: 90,
                          fit: BoxFit.cover,
                          errorWidget: (context, error, stackTrace) =>
                              Image.asset(
                            "assets/images/imagine_gri.jpg.webp",
                            width: 120,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          "assets/images/imagine_gri.jpg.webp",
                          width: 120,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data["title"] ?? "Ștrand",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentGlobal,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        data["description"] ?? "Detalii indisponibile momentan.",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: AppTheme.textPrimary(context),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 🔹 Info + buton detalii
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow(context,
                        Icons.location_on_outlined,
                        data["address"] ?? "-",
                      ),
                      _infoRow(context, Icons.access_time, data["schedule"] ?? "-"),
                      _infoRow(context, Icons.attach_money, data["price"] ?? "-"),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StrandDetaliiPage(
                          title: data["title"] ?? "Ștrand",
                          description:
                              data["description"] ?? "Detalii indisponibile.",
                          images: images,
                          address: data["address"] ?? "-",
                          schedule: data["schedule"] ?? "-",
                          price: data["price"] ?? "-",
                          phone: data["phone"] ?? "",
                          latitude: (data["latitude"] is num)
                              ? (data["latitude"] as num).toDouble()
                              : null,
                          longitude: (data["longitude"] is num)
                              ? (data["longitude"] as num).toDouble()
                              : null,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text("Detalii"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGlobal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------- INFO ROW (cu verde pentru prețuri) ----------
  Widget _infoRow(BuildContext context, IconData icon, String text) {
    final bool isMoney = icon == Icons.attach_money;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            icon,
            color: isMoney ? Colors.green[700] : AppTheme.accentGlobal,
            size: 18,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.5,
                color: isMoney ? Colors.green[800] : AppTheme.textPrimary(context),
                fontWeight: isMoney ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
