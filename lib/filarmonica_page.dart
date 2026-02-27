import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'filarmonica_detalii_page.dart';
import 'widgets/custom_footer.dart';

class FilarmonicaPage extends StatelessWidget {
  const FilarmonicaPage({super.key});

  static const Color kBrand = Color(0xFF004E64);
  static const Color kBg = Color(0xFFE8F1F4);

  // -------------------------------------------------------------
  // ✅ UI helpers (Apple 2025 - “buline”)
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
                      child: _titlePill("Filarmonica de Stat Oradea"),
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

  // -------------------------------------------------------------
  // ✅ “Card” alb premium (pentru textul de sus)
  // -------------------------------------------------------------
  Widget _whiteInfoCard({required Widget child}) {
    return Container(
      width: double.infinity,
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
        MediaQuery.of(context).padding.top + kToolbarHeight + 10;

    // ✅ spațiu real pentru footer floating
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final footerSpace = 90 + bottomInset + 12;

    return Scaffold(
      backgroundColor: kBg,

      // ✅ elimină banda albă din spatele footerului
      extendBodyBehindAppBar: true,
      extendBody: true,

      // ✅ “buline” ca la celelalte pagini
      appBar: _floatingPillsHeader(context),

      // ✅ BODY cu footer overlay
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                top: topPadding,
                left: 16,
                right: 16,
                bottom: footerSpace, // ✅ cheia
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // ✅ bloc “Programul Lunii” într-un card alb (mai Apple)
                  _whiteInfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Programul Lunii",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18.5,
                            fontWeight: FontWeight.w900,
                            color: kBrand,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "🎶 Filarmonica de Stat Oradea te invită la o serie de concerte remarcabile. Aici poți descoperi magia muzicii clasice într-o atmosferă unică.",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13.8,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.80),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          "Programul casieriei: Luni - Miercuri: 12:30 - 14:30 \nJoi 11 - 13 si 18 - 18:50, Vineri inchis \nProgram administrativ: Luni - Vineri: 8 - 16",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13.6,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.78),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 🔹 Evenimente din Firestore (funcționalitate intactă)
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('filarmonica')
                        .where('order', isGreaterThan: 0)
                        .orderBy('order')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            "Momentan nu există evenimente disponibile.",
                            style: TextStyle(color: Colors.black54),
                          ),
                        );
                      }

                      final concerts = snapshot.data!.docs;

                      return Column(
                        children: concerts
                            .map((doc) => _buildConcertCard(context, doc))
                            .toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 34),
                  const Center(
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
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),

          // ✅ Footer floating (fără bandă albă)
          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomFooter(isHome: true),
          ),
        ],
      ),
    );
  }

  // ---------- CARD EVENIMENT ----------
  Widget _buildConcertCard(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final Timestamp? ts = data["data_timp"];
    final DateTime? concertDate = ts?.toDate();

    final bool esteViitor =
        concertDate == null ? true : concertDate.isAfter(DateTime.now());
    final Color statusColor = esteViitor ? Colors.green : Colors.red;

    final String pret = data["pret"]?.toString() ?? "Nespecificat";
    final String dataText = data["data"] ?? "";
    final String ora = data["ora"] ?? "";

    // ✅ DOAR asta s-a schimbat: cardul devine alb (în rest, logică intactă)
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white, // ✅ cerința ta
      surfaceTintColor: Colors.white, // ✅ Material 3: păstrează alb
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: data["banner"] != null &&
                          data["banner"].toString().startsWith("http")
                      ? Image.network(
                          data["banner"],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          "assets/images/filarmonica_de_stat_oradea.jpg.webp",
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month,
                              color: Color(0xFF004E64), size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              dataText,
                              style: const TextStyle(
                                color: Color(0xFF004E64),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              data["titlu"] ?? "",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                height: 1.2,
                              ),
                            ),
                          ),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (ora.isNotEmpty)
                        Text(
                          "Ora: $ora",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              data["dirijor"] ?? "",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              data["descriere"] ?? "",
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Preț: $pret lei",
                  style: const TextStyle(
                    color: Color.fromARGB(255, 63, 147, 21),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FilarmonicaDetaliiPage(
                          title: data["titlu"] ?? "",
                          imageUrl: data["banner"] ?? "",
                          solist: data["solist"] ?? "",
                          dataConcertului: data["data"] ?? "",
                          ora: data["ora"] ?? "",
                          linkBilete: data["bilete"] ?? "",
                          locatie: data["locatie"] ?? "",
                          organizator: data["organizator"] ?? "",
                          pret: pret,
                          dataTimp: concertDate,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.music_note, color: Color(0xFF004E64)),
                  label: const Text(
                    "Mai multe detalii",
                    style: TextStyle(
                      color: Color(0xFF004E64),
                      fontWeight: FontWeight.bold,
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
}
