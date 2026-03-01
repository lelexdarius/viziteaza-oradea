import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:viziteaza_oradea/home.dart';
import 'widgets/custom_footer.dart';
import 'package:viziteaza_oradea/utils/app_theme.dart';
import 'package:viziteaza_oradea/services/app_state.dart';

class GaleriePage extends StatelessWidget {
  const GaleriePage({Key? key}) : super(key: key);

  static const Color kBrand = Color(0xFF004E64);
  static const Color kBg = Color(0xFFE8F1F4);

  final String instagramUrl = "https://www.instagram.com/ghiuroflaviu/";

  Future<void> _launchInstagram() async {
    final Uri url = Uri.parse(instagramUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Nu s-a putut deschide linkul: $url');
    }
  }

  void _goHomeNoAnim(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        opaque: true,
        barrierDismissible: false,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => HomePage(),
      ),
    );
  }

  // -------------------------------------------------------------
  // "Glass" DOAR pe elemente (buton / titlu), NU pe fundal
  // -------------------------------------------------------------
  Widget _glassPill({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  }) {
    final isDark = AppState.instance.isDarkMode;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        // Blur mic, doar pe element
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isDark ? Colors.black : Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: isDark ? Colors.white : Colors.white.withOpacity(0.70), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _iconPillButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = AppState.instance.isDarkMode;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: _glassPill(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: isDark ? Colors.white : AppTheme.accentGlobal, size: 20),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // SliverAppBar care SCROLLEAZĂ (pinned: false)
  // Fundal SOLID (kBg) -> nimic în spate (nici blur, nici poze)
  //
  // IMPORTANT: am scos collapsedHeight + topInset (asta împingea totul în jos)
  // -------------------------------------------------------------
  SliverAppBar _sliverAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: false,
      floating: false,
      snap: false,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // fundal solid => nu se vede nimic în spate
      automaticallyImplyLeading: false,
      toolbarHeight: kToolbarHeight,
      titleSpacing: 12,
      title: Row(
        children: [
          _iconPillButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => _goHomeNoAnim(context),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Center(
              child: _glassPill(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Text(
                  "Galerie foto",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    color: AppState.instance.isDarkMode ? Colors.white : AppTheme.accentGlobal,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const SizedBox(width: 42, height: 42), // placeholder simetrie
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Credit card (SCROLLEAZĂ cu conținutul)
  // Ca să fie mai aproape de AppBar, l-am urcat puțin cu Transform.translate
  // -------------------------------------------------------------
  Widget _creditCard(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, 0), // <- ajustează -6 / -10 dacă vrei
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            // blur mic, doar pe card
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withOpacity(0.88),
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
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                children: [
                  Text(
                    "Fotografiile sunt realizate de ",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: AppTheme.textPrimary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Ghiuro Flaviu",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: AppTheme.accent(context),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  GestureDetector(
                    onTap: _launchInstagram,
                    child: Image.asset(
                      "assets/icon/instagram.png",
                      width: 20,
                      height: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Build
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final footerSpace = 90 + bottomInset + 12;

    return FooterBackInterceptor(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        extendBody: true,
        body: Stack(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('galerie').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: AppTheme.accentGlobal),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return CustomScrollView(
                    slivers: [
                      _sliverAppBar(context),
                      SliverToBoxAdapter(child: _creditCard(context)),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Builder(
                            builder: (ctx) => Text(
                              "Nicio imagine disponibilă momentan.",
                              style: TextStyle(
                                color: AppTheme.textSecondary(ctx),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                final images = snapshot.data!.docs;

                return CustomScrollView(
                  slivers: [
                    _sliverAppBar(context),
                    SliverToBoxAdapter(child: _creditCard(context)),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(12, 6, 12, footerSpace),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childCount: images.length,
                        itemBuilder: (context, index) {
                          final data = images[index].data() as Map<String, dynamic>;
                          final imageUrl = data['imageUrl'] ?? '';
                          final width = (data['width'] ?? 400).toDouble();
                          final height = (data['height'] ?? 600).toDouble();
                          final aspectRatio = width / height;

                          return GestureDetector(
                            onTap: () => _openImage(context, imageUrl),
                            child: Hero(
                              tag: imageUrl,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: AspectRatio(
                                  aspectRatio: aspectRatio,
                                  child: _CachedFadeImage(url: imageUrl),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
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

  void _openImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => FullscreenImage(imageUrl: imageUrl),
        transitionDuration: const Duration(milliseconds: 150),
      ),
    );
  }
}

// =============================================================
// Cached image
// =============================================================
class _CachedFadeImage extends StatefulWidget {
  final String url;
  const _CachedFadeImage({Key? key, required this.url}) : super(key: key);

  @override
  State<_CachedFadeImage> createState() => _CachedFadeImageState();
}

class _CachedFadeImageState extends State<_CachedFadeImage> {
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _loaded ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: CachedNetworkImage(
        imageUrl: widget.url,
        fit: BoxFit.cover,
        progressIndicatorBuilder: (_, __, ___) =>
            Container(color: Colors.grey.shade300),
        imageBuilder: (context, imageProvider) {
          if (!_loaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _loaded = true);
            });
          }
          return Image(image: imageProvider, fit: BoxFit.cover);
        },
        errorWidget: (_, __, ___) =>
            const Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }
}

// =============================================================
// Fullscreen
// =============================================================
class FullscreenImage extends StatelessWidget {
  final String imageUrl;
  const FullscreenImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Hero(
            tag: imageUrl,
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
