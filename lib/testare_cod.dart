import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';

// paginile existente
import 'package:viziteaza_oradea/biserici_page.dart';
import 'package:viziteaza_oradea/cafenele_page.dart';
import 'package:viziteaza_oradea/catedrale_page.dart';
import 'package:viziteaza_oradea/cazari_page.dart';
import 'package:viziteaza_oradea/distractii_page.dart';
import 'package:viziteaza_oradea/faq_page.dart';
import 'package:viziteaza_oradea/galerie_page.dart';
import 'package:viziteaza_oradea/muzee_page.dart';
import 'package:viziteaza_oradea/restaurante_page.dart';
import 'package:viziteaza_oradea/stranduri_page.dart';
import 'package:viziteaza_oradea/fast_food_page.dart';
import 'evenimente_page.dart';
import 'istorie_page.dart';
import 'oradea_moderna_page.dart';
import 'video_widget.dart';
import 'baile_felix_page.dart';
import 'filarmonica_page.dart';
import 'package:viziteaza_oradea/teatru_page.dart';
import 'widgets/custom_footer.dart';
import 'favorite_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}
class MenuItemData {
    final IconData icon;
    final String text;
    final Widget destination;

    MenuItemData({
      required this.icon,
      required this.text,
      required this.destination,
    });
  }
class _HomePageState extends State<HomePage> {

  // ------------------------------------------------------------
  // 🔹 Structura itemelor de meniu — folosită în popup
  // ------------------------------------------------------------
  

