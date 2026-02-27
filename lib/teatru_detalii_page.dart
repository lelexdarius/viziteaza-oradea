import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';

// favorite
import 'models/favorite_item.dart';
import 'services/favorite_service.dart';

// ✅ footer standard din app
import 'widgets/custom_footer.dart';

class TeatruDetaliiPage extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String dataSpectacolului;
  final String ora;
  final String locatie;
  final String organizator;
  final String pret;
  final String linkBilete;
  final String descriere;
  final DateTime? dataTimp;

  const TeatruDetaliiPage({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.dataSpectacolului,
    required this.ora,
    required this.locatie,
    required this.organizator,
    required this.pret,
    required this.linkBilete,
    required this.descriere,
    this.dataTimp,
  });

  @override
  State<TeatruDetaliiPage> createState() => _TeatruDetaliiPageState();
}

class _TeatruDetaliiPageState extends State<TeatruDetaliiPage> {
  bool isFavorite = false;

  static const Color kBrand = Color(0xFF004E64);
  static const Color kBg = Color(0xFFE8F1F4);

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  // -------------------------
  // 🔵 Load Favorite status
  // -------------------------
  Future<void> _loadFavorite() async {
    final fav = await FavoriteService.isFavorite(widget.title);
    if (!mounted) return;
    setState(() => isFavorite = fav);
  }

  // -------------------------
  // 🔵 Toggle favorite
  // -------------------------
  Future<void> _toggleFavorite() async {
    final item = FavoriteItem(
      id: widget.title, // titlul este un ID unic
      type: "teatru",
      data: {
        "id": widget.title,
        "title": widget.title,
        "imagePath": widget.imageUrl,
        "data": widget.dataSpectacolului,
        "ora": widget.ora,
        "locatie": widget.locatie,
        "organizator": widget.organizator,
        "pret": widget.pret,
        "descriere": widget.descriere,
        "linkBilete": widget.linkBilete,
      },
    );

    await FavoriteService.toggleFavorite(item);
    await _loadFavorite();
  }

  // -------------------------
  // 🔵 Launch bilete link
  // -------------------------
  Future<void> _launchURL(BuildContext context) async {
    if (widget.linkBilete.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Link-ul pentru bilete nu este disponibil."),
        ),
      );
      return;
    }

    final url = Uri.parse(widget.linkBilete);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nu s-a putut deschide linkul.")),
      );
    }
  }

  // -------------------------------------------------------------
  // ✅ UI helpers (Apple 2025)
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

  Widget _whiteCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.fromLTRB(14, 14, 14, 14),
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

  Widget _infoLine(IconData icon, String title, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: kBrand.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: kBrand, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.8,
                  height: 1.45,
                  color: Colors.black.withOpacity(0.82),
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(
                    text: "$title: ",
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: kBrand,
                    ),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
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
                  Expanded(child: Center(child: _titlePill(widget.title))),
                  const SizedBox(width: 10),
                  _pillIconButton(
                    icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                    onTap: _toggleFavorite,
                  ),
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
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 10;

    // ✅ spațiu real pentru footer floating (ca să nu intre scroll-ul sub el)
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final footerSpace = 90 + bottomInset + 12;

    return Scaffold(
      backgroundColor: kBg,
      extendBodyBehindAppBar: true,
      extendBody: true,

      // ✅ “buline” + titlu pill (fără background AppBar)
      appBar: _floatingPillsHeader(context),

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
                  // Imagine copertă
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: widget.imageUrl.isNotEmpty &&
                            widget.imageUrl.startsWith("http")
                        ? Image.network(
                            widget.imageUrl,
                            width: double.infinity,
                            height: 230,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              "assets/images/teatru.jpg.webp",
                              width: double.infinity,
                              height: 230,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            "assets/images/teatru.jpg.webp",
                            width: double.infinity,
                            height: 230,
                            fit: BoxFit.cover,
                          ),
                  ),

                  const SizedBox(height: 14),

                  // ✅ Card info (data/ora/locatie/organizator/pret/bilete)
                  _whiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18.5,
                            fontWeight: FontWeight.w900,
                            color: kBrand,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 12),

                        _infoLine(
                          Icons.calendar_month_outlined,
                          "Data",
                          widget.dataSpectacolului,
                        ),
                        _infoLine(Icons.access_time, "Ora", widget.ora),
                        _infoLine(Icons.place_outlined, "Locație", widget.locatie),
                        _infoLine(Icons.account_balance_outlined, "Organizator",
                            widget.organizator),
                        _infoLine(Icons.sell_outlined, "Preț",
                            "${widget.pret} lei"),

                        if (widget.linkBilete.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () => _launchURL(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: kBrand.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: kBrand.withOpacity(0.12),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.confirmation_number_outlined,
                                      color: kBrand),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "Cumpără bilet",
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        color: kBrand,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14.8,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.open_in_new, color: kBrand),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ✅ Card descriere
                  _whiteCard(
                    child: Text(
                      widget.descriere.isNotEmpty
                          ? widget.descriere
                          : "Detalii despre acest spectacol vor fi disponibile în curând.",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        height: 1.55,
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withOpacity(0.80),
                      ),
                    ),
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

          // ✅ Footer floating
          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomFooter(isHome: true),
          ),
        ],
      ),
    );
  }
}
