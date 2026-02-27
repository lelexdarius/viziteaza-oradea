import 'package:flutter/material.dart';
import 'dart:ui'; // blur

class IstoriePage extends StatelessWidget {
  const IstoriePage({Key? key}) : super(key: key);

  // ✅ identitate vizuală (poți ajusta)
  static const Color kBrand = Color(0xFF004E64);
  static const Color kBg = Color(0xFFE8F1F4);

  // -------------------------------------------------------------
  // ✅ Floating pills header (Apple 2025)
  // -------------------------------------------------------------
  Widget _pillIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
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
                border: Border.all(color: Colors.white.withOpacity(0.60), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
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

  Widget _titlePill(String text) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.55), width: 1),
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
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Center(child: _titlePill(title)),
                  ),
                  const SizedBox(width: 10),
                  // simetrie (ca să stea titlul perfect centrat)
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
  // ✅ Data: 5 imagini + text între ele
  // -------------------------------------------------------------
  List<_TimelineSection> _sections() => const [
        _TimelineSection(
          imagePath: "assets/images/istorie11.jpg.webp",
          kicker: "Panoramă",
          title: "Repere esențiale",
          subtitle: "O privire rapidă asupra evoluției Oradiei",
          body:
              "Oradea a evoluat din așezări vechi spre un centru religios, cultural și urban important în Europa Centrală.",
        ),
        _TimelineSection(
          imagePath: "assets/images/istorie2.jpg.webp",
          kicker: "Evul Mediu",
          title: "Începuturi și consacrare",
          subtitle: "De la așezare la centru episcopal",
          body:
              "Zona Oradiei a fost locuită încă din antichitate. În Evul Mediu timpuriu, aici se conturează o așezare importantă.\n\n"
              "În 1113 este menționată în Diploma Benedictinilor din Zobor. Regele Ladislau I al Ungariei (Sf. Ladislau) fondează o mănăstire și o episcopie catolică — nucleul viitoarei Cetăți a Oradiei.",
        ),
        _TimelineSection(
          imagePath: "assets/images/istorie3.jpg.webp",
          kicker: "Fortificații",
          title: "Cetatea și epoca de aur",
          subtitle: "Secolele XIII–XVI",
          body:
              "Oradea devine un centru religios și cultural major al regiunii. Cetatea, consolidată în secolele XIV–XVI, ajunge printre cele mai moderne fortificații renascentiste din Europa Centrală.\n\n"
              "Orașul devine loc de înmormântare pentru mai mulți regi maghiari și un punct strategic în rețeaua politică a vremii.",
        ),
        _TimelineSection(
          imagePath: "assets/images/istorie4.jpg.webp",
          kicker: "Schimbări de imperii",
          title: "Otomani și Habsburgi",
          subtitle: "Secolele XVI–XIX",
          body:
              "După 1526, Oradea intră sub influența Principatului Transilvaniei, apoi urmează alternanțe între dominația otomană și cea habsburgică.\n\n"
              "În 1660 orașul este ocupat de turci și devine centru administrativ al pașalâcului până în 1692, când este recucerit de habsburgi.\n\n"
              "În secolele XVIII–XIX, sub Imperiul Habsburgic, orașul se dezvoltă puternic urbanistic și cultural: palate baroce, catedrale, școli, spitale; un oraș multietnic și multicultural.",
        ),
        _TimelineSection(
          imagePath: "assets/images/istorie5.jpg.webp",
          kicker: "Modern",
          title: "Secolul XX–prezent",
          subtitle: "De la transformări politice la reînnoire urbană",
          body:
              "După 1918–1920, Oradea devine parte a României (Tratatul de la Trianon, 1920). În 1940–1944 este ocupată temporar de Ungaria hortystă, revenind României în 1944.\n\n"
              "În perioada comunistă are loc industrializarea accelerată, păstrându-se totuși nucleul istoric.\n\n"
              "După 1989, Oradea se remarcă prin modernizare, reabilitări (Art Nouveau / Secession) și dezvoltarea turismului balnear (Băile Felix, 1 Mai).",
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 10;
    final sections = _sections();

    return Scaffold(
      backgroundColor: kBg,
      extendBodyBehindAppBar: true,
      extendBody: true,

      // ✅ floating pills sus
      appBar: _floatingPillsHeader(context, "Istorie"),

      body: Stack(
        children: [
          // ✅ fundal “Apple-ish” cu glow/gradiente soft
          const _SoftBackdrop(),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topPadding)),

              // ✅ Intro glass card mic (floating)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _GlassCard(
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
                          child: const Icon(Icons.timeline_rounded, color: kBrand, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Istoria Oradiei, în 5 momente vizuale ",
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

              // ✅ Timeline: 5 imagini + text între ele (stil 2025 / glass / floating)
              SliverList.separated(
                itemCount: sections.length,
                separatorBuilder: (_, __) => const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  final s = sections[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _HeroHeader(
                          imagePath: s.imagePath,
                          title: s.title,
                          subtitle: s.subtitle,
                          kicker: s.kicker,
                          indexLabel: "${index + 1}/5",
                        ),
                        const SizedBox(height: 12),
                        _GlassContent(
                          title: s.title,
                          body: s.body,
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
                      "— Oradea, o poveste în continuă evoluție —",
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
class _TimelineSection {
  final String imagePath;
  final String kicker;
  final String title;
  final String subtitle;
  final String body;

  const _TimelineSection({
    required this.imagePath,
    required this.kicker,
    required this.title,
    required this.subtitle,
    required this.body,
  });
}

// ===============================================================
// SOFT BACKDROP (glow/gradiente) - Apple 2025-ish
// ===============================================================
class _SoftBackdrop extends StatelessWidget {
  const _SoftBackdrop();

  static const Color kBrand = Color(0xFF004E64);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            // gradient de bază
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE8F1F4),
                    Color(0xFFF6FBFD),
                  ],
                ),
              ),
            ),

            // blob 1
            Positioned(
              top: -120,
              left: -90,
              child: _BlurBlob(
                size: 260,
                color: kBrand.withOpacity(0.18),
              ),
            ),

            // blob 2
            Positioned(
              bottom: -140,
              right: -110,
              child: _BlurBlob(
                size: 320,
                color: const Color(0xFF2AA6B6).withOpacity(0.16),
              ),
            ),

            // haze blur peste tot (foarte subtil)
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

class _BlurBlob extends StatelessWidget {
  final double size;
  final Color color;
  const _BlurBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          width: size,
          height: size,
          color: color,
        ),
      ),
    );
  }
}

