import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'services/iap_service.dart';

// ✅ pentru back -> Home (fără blank)
import 'package:viziteaza_oradea/home.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:viziteaza_oradea/services/app_state.dart';

class PremiumUnlockPage extends StatefulWidget {
  const PremiumUnlockPage({Key? key}) : super(key: key);

  @override
  State<PremiumUnlockPage> createState() => _PremiumUnlockPageState();
}

class _PremiumUnlockPageState extends State<PremiumUnlockPage> {
  StreamSubscription<bool>? _sub;
  StreamSubscription<String>? _msgSub; // ✅ NOU: mesaje IAP -> SnackBar

  // ✅ culori din Home.dart (păstrăm brand-ul ca bază)
  static const Color kBrand = Color(0xFF004E64);
  static const Color kBg = Color(0xFFE8F1F4);

  // ✅ accent din logo (doar accent)
  static const Color kAccent = Color(0xFFF2A019); // portocaliu
  static const Color kInk = Color(0xFF0F1F2A);

  // ✅ prevenim double-pop (blank negru)
  bool _didClose = false;

  // ✅ slider imagini
  final List<String> _heroImages = const [
    "assets/images/premium_unlock1.png.webp",
    "assets/images/premium_unlock2.png.webp",
    "assets/images/premium_unlock3.png.webp",
    "assets/images/premium_unlock4.png.webp",
  ];

  late final PageController _heroPageController;
  int _heroIndex = 0;
  Timer? _heroTimer;