  // ------------------------------------------------------------
  // 🔹 Construire card modern pentru fiecare secțiune din meniu
  // ------------------------------------------------------------
  Widget _buildMenuSection({
    required String title,
    required List<MenuItemData> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         Text(
  title,
  style: const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: Color(0xFF004E64),
  ),
),

          const SizedBox(height: 14),


         ...items.map((item) {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 1, end: 1),
    duration: const Duration(milliseconds: 150),
    builder: (context, scale, child) {
      return Transform.scale(
        scale: scale,
        child: child,
      );
    },
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        // efect mic la tap
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => item.destination),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(item.icon, size: 26, color: Color(0xFF004E64)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.text,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    ),
  );
}).toList(),


        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // 🔹 Popup modern pentru meniu (fără header, exact ca în poză)
  // ------------------------------------------------------------
  void _showModernMenu(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (context) {
        return Center(
  child: TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.85, end: 1.0),
    duration: const Duration(milliseconds: 220),
    curve: Curves.easeOutBack,
    builder: (context, scale, child) {
      return Opacity(
        opacity: scale,
        child: Transform.scale(
          scale: scale,
          child: child,
        ),
      );
    },
    child: ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.88,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.87),
            borderRadius: BorderRadius.circular(30),
          ),
          child: SingleChildScrollView(

                  child: Column(
                    children: [

                      _buildMenuSection(
  title: "Galerie",
  items: [
    MenuItemData(
      icon: Icons.photo_library_outlined,
      text: "Poze Oradea",
      destination: GaleriePage(),
    ),
    MenuItemData(
      icon: Icons.favorite_border,
      text: "Salvate de tine",
      destination: FavoritePage(),
    ),
  ],
),

SizedBox(height: 14),

_buildMenuSection(
  title: "Mâncare",
  items: [
    MenuItemData(
      icon: Icons.local_cafe_outlined,
      text: "Cafenele",
      destination: CafenelePage(),
    ),
    MenuItemData(
      icon: Icons.restaurant_outlined,
      text: "Restaurante",
      destination: RestaurantePage(),
    ),
    MenuItemData(
      icon: Icons.fastfood_outlined,
      text: "FastFood",
      destination: FastFoodPage(),
    ),
  ],
),

SizedBox(height: 14),

_buildMenuSection(
  title: "Activități",
  items: [
    MenuItemData(
      icon: Icons.theater_comedy_outlined,
      text: "Teatru",
      destination: TeatruPage(),
    ),
    MenuItemData(
      icon: Icons.music_note_outlined,
      text: "Filarmonica",
      destination: FilarmonicaPage(),
    ),
    MenuItemData(
      icon: Icons.pool_outlined,
      text: "AquaPark",
      destination: StranduriPage(),
    ),
    MenuItemData(
      icon: Icons.event_outlined,
      text: "Evenimente",
      destination: EvenimentePage(),
    ),
    MenuItemData(
      icon: Icons.celebration_outlined,
      text: "Distracții",
      destination: DistractiiPage(),
    ),
  ],
),

SizedBox(height: 14),

_buildMenuSection(
  title: "Cultură",
  items: [
    MenuItemData(
      icon: Icons.museum_outlined,
      text: "Muzee",
      destination: MuzeePage(),
    ),
    MenuItemData(
      icon: Icons.church_outlined,
      text: "Biserici",
      destination: BisericiPage(),
    ),
    MenuItemData(
      icon: Icons.account_balance_outlined,
      text: "Catedrale / Mănăstiri",
      destination: CatedralePage(),
    ),
  ],
),

SizedBox(height: 14),

_buildMenuSection(
  title: "De locuit",
  items: [
    MenuItemData(
      icon: Icons.hotel_outlined,
      text: "Cazări",
      destination: CazariPage(),
    ),
  ],
),

SizedBox(height: 14),

_buildMenuSection(
  title: "În apropiere",
  items: [
    MenuItemData(
      icon: Icons.terrain_outlined,
      text: "Băile Felix",
      destination: BaileFelixPage(),
    ),
  ],
),

SizedBox(height: 14),

_buildMenuSection(
  title: "Altele",
  items: [
    MenuItemData(
      icon: Icons.info_outline,
      text: "Despre aplicație",
      destination: FAQPage(),
    ),
  ],
),

                    ],
                  ),
                ),
              ),
            ),
          ),
  ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // 🔹 Începutul build() + AppBar
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat("d MMMM", "ro_RO").format(DateTime.now());
    final double topPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight + 16;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Scaffold(
        backgroundColor: const Color(0xFFE8F1F4),
        extendBodyBehindAppBar: true,

        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AppBar(
                backgroundColor: Colors.white.withOpacity(0.2),
                elevation: 0,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Color(0xFF004E64)),
                      onPressed: () => _showModernMenu(context),
                    ),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF004E64),
                        ),
                        children: [
                          const TextSpan(text: "Astăzi, "),
                          TextSpan(
                            text: formattedDate,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF004E64),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ------------------------------------------------------------
        // 🔹 BODY COMPLET
        // ------------------------------------------------------------
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: topPadding,
                  bottom: 20,
                  left: 16,
                  right: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Bine ai venit în Oradea.\nLocul unde trecutul și prezentul dansează împreună!",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Noi te ajutăm să vizitezi Oradea așa cum trebuie.",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔹 Imagine principală din Firestore
                    const FirestoreHeaderImage(),

                    const SizedBox(height: 50),

                    // 🔹 Titlu Localizare
                    const Text(
                      "Localizare",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "📍 Localizare: nord-vestul României, în județul Bihor, aproape de granița cu Ungaria.\n"
                      "👥 Populație: ~190.000 locuitori (2025).\n"
                      "🏛️ Rol: centru administrativ, economic, universitar și turistic.\n"
                      "🏞️ Râu: străbătut de Crișul Repede, care oferă orașului un peisaj urban pitoresc.",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 50),

                    // ------------------------------------------------------------
                    // 🔹 CARD ISTORIE
                    // ------------------------------------------------------------
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const IstoriePage()),
                      ),
                      child: Container(
                        height: 300,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                "assets/images/istorie1.png",
                                fit: BoxFit.cover,
                              ),

                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.65),
                                      Colors.black.withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                              ),

                              const Positioned(
                                left: 20,
                                bottom: 60,
                                right: 20,
                                child: Text(
                                  "Descoperă povestea\nOradiei de altădată",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.2,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black54,
                                        blurRadius: 8,
                                        offset: Offset(1, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              Positioned(
                                left: 20,
                                bottom: 15,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF004E64).withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.2),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Explorează",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward_rounded,
                                          color: Colors.white, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),

                    const Text(
                      "Oradea s-a transformat într-un exemplu de urbanism european — curat, verde, smart și plin de viață.",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 50),

                    // ------------------------------------------------------------
                    // 🔹 CARD ORADEA MODERNĂ
                    // ------------------------------------------------------------
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const OradeaModernaPage()),
                      ),
                      child: Container(
                        height: 300,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                "assets/images/oradea_moderna.jpg",
                                fit: BoxFit.cover,
                              ),

                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF004E64).withOpacity(0.6),
                                      Colors.black.withOpacity(0.25),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                              ),

                              const Positioned(
                                left: 20,
                                bottom: 60,
                                right: 20,
                                child: Text(
                                  "Oradea de azi.\nLuminoasă, vie, modernă.",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                              ),

                              Positioned(
                                left: 20,
                                bottom: 15,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Vezi transformarea",
                                        style: TextStyle(
                                          color: Color(0xFF004E64),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward_rounded,
                                          color: Color(0xFF004E64), size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),

                    const Text(
                      "Oradea este o poveste vie despre renaștere și viziune.",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 50),

                    const Text(
                      "Credite videoclip: Visit Oradea",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        color: Color.fromARGB(200, 126, 126, 126),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Builder(
                      builder: (context) {
                        final double screenW = MediaQuery.of(context).size.width;
                        final double videoH = screenW * 0.65;

                        return Container(
                          height: videoH,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: const Color(0xFF004E64), width: 0.8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: const OradeaVideoWidget(
                              enableTapToToggleSound: true,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 50),

                    const Center(
                      child: Text(
                        "— Vizitează Oradea © 2025 —",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    const SizedBox(height: 5),
                  ],
                ),
              ),
            ),

            const CustomFooter(isHome: true),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// 🔹 FirestoreHeaderImage
// ------------------------------------------------------------
class FirestoreHeaderImage extends StatelessWidget {
  const FirestoreHeaderImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('homeImage')
              .limit(1)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF004E64)),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  "Imaginea principală nu este disponibilă momentan.",
                  style: TextStyle(color: Colors.black54),
                ),
              );
            }

            final url = snapshot.data!.docs.first['imageUrl'] ?? '';

            return Image.network(
              url,
              fit: BoxFit.fitWidth,
              width: double.infinity,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image,
                    size: 42, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }
}