// ===============================================================
// HERO HEADER (cu kicker + badge)
// ===============================================================
class _HeroHeader extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final String kicker;
  final String indexLabel;

  const _HeroHeader({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.kicker,
    required this.indexLabel,
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
            Image.asset(imagePath, fit: BoxFit.cover),

            // overlay cinematic
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.74),
                    Colors.black.withOpacity(0.18),
                    kBrand.withOpacity(0.10),
                  ],
                  stops: const [0.0, 0.62, 1.0],
                ),
              ),
            ),

            // top badges
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  _GlassPill(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          kicker,
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
                  _GlassPill(
                    child: Text(
                      indexLabel,
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

            // bottom title block
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
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
                      subtitle,
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

class _GlassPill extends StatelessWidget {
  final Widget child;
  const _GlassPill({required this.child});

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
// GLASS CARD (generic)
// ===============================================================
class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

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
// GLASS CONTENT (text între poze)
// ===============================================================
class _GlassContent extends StatelessWidget {
  final String title;
  final String body;

  const _GlassContent({
    required this.title,
    required this.body,
  });

  static const Color kBrand = Color(0xFF004E64);

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
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
                child: const Icon(Icons.history_edu_rounded, color: kBrand, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
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
            body,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14.8,
              height: 1.62,
              color: Colors.black.withOpacity(0.84),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
