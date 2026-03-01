import 'package:flutter/material.dart';
import 'dart:ui'; // blur
import 'package:viziteaza_oradea/services/app_state.dart';

class OradeaModernaPage extends StatelessWidget {
  const OradeaModernaPage({Key? key}) : super(key: key);

  // ✅ identitate vizuală
  static const Color kBrand = Color(0xFF004E64);
  static const Color kBg = Color(0xFFE8F1F4);

  // -------------------------------------------------------------
  // ✅ Floating pills header (stil curat + blur)
  // -------------------------------------------------------------
  Widget _pillIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final isDark = AppState.instance.isDarkMode;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
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
                border: Border.all(color: isDark ? Colors.white : Colors.white.withOpacity(0.60), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(icon, color: isDark ? Colors.white : (iconColor ?? kBrand), size: 20),
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
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.black : Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: isDark ? Colors.white : Colors.white.withOpacity(0.55), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 14,
                offset: const Offset(0, 8),
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
                    icon: Icons.arrow_back_ios_new_rounded,
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

  // -------------------------------------------------------------
  // ✅ 5 imagini + text între ele (clar, fără exagerări)
  // -------------------------------------------------------------
  List<_SectiuneModerna> _sectiuni() => const [
        _SectiuneModerna(
          imagine: "assets/images/oradea_mod_1.jpg.webp",
          eticheta: "Imagine de ansamblu",
          titlu: "Oradea, în prezent",
          subtitlu: "Un oraș reabilitat, ordonat și ușor de parcurs",
          continut:
              "În ultimii ani, Oradea s-a remarcat prin reabilitarea centrului istoric, lucrări de modernizare a spațiilor publice și o administrare orientată spre proiecte. "
              "Se observă investiții în infrastructură, în calitatea spațiului urban și în servicii pentru cetățeni.",
          repere: ["centrul istoric reabilitat", "spații publice refăcute", "proiecte urbane coerente"],
          icon: Icons.location_city_rounded,
        ),
        _SectiuneModerna(
          imagine: "assets/images/oradea_mod_2.jpg.webp",
          eticheta: "Infrastructură",
          titlu: "Transport și mobilitate",
          subtitlu: "Trasee mai bune, zone pietonale și alternative reale",
          continut:
              "Un element important al modernizării este legat de mobilitate: îmbunătățirea transportului public, amenajarea zonelor pietonale și extinderea infrastructurii pentru biciclete. "
              "Acestea reduc aglomerația și cresc confortul în oraș.",
          repere: ["transport public", "zone pietonale", "piste pentru biciclete"],
          icon: Icons.directions_bus_rounded,
        ),
        _SectiuneModerna(
          imagine: "assets/images/oradea_moderna.jpg.webp",
          eticheta: "Servicii",
          titlu: "Digitalizare și administrație",
          subtitlu: "Mai multe proceduri realizate online, mai puține drumuri",
          continut:
              "Modernizarea unui oraș se vede și în modul în care funcționează serviciile publice. "
              "Oradea a investit în digitalizarea unor procese administrative și în simplificarea interacțiunii cu instituțiile, astfel încât anumite cereri și plăți să se poată face mai ușor.",
          repere: ["servicii online", "proceduri simplificate", "comunicare mai rapidă"],
          icon: Icons.account_balance_rounded,
        ),
        _SectiuneModerna(
          imagine: "assets/images/oradea_mod_4.jpg.webp",
          eticheta: "Cultură",
          titlu: "Spații culturale și evenimente",
          subtitlu: "Cetatea, centrul și infrastructura pentru evenimente",
          continut:
              "Oradea a pus accent pe refacerea și folosirea spațiilor cu valoare istorică și culturală. "
              "Cetatea Oradea găzduiește frecvent activități culturale, iar centrul istoric reabilitat susține turismul și evenimentele. "
              "Orașul are și infrastructură modernă pentru sport și concerte.",
          repere: ["Cetatea Oradea", "centrul istoric", "evenimente și turism"],
          icon: Icons.theater_comedy_rounded,
        ),
        _SectiuneModerna(
          imagine: "assets/images/oradea_mod_5.jpg.webp",
          eticheta: "Calitatea vieții",
          titlu: "Spații verzi și zone de relaxare",
          subtitlu: "Amenajări pe malul Crișului și legătura cu stațiunile",
          continut:
              "Modernizarea se reflectă și în calitatea vieții: zone verzi întreținute, spații pentru plimbare și mișcare, amenajări pe malul Crișului Repede. "
              "În apropiere, Băile Felix și 1 Mai completează oferta de relaxare și turism balnear.",
          repere: ["malurile Crișului", "zone verzi", "Băile Felix și 1 Mai"],
          icon: Icons.park_rounded,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 10;
    final sectiuni = _sectiuni();

    return Scaffold(
      backgroundColor: kBg,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: _floatingPillsHeader(context, "Oradea Modernă"),
      body: Stack(
        children: [
          const _FundalFin(),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topPadding)),

              // card scurt de introducere
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _CardSticla(
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: kBrand.withOpacity(0.10),
                            border: Border.all(color: Colors.white.withOpacity(0.55)),
                          ),
                          child: const Icon(Icons.apartment_rounded, color: kBrand, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "O prezentare în 5 secțiuni despre cum arată Oradea astăzi: infrastructură, servicii, cultură și calitatea vieții.",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.5,
                              height: 1.25,
                              fontWeight: FontWeight.w700,
                              color: Colors.black.withOpacity(0.80),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              // 5 blocuri: imagine + text între ele
              SliverList.separated(
                itemCount: sectiuni.length,
                separatorBuilder: (_, __) => const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  final s = sectiuni[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _Erou(
                          imagine: s.imagine,
                          titlu: s.titlu,
                          subtitlu: s.subtitlu,
                          eticheta: s.eticheta,
                          numar: "${index + 1}/5",
                          icon: s.icon,
                        ),
                        const SizedBox(height: 12),
                        _Continut(
                          titlu: s.titlu,
                          continut: s.continut,
                          repere: s.repere,
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 28),
                  child: Center(
                    child: Text(
                      "— Un oraș care își respectă trecutul și construiește viitorul —",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.black38,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// MODEL
// ===============================================================
class _SectiuneModerna {
  final String imagine;
  final String eticheta;
  final String titlu;
  final String subtitlu;
  final String continut;
  final List<String> repere;
  final IconData icon;

  const _SectiuneModerna({
    required this.imagine,
    required this.eticheta,
    required this.titlu,
    required this.subtitlu,
    required this.continut,
    required this.repere,
    required this.icon,
  });
}

// ===============================================================
// FUNDAL (fin, discret) - blur + "glow" ușor
// ===============================================================
class _FundalFin extends StatelessWidget {
  const _FundalFin();

  static const Color kBrand = Color(0xFF004E64);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE8F1F4),
                    Color(0xFFF7FBFD),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -120,
              left: -90,
              child: _PataBlur(size: 280, color: kBrand.withOpacity(0.18)),
            ),
            Positioned(
              bottom: -150,
              right: -110,
              child: _PataBlur(size: 320, color: const Color(0xFF2AA6B6).withOpacity(0.14)),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(color: Colors.transparent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PataBlur extends StatelessWidget {
  final double size;
  final Color color;
  const _PataBlur({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(width: size, height: size, color: color),
      ),
    );
  }
}

// ===============================================================
// EROU (imagine + etichete de tip "sticlă")
// ===============================================================
class _Erou extends StatelessWidget {
  final String imagine;
  final String titlu;
  final String subtitlu;
  final String eticheta;
  final String numar;
  final IconData icon;

  const _Erou({
    required this.imagine,
    required this.titlu,
    required this.subtitlu,
    required this.eticheta,
    required this.numar,
    required this.icon,
  });

  static const Color kBrand = Color(0xFF004E64);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(imagine, fit: BoxFit.cover),

            // overlay discret
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.76),
                    Colors.black.withOpacity(0.16),
                    kBrand.withOpacity(0.10),
                  ],
                  stops: const [0.0, 0.62, 1.0],
                ),
              ),
            ),

            // etichete sus
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  _PastilaSticla(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          eticheta,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _PastilaSticla(
                    child: Text(
                      numar,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // titlu jos
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titlu,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitlu,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.92),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PastilaSticla extends StatelessWidget {
  final Widget child;
  const _PastilaSticla({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.26), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ===============================================================
// CARD "STICLĂ" (generic)
// ===============================================================
class _CardSticla extends StatelessWidget {
  final Widget child;
  const _CardSticla({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.70),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.60), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ===============================================================
// CONȚINUT (text + repere clare)
// ===============================================================
class _Continut extends StatelessWidget {
  final String titlu;
  final String continut;
  final List<String> repere;

  const _Continut({
    required this.titlu,
    required this.continut,
    required this.repere,
  });

  static const Color kBrand = Color(0xFF004E64);

  @override
  Widget build(BuildContext context) {
    return _CardSticla(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: kBrand.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.65)),
                ),
                child: const Icon(Icons.apartment_rounded, color: kBrand, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titlu,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.black.withOpacity(0.86),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            continut,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14.8,
              height: 1.62,
              color: Colors.black.withOpacity(0.84),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: repere.map((r) => _Eticheta(text: r)).toList(),
          ),
        ],
      ),
    );
  }
}

class _Eticheta extends StatelessWidget {
  final String text;
  const _Eticheta({required this.text});

  static const Color kBrand = Color(0xFF004E64);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.60),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: kBrand.withOpacity(0.10)),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: Colors.black.withOpacity(0.74),
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
