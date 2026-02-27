import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'evenimente_detalii_page.dart';
import 'widgets/custom_footer.dart';

import 'package:viziteaza_oradea/home.dart'; // ✅ pentru HomePage
import 'package:cached_network_image/cached_network_image.dart';

class EvenimentePage extends StatelessWidget {
  const EvenimentePage({super.key});

  static const Color kBrand = Color(0xFF004E64);
  static const Color kBg = Color(0xFFE8F1F4);

  // ✅ Navigare către Home fără animație (evită blank)
  void _goHomeNoAnim(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pushReplacement(
      PageRouteBuilder(
        opaque: true,
        barrierDismissible: false,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => HomePage(),
        settings: const RouteSettings(name: CustomFooter.routeHome),
      ),
    );
  }

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
                    onTap: () => _goHomeNoAnim(context),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Center(
                      child: _titlePill("Evenimente Oradea"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // simetrie
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
  // ✅ “Card” alb premium (pentru intro)
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

    // ✅ Wrap cu FooterBackInterceptor ca butonul back (sistem) să ducă la Home
    return FooterBackInterceptor(
      child: Scaffold(
        backgroundColor: kBg,

        // ✅ IMPORTANT: asta elimină “banda albă” din spatele footer-ului
        extendBody: true,
        extendBodyBehindAppBar: true,

        // ✅ “buline” ca la restul paginilor
        appBar: _floatingPillsHeader(context),

        // ✅ Stack ca footerul să plutească
        body: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: topPadding,
                  left: 16,
                  right: 16,
                  bottom: footerSpace, // ✅ loc pentru footer
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // ✅ intro într-un chenar alb (stil Apple)
                    _whiteInfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Evenimente în Oradea",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18.5,
                              fontWeight: FontWeight.w900,
                              color: kBrand,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "🎉 Descoperă cele mai interesante evenimente, festivaluri și activități care au loc în Oradea.",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.8,
                              fontWeight: FontWeight.w600,
                              color: Colors.black.withOpacity(0.80),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('evenimente')
                          .orderBy('order')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text(
                              "Momentan nu există evenimente disponibile.",
                              style: TextStyle(color: Colors.black54),
                            ),
                          );
                        }

                        final events = snapshot.data!.docs;

                        return Column(
                          children: events
                              .map((doc) => _buildEventCard(context, doc))
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
              child: CustomFooter(isHome: false),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- CARD EVENIMENT ----------
  Widget _buildEventCard(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final String title = data["title"] ?? "Eveniment";
    final String description = data["description"] ?? "";
    final String locatie = data["address"] ?? "Locație necunoscută";
    final String dataText = data["schedule"] ?? "";
    final String pret = data["price"]?.toString() ?? "Nespecificat";
    final String banner = data["image"] ?? "";
    final String linkBilete = data["mapLink"] ?? "";

    // 🔹 Citește data_timp din Firestore
    final Timestamp? ts = data["data_timp"];
    final DateTime? eventDate = ts?.toDate();

    // 🔹 Determină dacă este eveniment viitor
    final bool esteViitor =
        eventDate == null ? true : eventDate.isAfter(DateTime.now());
    final Color statusColor = esteViitor ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      color: Colors.white, // ✅ alb
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Imagine + titlu + dată
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: banner.isNotEmpty && banner.startsWith("http")
                      ? CachedNetworkImage(imageUrl: 
                          banner,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          "assets/images/evenimente.jpg.webp",
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.only(left: 6, right: 4),
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month,
                              color: kBrand, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              dataText,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: kBrand, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              locatie,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 🔹 Descriere
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 10),

            // 🔹 Preț + buton detalii
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
                        builder: (_) => EventDetailsPage(
                          title: title,
                          description: description,
                          imagePath: banner,
                          data: dataText,
                          ora: "",
                          locatie: locatie,
                          pret: pret,
                          organizator: "",
                          linkBilete: linkBilete,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.event, color: kBrand),
                  label: const Text(
                    "Detalii",
                    style: TextStyle(
                      color: kBrand,
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
