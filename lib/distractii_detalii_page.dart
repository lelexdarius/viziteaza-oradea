import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';

import 'models/favorite_item.dart';
import 'services/favorite_service.dart';
import 'widgets/custom_footer.dart';

class DistractiiDetaliiPage extends StatefulWidget {
  final String title;
  final String description;
  final String image;
  final String price;
  final String schedule;
  final String address;
  final String mapLink;

  const DistractiiDetaliiPage({
    super.key,
    required this.title,
    required this.description,
    required this.image,
    required this.price,
    required this.schedule,
    required this.address,
    required this.mapLink,
  });

  @override
  State<DistractiiDetaliiPage> createState() => _DistractiiDetaliiPageState();
}

class _DistractiiDetaliiPageState extends State<DistractiiDetaliiPage> {
  static const Color kBrand = Color(0xFF004E64);

  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteState();
  }

  Future<void> _loadFavoriteState() async {
    final fav = await FavoriteService.isFavorite(widget.title);
    if (!mounted) return;
    setState(() => isFavorite = fav);
  }

  Future<void> _toggleFavorite() async {
    final item = FavoriteItem(
      id: widget.title,
      type: "distractie",
      data: {
        "title": widget.title,
        "description": widget.description,
        "image": widget.image,
        "price": widget.price,
        "schedule": widget.schedule,
        "address": widget.address,
        "mapLink": widget.mapLink,
      },
    );

    await FavoriteService.toggleFavorite(item);
    if (!mounted) return;
    setState(() => isFavorite = !isFavorite);
  }

  Future<void> _openGoogleMaps() async {
    if (widget.mapLink.trim().isEmpty) return;
    final url = Uri.parse(widget.mapLink);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
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
  // ✅ “Card” alb premium (Apple-ish)
  // -------------------------------------------------------------
  Widget _whiteCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBrand.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
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

    final bottomInset = MediaQuery.of(context).padding.bottom;
    final footerSpace = 90 + bottomInset + 12;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F1F4),
      extendBodyBehindAppBar: true,
      extendBody: true,

      // ✅ “buline” ca în restul app-ului
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
                  // IMAGINE
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: widget.image.startsWith("http")
                        ? Image.network(
                            widget.image,
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              "assets/images/imagine_gri.jpg.webp",
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            "assets/images/imagine_gri.jpg.webp",
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),

                  const SizedBox(height: 18),

                  // TITLU (în pagină)
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: kBrand,
                      fontFamily: 'Poppins',
                      height: 1.15,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ✅ DESCRIERE într-un chenar alb (ca ai cerut)
                  _whiteCard(
                    child: Text(
                      widget.description.isNotEmpty
                          ? widget.description
                          : "Detalii indisponibile momentan.",
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.55,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ✅ INFO BOX alb
                  _whiteCard(
                    child: Column(
                      children: [
                        _buildInfoRow(
                            Icons.price_change, "Preț:", widget.price),
                        const SizedBox(height: 10),
                        _buildInfoRow(
                            Icons.schedule, "Program:", widget.schedule),
                        const SizedBox(height: 10),
                        _buildInfoRow(
                            Icons.location_on, "Adresă:", widget.address),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // BUTON MAPS (păstrat)
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _openGoogleMaps,
                      icon: const Icon(Icons.map, color: Colors.white),
                      label: const Text(
                        "Deschide în Google Maps",
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBrand,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 34),

                  const Center(
                    child: Text(
                      "— Tour Oradea © 2025 —",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),

          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomFooter(isHome: true),
          ),
        ],
      ),
    );
  }

  // 🔵 Helper pentru info
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: kBrand, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 15, color: Colors.black87),
              children: [
                TextSpan(
                  text: "$label ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
