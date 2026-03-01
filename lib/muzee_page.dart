import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'muzeu_detalii_page.dart';
import 'widgets/custom_footer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:viziteaza_oradea/widgets/category_map_preview.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:viziteaza_oradea/utils/app_theme.dart';
import 'package:viziteaza_oradea/services/app_state.dart';

class Muzeu {
  final String title;
  final String type;
  final String description;
  final String address;
  final String phone;
  final String schedule;
  final String imagePath;
  final int order;
  final double? latitude;
  final double? longitude;

  Muzeu({
    required this.title,
    required this.type,
    required this.description,
    required this.address,
    required this.phone,
    required this.schedule,
    required this.imagePath,
    required this.order,
    this.latitude,
    this.longitude,
  });

  factory Muzeu.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Muzeu(
      title: data['title'] ?? '',
      type: data['type'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      schedule: data['schedule'] ?? '',
      imagePath: data['imagePath'] ??
          'https://via.placeholder.com/400x200?text=Imagine+neexistenta',
      order: data['order'] ?? 0,
      latitude: (data['latitude'] is num) ? (data['latitude'] as num).toDouble() : null,
      longitude: (data['longitude'] is num) ? (data['longitude'] as num).toDouble() : null,
    );
  }
}

class MuzeePage extends StatefulWidget {
  const MuzeePage({super.key});

  @override
  State<MuzeePage> createState() => _MuzeePageState();
}

class _MuzeePageState extends State<MuzeePage> {
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

  Widget _titlePillRich(String formattedDate) {
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
          child: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : kBrand,
              ),
              children: [
                const TextSpan(text: "Muzee • "),
                TextSpan(
                  text: formattedDate,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _floatingPillsHeader(
    BuildContext context,
    String formattedDate,
  ) {
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
                      child: _titlePillRich(formattedDate),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // păstrăm simetria ca în celelalte pagini
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
    final formattedDate = DateFormat("d MMMM", "ro_RO").format(DateTime.now());

    // ✅ spațiu real pentru footer floating
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final footerSpace = 90 + bottomInset + 12;

    // ✅ păstrăm comportamentul tău (top ca înainte)
    final topPad = MediaQuery.of(context).padding.top + 80;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      extendBody: true,

      // ✅ "buline" (back + titlu în pill)
      appBar: _floatingPillsHeader(context, formattedDate),

      body: Stack(
        children: [
          Positioned.fill(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('muzee')
                  .orderBy('order')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "Nu există muzee disponibile momentan.",
                      style: TextStyle(fontSize: 16, color: AppTheme.textSecondary(context)),
                    ),
                  );
                }

                final muzee = snapshot.data!.docs
                    .map((d) => Muzeu.fromFirestore(d))
                    .toList();

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    top: topPad,
                    left: 16,
                    right: 16,
                    bottom: footerSpace,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CategoryMapPreview(
                        collection: 'muzee',
                        markerColor: const Color(0xFF6A1B9A),
                        markerIcon: Icons.museum,
                        extractPoints: (data) {
                          final lat = (data['latitude'] is num) ? (data['latitude'] as num).toDouble() : null;
                          final lng = (data['longitude'] is num) ? (data['longitude'] as num).toDouble() : null;
                          if (lat != null && lng != null) return [LatLng(lat, lng)];
                          return [];
                        },
                        getTitle: (data) => data['title']?.toString() ?? 'Muzeu',
                        onMarkerTap: (ctx, doc) {
                          Navigator.push(ctx, MaterialPageRoute(
                            builder: (_) => MuzeuDetaliiPage(muzeu: Muzeu.fromFirestore(doc)),
                          ));
                        },
                      ),
                      ...muzee.map((m) => _buildCard(context, m)).toList(),
                      const SizedBox(height: 40),
                      Center(
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
                      const SizedBox(height: 10),
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

  Widget _buildCard(BuildContext context, Muzeu muzeu) {
    final shortDesc = muzeu.description.length > 120
        ? "${muzeu.description.substring(0, 120)}..."
        : muzeu.description;

    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MuzeuDetaliiPage(muzeu: muzeu)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(imageUrl: 
                muzeu.imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 180,
                errorWidget: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/imagine_gri.jpg.webp',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 180,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    muzeu.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "🏛️ ${muzeu.type}",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.accentGlobal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    shortDesc,
                    style: TextStyle(fontSize: 14, color: AppTheme.textPrimary(context)),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MuzeuDetaliiPage(muzeu: muzeu),
                        ),
                      );
                    },
                    child: Text(
                      "Vezi detalii",
                      style: TextStyle(
                        color: AppTheme.accentGlobal,
                        fontWeight: FontWeight.bold,
                      ),
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
