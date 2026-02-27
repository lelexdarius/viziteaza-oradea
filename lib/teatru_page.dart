import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'teatru_detalii_page.dart';
import 'widgets/custom_footer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TeatruPage extends StatelessWidget {
  const TeatruPage({super.key});

  static const Color kBrand = Color(0xFF004E64);
  static const Color kBg = Color(0xFFE8F1F4);

  @override
  Widget build(BuildContext context) {
    final double topPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight + 10;

    // ✅ spațiu real pentru footer floating (ca să nu intre scroll-ul sub el)
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final footerSpace = 90 + bottomInset + 12;

    return Scaffold(
      backgroundColor: kBg,
      extendBodyBehindAppBar: true,
      extendBody: true,

      // ✅ AppBar “invizibil”, dar cu “buline” (ca la Cafenele/Detalii)
      appBar: _floatingPillsHeader(context, "Teatrul Regina Maria"),

      body: Stack(
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
                  const SizedBox(height: 10),

                  // ✅ Header info în card alb (Apple-ish)
                  _whiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Programul Lunii",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: kBrand,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "🎭 Teatrul Regina Maria te invită să trăiești emoția scenei. Descoperă spectacole de comedie, dramă și muzical într-o atmosferă unică.",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13.8,
                            color: Colors.black87,
                            height: 1.55,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 18),
                        Text(
                          "Program casierie: Luni - Vineri: 10:00 - 17:00\n"
                          "Sâmbătă - Duminică: 17:00 - 19:00 (în zilele cu spectacole)\n"
                          "Telefon rezervări: 0359 409 475",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13.8,
                            color: Colors.black87,
                            height: 1.55,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 🔹 Evenimente din Firestore (funcționalitate păstrată)
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('teatru')
                        .where('order', isGreaterThan: 0)
                        .orderBy('order')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: CircularProgressIndicator(color: kBrand),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return _whiteCard(
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: kBrand.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.info_outline_rounded,
                                    color: kBrand),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Momentan nu există spectacole disponibile.",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black.withOpacity(0.72),
                                    height: 1.25,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final spectacole = snapshot.data!.docs;

                      return Column(
                        children: spectacole
                            .map((doc) => _buildSpectacolCard(context, doc))
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

          // ✅ Footer fix “deasupra” conținutului (fără bandă albă)
          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomFooter(isHome: true),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // ✅ Header cu “buline” + titlu pill (identic ca stil cu celelalte pagini)
  // -------------------------------------------------------------
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
                  Expanded(child: Center(child: _titlePill(title))),
                  const SizedBox(width: 10),
                  const SizedBox(width: 42, height: 42), // placeholder simetrie
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  // -------------------------------------------------------------
  // ✅ White “Apple” card
  // -------------------------------------------------------------
  Widget _whiteCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.fromLTRB(14, 14, 14, 14),
  }) {
    return Container(
      padding: padding,
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

  // ---------- CARD SPECTACOL (design nou, funcții intacte) ----------
  Widget _buildSpectacolCard(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final Timestamp? ts = data["data_timp"];
    final DateTime? spectacolDate = ts?.toDate();

    final bool esteViitor =
        spectacolDate == null ? true : spectacolDate.isAfter(DateTime.now());
    final Color statusColor = esteViitor ? const Color(0xFF137A3A) : const Color(0xFFB42318);

    final String pret = data["pret"]?.toString() ?? "Nespecificat";
    final String dataText = data["data"] ?? "";
    final String ora = data["ora"] ?? "";

    final String titlu = data["titlu"] ?? "";
    final String descriere = data["descriere"] ?? "";
    final String organizator = (data["organizator"] ?? "").toString();
    final String banner = (data["banner"] ?? "").toString();

    Widget imageWidget() {
      if (banner.isNotEmpty && banner.startsWith("http")) {
        return CachedNetworkImage(imageUrl: 
          banner,
          width: 96,
          height: 96,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => Image.asset(
            "assets/images/teatru.jpg.webp",
            width: 96,
            height: 96,
            fit: BoxFit.cover,
          ),
        );
      }
      return Image.asset(
        "assets/images/teatru.jpg.webp",
        width: 96,
        height: 96,
        fit: BoxFit.cover,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: kBrand.withOpacity(0.10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // top row: imagine + date + titlu + status dot
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: imageWidget(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // data
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: kBrand.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.calendar_month,
                                  color: kBrand, size: 16),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                dataText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  color: kBrand,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13.6,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                titlu,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15.6,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black.withOpacity(0.88),
                                  height: 1.15,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
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
                        if (ora.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            "Ora: $ora",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.2,
                              fontWeight: FontWeight.w700,
                              color: Colors.black.withOpacity(0.70),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              if (organizator.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  "Organizator: $organizator",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.2,
                    fontWeight: FontWeight.w700,
                    color: Colors.black.withOpacity(0.62),
                  ),
                ),
              ],

              const SizedBox(height: 10),

              Text(
                descriere,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.8,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withOpacity(0.78),
                  height: 1.45,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCF6E6).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color(0xFF137A3A).withOpacity(0.25),
                      ),
                    ),
                    child: Text(
                      "Preț: $pret lei",
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Color(0xFF137A3A),
                        fontWeight: FontWeight.w900,
                        fontSize: 12.6,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TeatruDetaliiPage(
                            title: titlu,
                            imageUrl: banner,
                            dataSpectacolului: dataText,
                            ora: ora,
                            linkBilete: data["bilete"] ?? "",
                            locatie: data["locatie"] ?? "",
                            organizator: organizator,
                            pret: pret,
                            dataTimp: spectacolDate,
                            descriere: descriere,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.theater_comedy, color: kBrand),
                    label: const Text(
                      "Mai multe detalii",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: kBrand,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: kBrand,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
