import 'package:flutter/material.dart';
import 'dart:ui';

import 'home.dart';
import 'widgets/custom_footer.dart';
import 'package:viziteaza_oradea/utils/app_theme.dart';
import 'package:viziteaza_oradea/services/app_state.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({Key? key}) : super(key: key);

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  // -------------------------------------------------------------
  // Theme (aliniat cu Home)
  // -------------------------------------------------------------
  static const Color kBrand = Color(0xFF004E64);
  static const Color kBg = Color(0xFFE8F1F4);

  final List<Map<String, String>> faqs = [
    {
      "question": "Ce este Tour Oradea?",
      "answer":
          "Tour Oradea este un ghid turistic digital dedicat orașului Oradea. "
              "Te ajută să descoperi locuri frumoase, recomandări de mâncare, cultură și activități – rapid și ușor."
    },
    {
      "question": "Este Tour Oradea gratuit?",
      "answer":
          "Da. Aplicația este gratuită pentru folosirea de bază. "
              "Unele funcții pot fi disponibile ca „Premium\" (de exemplu trasee complete pe mai multe zile)."
    },
    {
      "question": "Ce înseamnă Premium și cum funcționează?",
      "answer":
          "Premium îți oferă acces la trasee pe mai multe zile, cu hartă și posibilitatea de a bifa obiectivele vizitate. "
              "Este o singură plată, fără abonament și fără plăți lunare."
    },
    {
      "question": "Pot face rezervări direct din aplicație?",
      "answer":
          "Momentan nu. Tour Oradea este un ghid informativ. "
              "Pentru rezervări (restaurante, cazări etc.), te rugăm să contactezi locația direct."
    },
    {
      "question": "Aplicația funcționează fără internet?",
      "answer":
          "O parte din conținut poate fi accesată și fără internet, însă pentru imagini, actualizări și hărți "
              "este nevoie de o conexiune la internet."
    },
    {
      "question": "Unde găsesc rapid cele mai populare categorii?",
      "answer":
          "Pe pagina principală există secțiunea „Cele mai accesate\", unde găsești rapid Cafenele, Restaurante, "
              "Poze Oradea, Teatru, Evenimente și Muzee."
    },
    {
      "question": "Cum pot vedea traseele recomandate pe zile?",
      "answer":
          "Intră la „Trasee\". Dacă ai acces Premium, vei vedea trasee pe mai multe zile, cu hartă și ordine recomandată. "
              "Poți marca obiectivele ca vizitate ca să-ți urmărești progresul."
    },
    {
      "question": "Cum pot contacta echipa Tour Oradea?",
      "answer":
          "Intră în pagina „Ajutor\" și completează formularul. "
              "Țintim să răspundem cât mai repede, de obicei în maximum 24 de ore."
    },
    {
      "question": "De unde provin informațiile din aplicație?",
      "answer":
          "Informațiile sunt colectate din surse publice și verificate periodic. "
              "Ne străduim să fie cât mai actuale, dar uneori pot apărea modificări (program, prețuri, evenimente)."
    },
    {
      "question": "Pot sugera un loc nou sau o corecție?",
      "answer":
          "Da. Scrie-ne din „Ajutor\" cu detaliile (nume, adresă, ce ar trebui schimbat). "
              "Dacă informația se confirmă, o includem într-o actualizare viitoare."
    },
    {
      "question": "De ce uneori apar diferențe la poze sau descrieri?",
      "answer":
          "Unele locații își actualizează periodic imaginile sau detaliile. "
              "Dacă observi ceva greșit, trimite-ne un mesaj din „Ajutor\" și rezolvăm."
    },
  ];

  // ✅ route fără animație (ca în footer)
  PageRoute<T> _noAnimRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      opaque: true,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (_, __, ___) => page,
    );
  }

  void _goHomeRoot(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      _noAnimRoute(HomePage()),
      (route) => false,
    );
  }

  // -------------------------------------------------------------
  // ✅ Floating Pills Header (Apple 2025)
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
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => _goHomeRoot(context),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Center(child: _titlePill(title))),
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

  // ✅ HERO
  Widget _heroHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBrand.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.accentGlobal,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentGlobal.withOpacity(0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.question_mark_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ai o întrebare?",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary(context),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Atinge o întrebare ca să vezi răspunsul. "
                  "Dacă nu găsești ce cauți, scrie-ne din pagina Ajutor.",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.3,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary(context),
                    height: 1.28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === FAQ CARD modern ===
  Widget _buildFAQCard(Map<String, String> faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.92),
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
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            faq["question"] ?? "",
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontSize: 14.5,
              height: 1.2,
            ),
          ),
          trailing: const Icon(Icons.expand_more_rounded, color: Colors.white),
          children: [
            Text(
              faq["answer"] ?? "",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.8,
                height: 1.5,
                color: AppTheme.textPrimary(context),
                fontWeight: FontWeight.w600,
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
        MediaQuery.of(context).padding.top + kToolbarHeight + 14;

    // ✅ spațiu real pentru footer floating
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final footerSpace = 90 + bottomInset + 12;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      extendBody: true,

      // ✅ înlocuiește vechiul _glassAppBar cu floating pills
      appBar: _floatingPillsHeader(context, "Întrebări frecvente"),

      body: FooterBackInterceptor(
        child: Stack(
          children: [
            Positioned.fill(
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
                    _heroHeader(),
                    const SizedBox(height: 14),

                    ...faqs.map(_buildFAQCard).toList(),

                    const SizedBox(height: 22),
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
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),

            const Align(
              alignment: Alignment.bottomCenter,
              child: CustomFooter(isHome: false),
            ),
          ],
        ),
      ),
    );
  }
}