  @override
  void initState() {
    super.initState();

    _heroPageController = PageController();

    // ✅ autoplay subtil
    if (_heroImages.length > 1) {
      _heroTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        if (!mounted) return;
        final next = (_heroIndex + 1) % _heroImages.length;
        _heroPageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
        );
      });
    }

    // ✅ închide pagina automat când premium devine true (O SINGURĂ DATĂ)
    _sub = IAPService.instance.premiumStateStream.listen((isPremium) {
      if (!mounted) return;
      if (isPremium == true && !_didClose) {
        _didClose = true;
        Navigator.pop(context, true);
      }
    });

    // ✅ NOU: Mesaje (restore/buy/error) -> SnackBar
    _msgSub = IAPService.instance.iapMessageStream.listen((msg) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    });
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _heroPageController.dispose();
    _sub?.cancel();
    _msgSub?.cancel(); // ✅ NOU
    super.dispose();
  }

  // =============================================================
  // ✅ BACK FIX: mergi mereu la HOME și resetezi stack (fără blank)
  // =============================================================
  PageRoute<T> _noAnimRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      opaque: true,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (_, __, ___) => page,
    );
  }

  void _goHomeRoot() {
    if (!mounted) return;
    if (_didClose) return;
    _didClose = true;

    Navigator.of(context).pushAndRemoveUntil(
      _noAnimRoute(HomePage()),
      (route) => false,
    );
  }

  // -------------------------------------------------------------
  // UI helpers
  // -------------------------------------------------------------
  Widget _pillIcon({
    required IconData icon,
    Color? bg,
    Color? fg,
    double size = 20,
  }) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: (bg ?? Colors.white).withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.22), width: 1),
      ),
      child: Icon(icon, color: fg ?? Colors.white, size: size),
    );
  }

  Widget _pillIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = kBrand,
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
                border: Border.all(color: isDark ? Colors.white : Colors.white.withOpacity(0.60), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, color: isDark ? Colors.white : iconColor, size: 20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _titlePill(String title) {
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
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : kBrand,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _premiumBadgePill() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppState.instance.isDarkMode
                ? const Color(0xFF2C2C2E)
                : Colors.white.withOpacity(0.70),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppState.instance.isDarkMode
                  ? Colors.white.withOpacity(0.20)
                  : Colors.white.withOpacity(0.55),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, size: 16, color: kAccent),
              const SizedBox(width: 6),
              Text(
                "Premium",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: AppState.instance.isDarkMode ? Colors.white : kBrand,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 7),
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: kAccent.withOpacity(0.95),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: AppState.instance.isDarkMode
                    ? Colors.white.withOpacity(0.85)
                    : Colors.black.withOpacity(0.62),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _packagePreviewCard() {
    final isDark = AppState.instance.isDarkMode;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBrand.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: kAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kAccent.withOpacity(0.22)),
                ),
                child: const Icon(Icons.card_giftcard_rounded, color: kAccent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Ce conțin traseele?",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black.withOpacity(0.78),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Turist in Oradea și nu ai încă un Ghid? Acesta este ghidul tău Digital! \n \nInformații atent selectate. Descoperi toate punctele interesante ale orașului.",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white.withOpacity(0.85) : Colors.black.withOpacity(0.58),
            ),
          ),
          const SizedBox(height: 12),
          _bullet("Găsești cele mai bune recomandări "),
          _bullet(
            "Conține informații despre: Calea Republicii, Piața Unirii, Vulturul Negru și multe alte obiective pe care nu le vei găsi altundeva in aplicație.",
          ),
          _bullet(
            "Cuprinde o harta integrata, care iti arata pas cu pas ce sa vizitezi intai(un traseu), pentru ca drumul sa fie cat mai eficient.(În unele zile, mașina nu prezintă o necesitate)",
          ),
          _bullet("Accesul este permanent: plătești o singură dată, fără abonament"),
        ],
      ),
    );
  }

  Widget _whatItFeelsLikeCard() {
    final isDark = AppState.instance.isDarkMode;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBrand.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: kBrand.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kBrand.withOpacity(0.12)),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: kBrand),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Pe scurt: Ghid turistic digital.\n"
              "Nu mai depinzi de nimeni.\nPret cum nu mai intalnesti la nici un ghid turistic.",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white.withOpacity(0.85) : Colors.black.withOpacity(0.60),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceBox(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final isDark = AppState.instance.isDarkMode;

    // ✅ preț real din Store (dacă este încărcat)
    final storePrice = IAPService.instance.premiumProduct?.price;
    final displayPrice = storePrice ?? "29,99 RON";

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBrand.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                displayPrice,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: h * 0.040,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black.withOpacity(0.80),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: kAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: kAccent.withOpacity(0.22)),
                ),
                child: const Text(
                  "O singură plată",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: kAccent,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrand.withOpacity(0.95),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => _onBuyPressed(context),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_open_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text(
                    "Deblochează Premium",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              // ✅ NOU: restore async (mesajele vin din iapMessageStream)
              onPressed: () async {
                await IAPService.instance.restore();
              },
              child: Text(
                "Restaurare achiziție",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: isDark ? Colors.white.withOpacity(0.70) : Colors.black.withOpacity(0.60),
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "Accesul se restaurează automat pe același cont App Store / Google Play.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: isDark ? Colors.white.withOpacity(0.50) : Colors.black.withOpacity(0.45),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // BUY HANDLER (PRODUCTION READY)
  // -------------------------------------------------------------
  Future<void> _onBuyPressed(BuildContext context) async {
    final available = IAPService.instance.isAvailable;
    final product = IAPService.instance.premiumProduct;

    if (!available || product == null) {
      // ✅ DEBUG: păstrăm test unlock (opțional)
      if (kDebugMode) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("DEBUG: Mod test — Premium a fost deblocat local")),
        );
        await IAPService.instance.setPremiumUnlocked(true);
        return;
      }

      // ✅ RELEASE: fără bypass
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Magazin indisponibil momentan. Încearcă din nou.")),
      );
      return;
    }

    await IAPService.instance.buyPremium();
  }

  // -------------------------------------------------------------
  // HERO SLIDER
  // -------------------------------------------------------------
  Widget _heroSlider() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        height: 250,
        width: double.infinity,
        child: Stack(
          children: [
            PageView.builder(
              controller: _heroPageController,
              itemCount: _heroImages.length,
              onPageChanged: (i) => setState(() => _heroIndex = i),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final path = _heroImages[index];
                final bool isNetwork =
                    path.startsWith("http://") || path.startsWith("https://");

                return isNetwork
                    ? CachedNetworkImage(imageUrl: 
                        path,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 250,
                        alignment: Alignment.center,
                        placeholder: (_, __) => Container(color: const Color(0xFFE8F1F4)),
                        errorWidget: (context, error, stack) {
                          return Container(
                            color: Colors.black.withOpacity(0.08),
                            child: const Center(
                              child: Icon(Icons.broken_image,
                                  size: 64, color: Colors.white70),
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        path,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 250,
                        alignment: Alignment.center,
                      );
              },
            ),
            if (_heroImages.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 10,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: IgnorePointer(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(_heroImages.length, (i) {
                        final active = i == _heroIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: active ? 14 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(active ? 0.92 : 0.45),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double safeTop = MediaQuery.of(context).padding.top;
    final double headerHeight = kToolbarHeight;
    final double topPadding = safeTop + headerHeight + 12;

    return WillPopScope(
      onWillPop: () async {
        _goHomeRoot();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppState.instance.isDarkMode ? Colors.black : kBg,
        extendBodyBehindAppBar: true,
        extendBody: true,
        body: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: topPadding,
                  left: 18,
                  right: 18,
                  bottom: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _heroSlider(),
                    const SizedBox(height: 18),
                    _packagePreviewCard(),
                    const SizedBox(height: 10),
                    _whatItFeelsLikeCard(),
                    const SizedBox(height: 16),
                    _priceBox(context),
                    const SizedBox(height: 18),
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
                  ],
                ),
              ),
            ),
            Positioned(
              top: safeTop,
              left: 0,
              right: 0,
              height: headerHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    _pillIconButton(
                      icon: Icons.arrow_back,
                      onTap: _goHomeRoot,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Center(
                        child: _titlePill("Trasee"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _premiumBadgePill(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
