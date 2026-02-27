import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ pentru imaginea din Firestore
import 'dart:ui'; // pentru BackdropFilter

// paginile tale existente
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

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat("d MMMM", "ro_RO").format(DateTime.now());
    final double topPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight + 16;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Scaffold(
        backgroundColor: const Color(0xFFE8F1F4),

        // 🔹 AppBar
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
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu, color: Color(0xFF004E64)),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF004E64)),
                        children: [
                          const TextSpan(text: "Astăzi, "),
                          TextSpan(
                            text: formattedDate,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF004E64)),
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

        // 🔹 Drawer (meniu lateral)
        drawer: Drawer(
          backgroundColor: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                color: const Color(0xFF004E64),
                padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      "Vizitează Oradea",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Descoperă orașul pas cu pas",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              _buildCategoryHeader("Galerie"),
              _buildMenuItem(
                context,
                title: "Poze Oradea",
                icon: Icons.photo_library_outlined,
                destination: GaleriePage(),
              ),
              _buildCategoryHeader("Salvate de tine"),
              _buildMenuItem(
                context,
                title: "Favorite",
                icon: Icons.photo_library_outlined,
                destination: const FavoritePage(),
              ),

              // MANCARE
              const SizedBox(height: 10),
              _buildCategoryHeader("Mâncare"),
              _buildMenuItem(context,
                  title: "Cafenele",
                  icon: Icons.local_cafe_outlined,
                  destination: CafenelePage()),
              _buildMenuItem(context,
                  title: "Restaurante",
                  icon: Icons.restaurant_outlined,
                  destination: RestaurantePage()),
              _buildMenuItem(context,
                  title: "FastFood",
                  icon: Icons.fastfood_outlined,
                  destination: FastFoodPage()),
              const Divider(height: 24),

              // ACTIVITATI
              _buildCategoryHeader("Activități"),
              _buildMenuItem(context,
                  title: "Teatru",
                  icon: Icons.theater_comedy_outlined,
                  destination: const TeatruPage()),
              _buildMenuItem(
                context,
                title: "Filarmonica",
                icon: Icons.music_note_outlined,
                destination: FilarmonicaPage(),
              ),
              _buildMenuItem(context,
                  title: "AquaPark",
                  icon: Icons.pool_outlined,
                  destination: const StranduriPage()),
              _buildMenuItem(
                context,
                title: "Evenimente",
                icon: Icons.event_outlined,
                destination: EvenimentePage(),
              ),
              _buildMenuItem(context,
                  title: "Distracții",
                  icon: Icons.celebration_outlined,
                  destination: DistractiiPage()),
              const Divider(height: 30),

              // CULTURA
              _buildCategoryHeader("Cultura"),
              _buildMenuItem(context,
                  title: "Muzee",
                  icon: Icons.museum_outlined,
                  destination: MuzeePage()),
              _buildMenuItem(context,
                  title: "Biserici",
                  icon: Icons.church_outlined,
                  destination: BisericiPage()),
              _buildMenuItem(context,
                  title: "Catedrale / Mănăstiri",
                  icon: Icons.account_balance_outlined,
                  destination: CatedralePage()),
              const Divider(height: 24),

              // DE LOCUIT
              _buildCategoryHeader("De locuit"),
              _buildMenuItem(context,
                  title: "Cazări",
                  icon: Icons.hotel_outlined,
                  destination: CazariPage()),
              const Divider(height: 24),

              // BAILE FELIX
              _buildCategoryHeader("In apropiere"),
              _buildMenuItem(
                context,
                title: "Băile Felix",
                icon: Icons.terrain_outlined,
                destination: const BaileFelixPage(),
              ),

              // DESPRE APLICATIE
              const Divider(height: 30),
              ListTile(
                dense: true,
                visualDensity: const VisualDensity(vertical: -4),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                minVerticalPadding: 0,
                leading: const Icon(Icons.info_outline, color: Colors.grey),
                title: const Text("Despre aplicație"),
                onTap: () {
                  Navigator.pop(context); // închide meniul Drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FAQPage()),
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),

        // 🔹 Conținut + footer
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

                    // 🔁 AICI era caruselul. ACUM:
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
                      "🏛️ Rol: centru administrativ, economic, universitar și turistic al regiunii Crișana.\n"
                      "🏞️ Râu: străbătut de Crișul Repede, care oferă orașului un peisaj urban pitoresc.",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 50),

                    // 🔹 Card Istorie – versiunea ta (nemodificată)
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
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 10.0),
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.easeInOut,
                                  builder: (context, value, child) {
                                    return Transform.translate(
                                      offset: Offset(value, 0),
                                      child: child,
                                    );
                                  },
                                  onEnd: () {
                                    Future.delayed(
                                        const Duration(milliseconds: 500), () {
                                      if (context.mounted) setState(() {});
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF004E64)
                                          .withOpacity(0.9),
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
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),

                    const Text(
                      "Oradea s-a transformat într-un exemplu de urbanism european — curat, verde, smart și plin de viață — atrăgând turiști, investitori și tineri dornici de oportunități.",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 50),

                    // 🔹 Card Oradea Modernă – versiunea ta (nemodificată)
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
                                      const Color(0xFF004E64).withOpacity(0.65),
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
                                  "Oradea de azi.\nLuminoasă, vie, modernă.",
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
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 10.0),
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.easeInOut,
                                  builder: (context, value, child) {
                                    return Transform.translate(
                                      offset: Offset(value, 0),
                                      child: child,
                                    );
                                  },
                                  onEnd: () {
                                    Future.delayed(
                                        const Duration(milliseconds: 500), () {
                                      if (context.mounted) setState(() {});
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.95),
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 6,
                                        ),
                                      ],
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
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),

                    const Text(
                      "Oradea de astăzi este mai mult decât un oraș din nord-vestul României — este o poveste vie despre renaștere, viziune și oameni care au înțeles că frumusețea unui loc se construiește în timp, cu grijă și cu suflet. În ultimii ani, Oradea a devenit un model de dezvoltare urbană în România, un oraș care respiră ordine, eleganță și energie pozitivă. \n \nCentrul istoric, cândva uitat, a fost redat vieții: clădirile Art Nouveau au fost restaurate în detaliu, redând farmecul de altădată, iar Piața Unirii a devenit un spațiu vibrant, plin de oameni, evenimente, artiști și lumină. Aici, serile de vară se împletesc cu muzica străzii, mirosul cafelelor proaspete și râsetele turiștilor veniți din toată lumea.",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 50),
                    const Text("Credite videoclip: Visit Oradea",style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        color: Color.fromARGB(221, 126, 126, 126),
                        height: 1.5,
                      ),),
                      const SizedBox(height: 10),
                    // 🔹 Video Oradea (mare + tap oriunde = sunet)
                    Builder(
                      builder: (context) {
                        final double screenW =
                            MediaQuery.of(context).size.width;
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

                    const Padding(
                      padding: EdgeInsets.only(top: 12, bottom: 6),
                      child: Center(
                        child: Text(
                          "— Vizitează Oradea © 2025 —",
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

  // ---------- Helper Widgets ----------
  static Widget _buildCategoryHeader(String title) => Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 4),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF004E64),
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  static Widget _buildMenuItem(BuildContext context,
          {required String title,
          required IconData icon,
          required Widget destination}) =>
      ListTile(
        dense: true,
        visualDensity: const VisualDensity(vertical: -3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Icon(icon, color: Colors.black87),
        title: Text(title, style: const TextStyle(color: Colors.black87)),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => destination));
        },
      );
}

/// 🔹 Imagine principală din Firestore (înlocuiește caruselul)
class FirestoreHeaderImage extends StatelessWidget {
  const FirestoreHeaderImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8), // 🔹 fix mic universal
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
                  textAlign: TextAlign.center,
                ),
              );
            }

            final url = snapshot.data!.docs.first['imageUrl'] as String? ?? '';

            return Image.network(
              url,
              fit: BoxFit.fitWidth,
              width: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF004E64)),
                );
              },
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image, size: 42, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }
}
