import 'package:flutter/material.dart';
import 'dart:ui';

import 'widgets/custom_footer.dart';
import 'home.dart';

class TermeniPage extends StatelessWidget {
  const TermeniPage({Key? key}) : super(key: key);

  // -------------------------------------------------------------
  // Theme (aliniat cu Home)
  // -------------------------------------------------------------
  static const Color kBrand = Color(0xFF004E64);
  static const Color kBg = Color(0xFFE8F1F4);

  // ✅ route fără animație
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
            border: Border.all(
              color: Colors.white.withOpacity(0.55),
              width: 1,
            ),
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
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => _goHomeRoot(context),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Center(
                      child: _titlePill(title),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // ✅ simetrie ca la celelalte pagini
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
  // UI blocks (rămân la fel)
  // -------------------------------------------------------------
  Widget _heroHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
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
              color: kBrand,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: kBrand.withOpacity(0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.gavel_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Termeni și condiții (2025)",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.black.withOpacity(0.86),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Prin folosirea Tour Oradea, ești de acord cu regulile de mai jos. ",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.3,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.62),
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

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: kBrand,
        height: 1.2,
      ),
    );
  }

  Widget _paragraph(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14.5,
        height: 1.6,
        color: Colors.black.withOpacity(0.80),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _card({required Widget child}) {
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
      child: child,
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
      backgroundColor: kBg,
      extendBodyBehindAppBar: true,
      extendBody: true,

      // ✅ floating pills sus
      appBar: _floatingPillsHeader(context, "Termeni și condiții"),

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

                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle("1) Despre aplicație"),
                          const SizedBox(height: 8),
                          _paragraph(
                            "Tour Oradea este un ghid turistic digital cu rol informativ. "
                            "Îți oferă recomandări și informații despre locuri, obiective, mâncare, cultură și activități din Oradea. "
                            "Aplicația nu este o agenție de turism și nu înlocuiește informațiile oficiale (program, tarife, reguli).",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle("2) Cont, acces și utilizare"),
                          const SizedBox(height: 8),
                          _paragraph("Poți folosi Tour Oradea pentru informare personală. "),
                          const SizedBox(height: 10),
                          _paragraph(
                            "Dacă anumite funcții nu sunt disponibile temporar (de exemplu harta sau conținutul încărcat online), "
                            "motivul poate fi conexiunea la internet, mentenanța sau actualizările aplicației.",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle("3) Premium și plăți (o singură plată)"),
                          const SizedBox(height: 8),
                          _paragraph(
                            "Tour Oradea poate include acces Premium pentru funcții suplimentare (de exemplu: trasee pe mai multe zile, "
                            "hartă în traseu și salvarea progresului). Premium se achiziționează ca o singură plată (fără abonament).",
                          ),
                          const SizedBox(height: 10),
                          _paragraph(
                            "Plata se face prin magazinul platformei (App Store / Google Play), iar confirmarea plății și livrarea accesului "
                            "se realizează automat. Prețul afișat în aplicație poate varia în funcție de țară/monedă și setările magazinului.",
                          ),
                          const SizedBox(height: 10),
                          _paragraph(
                            "Dacă schimbi telefonul sau reinstalezi aplicația, poți folosi opțiunea „Restaurare achiziție” pentru a recupera "
                            "accesul Premium pe același cont de magazin (Apple ID / Google).",
                          ),
                          const SizedBox(height: 10),
                          _paragraph(
                            "Pentru rambursări (returnarea banilor), te rugăm să folosești procedura magazinului (App Store / Google Play). "
                            "Tour Oradea nu procesează direct plățile, deci nu poate efectua rambursări manual în locul magazinului.",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle("4) Informații, hărți și linkuri externe"),
                          const SizedBox(height: 8),
                          _paragraph(
                            "Tour Oradea afișează informații care pot include: program, prețuri, descrieri, imagini, locații pe hartă și linkuri "
                            "către site-uri externe sau aplicații de hărți. Unele informații se pot schimba fără preaviz (de exemplu: program special, "
                            "evenimente, lucrări, tarife).",
                          ),
                          const SizedBox(height: 10),
                          _paragraph(
                            "Când deschizi un link extern (de exemplu Google Maps / Apple Maps / site-ul unei locații), se aplică regulile și politica "
                            "acelui serviciu. Tour Oradea nu controlează conținutul extern.",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle("5) Drepturi de autor"),
                          const SizedBox(height: 8),
                          _paragraph(
                            "Imaginile și materialele despre locații pot aparține autorilor originali și sunt folosite cu scop informativ. "
                            "Dacă ești deținător de drepturi și consideri că un conținut trebuie actualizat sau eliminat, te rugăm să ne contactezi din „Ajutor”.",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle("6) Confidențialitate și date"),
                          const SizedBox(height: 8),
                          _paragraph(
                            "Respectăm confidențialitatea ta. Dacă ne trimiți un mesaj din „Ajutor”, poți introduce nume și email pentru a primi răspuns. "
                            "Folosim aceste date doar pentru a răspunde solicitării tale.",
                          ),
                          const SizedBox(height: 10),
                          _paragraph(
                            "Aplicația poate salva local anumite preferințe (de exemplu progresul din trasee). "
                            "Acestea sunt folosite ca să îți ofere o experiență mai bună și nu sunt vândute către terți.",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle("7) Limitarea responsabilității"),
                          const SizedBox(height: 8),
                          _paragraph(
                            "Tour Oradea depune eforturi pentru a păstra informațiile actuale, însă nu poate garanta că toate detaliile sunt perfecte în orice moment. "
                            "Utilizarea informațiilor din aplicație se face pe propria răspundere (de exemplu: verifică programul oficial înainte de a porni la drum).",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle("8) Actualizări și modificări"),
                          const SizedBox(height: 8),
                          _paragraph(
                            "Putem actualiza aplicația și acești termeni pentru a îmbunătăți experiența și pentru a ține pasul cu funcțiile noi. "
                            "Dacă folosești în continuare aplicația după o actualizare, înseamnă că ești de acord cu versiunea actualizată a termenilor.",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle("9) Contact"),
                          const SizedBox(height: 8),
                          _paragraph(
                            "Pentru întrebări, sugestii, corecții sau probleme legate de Premium, scrie-ne din pagina „Ajutor”. "
                            "Îți răspundem de obicei în cel mult 24 de ore.",
                          ),
                        ],
                      ),
                    ),

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
