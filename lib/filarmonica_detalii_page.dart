import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';

import 'models/favorite_item.dart';
import 'services/favorite_service.dart';
import 'widgets/custom_footer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:viziteaza_oradea/services/app_state.dart';
import 'package:viziteaza_oradea/utils/app_theme.dart';

class FilarmonicaDetaliiPage extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String descriere;
  final String solist;
  final String dataConcertului;
  final String ora;
  final String linkBilete;
  final String locatie;
  final String organizator;
  final String pret;
  final DateTime? dataTimp;

  const FilarmonicaDetaliiPage({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.descriere,
    required this.solist,
    required this.dataConcertului,
    required this.ora,
    required this.linkBilete,
    required this.locatie,
    required this.organizator,
    required this.pret,
    required this.dataTimp,
  }) : super(key: key);

  @override
  State<FilarmonicaDetaliiPage> createState() => _FilarmonicaDetaliiPageState();
}

class _FilarmonicaDetaliiPageState extends State<FilarmonicaDetaliiPage> {
  static const Color kBrand = Color(0xFF004E64);
  static const Color kBg = Color(0xFFE8F1F4);

  bool _isFav = false;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final fav = await FavoriteService.isFavorite(widget.title);
    if (!mounted) return;
    setState(() => _isFav = fav);
  }

  Future<void> _toggleFavorite() async {
    final item = FavoriteItem(
      id: widget.title,
      type: "filarmonica",
      data: {
        "id": widget.title,
        "title": widget.title,
        "imagePath": widget.imageUrl,
        "solist": widget.solist,
        "data": widget.dataConcertului,
        "ora": widget.ora,
        "locatie": widget.locatie,
        "organizator": widget.organizator,
        "pret": widget.pret,
        "linkBilete": widget.linkBilete,
      },
    );

    await FavoriteService.toggleFavorite(item);
    await _loadFavorite();
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    if (url.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Link-ul pentru bilete nu este disponibil.")),
      );
      return;
    }

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nu s-a putut deschide linkul.")),
      );
    }
  }

  // -------------------------------------------------------------
  // ✅ Apple 2025 "buline"
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
                    icon: _isFav ? Icons.favorite : Icons.favorite_border,
                    iconColor: Colors.red,
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

  // -------------------------------------------------------------
  // ✅ Card alb premium
  // -------------------------------------------------------------
  Widget _whiteCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppTheme.isDarkGlobal ? const Color(0xFF3A3A3C) : Colors.white.withOpacity(0.92),
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
    final bool esteViitor =
        widget.dataTimp == null ? true : widget.dataTimp!.isAfter(DateTime.now());
    final Color statusColor = esteViitor ? Colors.green : Colors.red;

    // ✅ spațiu real pentru footer floating
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final footerSpace = 90 + bottomInset + 12;

    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 10;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ✅ blur real "în spatele" header-ului cu buline
      extendBodyBehindAppBar: true,
      extendBody: true,

      appBar: _floatingPillsHeader(context),

      // ✅ BODY cu footer overlay
      body: Stack(
        children: [
          Positioned.fill(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                16,
                topPadding,
                16,
                footerSpace,
              ),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: _buildConcertImage(widget.imageUrl),
                ),
                const SizedBox(height: 14),

                _whiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titlu + status dot
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.accentGlobal,
                                height: 1.15,
                              ),
                            ),
                          ),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _infoRow(Icons.person, "Solist", widget.solist),
                      _infoRow(Icons.calendar_month, "Data", widget.dataConcertului),
                      _infoRow(Icons.access_time, "Ora", widget.ora),
                      _infoRow(Icons.location_on_outlined, "Locație", widget.locatie),
                      _infoRow(Icons.account_balance_outlined, "Organizator",
                          widget.organizator),

                      const SizedBox(height: 14),

                      // Preț
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF5F2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: kBrand.withOpacity(0.10)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.confirmation_number, color: AppTheme.accentGlobal),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Preț bilet: ${widget.pret} lei",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: AppTheme.accentGlobal,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (widget.linkBilete.trim().isNotEmpty) ...[
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => _launchURL(context, widget.linkBilete),
                          child: Text(
                            "Cumpără bilete online",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15.2,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.accentGlobal,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                if (widget.descriere.trim().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _whiteCard(
                    child: Text(
                      widget.descriere,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.4,
                        height: 1.55,
                        color: AppTheme.textPrimary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 30),

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
              ],
            ),
          ),

          // ✅ Footer fix "deasupra" conținutului
          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomFooter(isHome: true),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    final v = value.trim().isEmpty ? "—" : value.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.accentGlobal,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.2,
                  color: AppTheme.textPrimary(context),
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: TextStyle(
                      color: AppTheme.accentGlobal,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(text: v),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔵 Imagine concert
  Widget _buildConcertImage(String imageUrl) {
    if (imageUrl.startsWith("http")) {
      return CachedNetworkImage(imageUrl: 
        imageUrl,
        fit: BoxFit.cover,
        height: 220,
        width: double.infinity,
        errorWidget: (_, __, ___) => Image.asset(
          'assets/images/filarmonica_de_stat_oradea.jpg.webp',
          height: 220,
          fit: BoxFit.cover,
        ),
      );
    }

    return Image.asset(
      imageUrl.isNotEmpty
          ? imageUrl
          : 'assets/images/filarmonica_de_stat_oradea.jpg.webp',
      height: 220,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}
