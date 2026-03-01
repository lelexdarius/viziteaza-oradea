import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:viziteaza_oradea/main.dart' show appNavigatorKey;
import 'package:viziteaza_oradea/premium_unlock_page.dart';
import 'package:viziteaza_oradea/services/app_state.dart';
import 'package:viziteaza_oradea/services/iap_service.dart';

// ─────────────────────────────────────────────────────────────
// Full-screen overlay widget — place it in a Stack above everything
// ─────────────────────────────────────────────────────────────
class PremiumPromoOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const PremiumPromoOverlay({Key? key, required this.onDismiss})
      : super(key: key);

  @override
  State<PremiumPromoOverlay> createState() => _PremiumPromoOverlayState();
}

class _PremiumPromoOverlayState extends State<PremiumPromoOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  static const Color kBrand  = Color(0xFF004E64);
  static const Color kAccent = Color(0xFFF2A019);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final isDark      = AppState.instance.isDarkMode;
    final cardBg      = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textPrim    = isDark ? Colors.white : const Color(0xFF0F1F2A);
    final textSec     = isDark ? const Color(0xFF8E8E93) : Colors.black54;
    final divClr      = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA);
    final storePrice  = IAPService.instance.premiumProduct?.price ?? "29,99 RON";
    final safeBottom  = MediaQuery.of(context).padding.bottom;

    return Material(
      type: MaterialType.transparency,
      child: FadeTransition(
        opacity: _fade,
        child: GestureDetector(
          onTap: _dismiss, // tap outside sheet → dismiss
          child: Container(
            color: Colors.black.withOpacity(0.55),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {}, // absorb taps inside sheet
                child: SlideTransition(
                  position: _slide,
                  child: Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + safeBottom),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: divClr,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),

                      // header row
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: kAccent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: kAccent.withOpacity(0.22)),
                            ),
                            child: const Icon(Icons.star_rounded,
                                color: kAccent, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Trasee Premium",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: textPrim,
                                    height: 1.1,
                                  ),
                                ),
                                Text(
                                  "Ghidul tău digital pentru Oradea",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: textSec,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // X button
                          GestureDetector(
                            onTap: _dismiss,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF2C2C2E)
                                    : const Color(0xFFF2F2F7),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: isDark
                                    ? Colors.white60
                                    : Colors.black45,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // hero image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          "assets/images/premium_unlock1.png.webp",
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 150,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  kBrand.withOpacity(0.80),
                                  kBrand.withOpacity(0.35),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Center(
                              child: Icon(Icons.map_rounded,
                                  size: 52, color: Colors.white),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // benefits
                      _benefit(Icons.route_rounded,
                          "Trasee pe 1–5 zile cu hartă integrată",
                          isDark, textPrim),
                      const SizedBox(height: 8),
                      _benefit(Icons.check_circle_rounded,
                          "Bifează obiectivele pe măsură ce le vizitezi",
                          isDark, textPrim),
                      const SizedBox(height: 8),
                      _benefit(Icons.lock_open_rounded,
                          "O singură plată • Acces permanent",
                          isDark, textPrim),

                      const SizedBox(height: 18),

                      // price row
                      Row(
                        children: [
                          Text(
                            storePrice,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: textPrim,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: kAccent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                  color: kAccent.withOpacity(0.25)),
                            ),
                            child: const Text(
                              "O singură plată",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                                color: kAccent,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // CTA button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kBrand,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            _dismiss();
                            appNavigatorKey.currentState?.push(
                              MaterialPageRoute(
                                builder: (_) => const PremiumUnlockPage(),
                              ),
                            );
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.explore_rounded,
                                  color: Colors.white, size: 20),
                              SizedBox(width: 10),
                              Text(
                                "Descoperă Premium",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // dismiss link
                      GestureDetector(
                        onTap: _dismiss,
                        child: Text(
                          "Poate mai târziu",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: textSec,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),  // Material
    );
  }

  Widget _benefit(
      IconData icon, String text, bool isDark, Color textPrim) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: kBrand.withOpacity(0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: kBrand),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.2,
              fontWeight: FontWeight.w600,
              color: textPrim,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
