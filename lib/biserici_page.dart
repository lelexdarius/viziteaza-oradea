import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';

import 'biserici_ortodoxe_page.dart';
import 'biserici_catolice_page.dart';
import 'biserici_neoprotestante_page.dart';
import 'widgets/custom_footer.dart';

// === MODEL ===
class BisericaCategorie {
  final String title;
  final String subtitle;
  final String imagePath;
  final int order;

  BisericaCategorie({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.order,
  });

  factory BisericaCategorie.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BisericaCategorie(
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      imagePath: data['imagePath'] ?? '',
      order: data['order'] ?? 0,
    );
  }
}

// === PAGINA PRINCIPALĂ BISERICI ===
class BisericiPage extends StatefulWidget {
  const BisericiPage({super.key});

  @override
  State<BisericiPage> createState() => _BisericiPageState();
}

class _BisericiPageState extends State<BisericiPage> {
  static const Color kBrand = Color(0xFF004E64);

  // -------------------------------------------------------------
  // ✅ UI helpers (Apple 2025 - “buline” sus)
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
    final formattedDate = DateFormat("d MMMM", "ro_RO").format(DateTime.now());
    final double topPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight + 10;

    // ✅ spațiu real pentru footer floating (ca să nu intre scroll-ul sub el)
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final footerSpace = 90 + bottomInset + 12;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F1F4),
      extendBodyBehindAppBar: true,
      extendBody: true, // ✅ elimină banda albă din spatele footer-ului

      // ✅ DOAR sus: “floating pills”
      appBar: _floatingPillsHeader(context, "Biserici • $formattedDate"),

      // ✅ Layout corect: content + footer floating
      body: Stack(
        children: [
          Positioned.fill(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('biserici_categorii')
                  .orderBy('order')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("Nu există categorii momentan."),
                  );
                }

                final categorii = snapshot.data!.docs
                    .map((d) => BisericaCategorie.fromFirestore(d))
                    .toList();

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    top: topPadding,
                    left: 16,
                    right: 16,
                    bottom: footerSpace, // ✅ important
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      ...categorii
                          .map((cat) => _buildCategoryCard(context, cat))
                          .toList(),
                      const SizedBox(height: 40),
                      const Padding(
                        padding: EdgeInsets.only(top: 12, bottom: 6),
                        child: Center(
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
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ✅ Footer floating (nu mai “împinge” layout-ul, nu mai face bandă albă)
          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomFooter(isHome: true),
          ),
        ],
      ),
    );
  }

  // === CARD CATEGORIE (LĂSAT IDENTIC) ===
  Widget _buildCategoryCard(BuildContext context, BisericaCategorie cat) {
    Widget destination;
    switch (cat.title.toLowerCase()) {
      case 'ortodoxe':
        destination = const BisericiOrtodoxePage();
        break;
      case 'catolice':
        destination = BisericiCatolicePage();
        break;
      case 'neoprotestante':
        destination = const BisericiNeoprotestantePage();
        break;
      default:
        destination = const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => destination),
      ),
      child: Card(
        color: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: cat.imagePath.isNotEmpty
                  ? Image.network(
                      cat.imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 180,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/imagine_gri.jpg.webp',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 180,
                        );
                      },
                    )
                  : Image.asset(
                      'assets/images/imagine_gri.jpg.webp',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 180,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat.subtitle,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      height: 1.4,
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
