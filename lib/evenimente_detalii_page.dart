import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';

import 'models/favorite_item.dart';
import 'services/favorite_service.dart';
import 'widgets/custom_footer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EventDetailsPage extends StatefulWidget {
  final String title;
  final String description;
  final String imagePath;
  final String data;
  final String ora;
  final String locatie;
  final String pret;
  final String organizator;
  final String linkBilete;

  const EventDetailsPage({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.data,
    required this.ora,
    required this.locatie,
    required this.pret,
    required this.organizator,
    required this.linkBilete,
  });

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  static const Color kBrand = Color(0xFF004E64);
  static const Color kBg = Color(0xFFE8F1F4);

  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  FavoriteItem _favoriteItem() {
    return FavoriteItem(
      id: widget.title,
      type: "eveniment",
      data: {
        "id": widget.title,
        "title": widget.title,
        "description": widget.description,
        "imagePath": widget.imagePath,
        "data": widget.data,
        "ora": widget.ora,
        "locatie": widget.locatie,
        "pret": widget.pret,
        "organizator": widget.organizator,
        "linkBilete": widget.linkBilete,
      },
    );
  }

  Future<void> _loadFavorite() async {
    final item = _favoriteItem();
    isFavorite = await FavoriteService.isFavorite(item.id);
    if (mounted) setState(() {});
  }

  Future<void> _launchURL(BuildContext context) async {
    if (widget.linkBilete.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Link-ul pentru eveniment nu este disponibil."),
        ),
      );
      return;
    }

    final Uri url = Uri.parse(widget.linkBilete);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nu s-a putut deschide linkul.")),
      );
    }
  }

  // -------------------------------------------------------------
  // ✅ UI helpers (Apple 2025 - “buline”)
  // -------------------------------------------------------------
  Widget _pillIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = kBrand,
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
              child: Icon(icon, color: iconColor, size: 20),
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
                      child: _titlePill(widget.title),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _pillIconButton(
                    icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                    iconColor: Colors.red,
                    onTap: () async {
                      final item = _favoriteItem();
                      await FavoriteService.toggleFavorite(item);
                      if (!mounted) return;
                      setState(() => isFavorite = !isFavorite);
                    },
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
  // ✅ “Card” alb premium (info + descriere)
  // -------------------------------------------------------------
  Widget _whiteCard({required Widget child}) {
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

  Widget _infoRow(IconData icon, String text, {Color? color, FontWeight? fw}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kBrand, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.2,
                height: 1.35,
                color: color ?? Colors.black.withOpacity(0.82),
                fontWeight: fw ?? FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ spațiu corect sub header (bulinele sunt overlay)
    final double topPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight + 10;

    // ✅ spațiu real pentru footer floating
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final footerSpace = 90 + bottomInset + 12;

    return Scaffold(
      backgroundColor: kBg,
      extendBodyBehindAppBar: true,
      extendBody: true,

      // ✅ header cu “buline”
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
                  // Imagine principală
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: widget.imagePath.isNotEmpty &&
                            widget.imagePath.startsWith("http")
                        ? CachedNetworkImage(imageUrl: 
                            widget.imagePath,
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Image.asset(
                              "assets/images/evenimente.jpg.webp",
                              width: double.infinity,
                              height: 220,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            "assets/images/evenimente.jpg.webp",
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                          ),
                  ),

                  const SizedBox(height: 16),

                  // ✅ Info într-un chenar alb (stil Apple)
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
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 10),

                        _infoRow(
                          Icons.calendar_month_outlined,
                          widget.ora.isNotEmpty
                              ? "${widget.data} • ${widget.ora}"
                              : widget.data,
                        ),
                        _infoRow(Icons.place_outlined, widget.locatie),
                        if (widget.organizator.isNotEmpty)
                          _infoRow(Icons.business_center_outlined,
                              widget.organizator),
                        _infoRow(
                          Icons.sell_outlined,
                          "Preț: ${widget.pret} lei",
                          color: const Color(0xFF2E7D32),
                          fw: FontWeight.w900,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ✅ Descriere într-un chenar alb
                  _whiteCard(
                    child: Text(
                      widget.description.isNotEmpty
                          ? widget.description
                          : "Detalii despre acest eveniment vor fi disponibile în curând.",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.4,
                        height: 1.55,
                        color: Colors.black.withOpacity(0.82),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Link (păstrat)
                  if (widget.linkBilete.isNotEmpty)
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => _launchURL(context),
                        icon: const Icon(Icons.open_in_browser,
                            color: Colors.white),
                        label: const Text(
                          "Vizitează site-ul evenimentului",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBrand,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          shadowColor: Colors.black45,
                          elevation: 5,
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

          // Footer floating
          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomFooter(isHome: true),
          ),
        ],
      ),
    );
  }
}
