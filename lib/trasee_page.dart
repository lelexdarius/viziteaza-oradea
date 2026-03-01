import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:viziteaza_oradea/home.dart';
import 'package:viziteaza_oradea/premium_unlock_page.dart';
import 'services/iap_service.dart';
import 'package:viziteaza_oradea/services/app_state.dart';
import 'package:viziteaza_oradea/traseu_multiday_page.dart';

class TraseePage extends StatefulWidget {
  const TraseePage({Key? key}) : super(key: key);

  @override
  State<TraseePage> createState() => _TraseePageState();
}

class _TraseePageState extends State<TraseePage> {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bool premiumUnlocked = IAPService.instance.premiumUnlocked;

    return Scaffold(
      backgroundColor: AppState.instance.isDarkMode ? Colors.black : Colors.white,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // BACKGROUND
          Positioned.fill(
            child: Image.asset(
              "assets/images/trasee_oradea.png",
              fit: BoxFit.cover,
            ),
          ),

          // DARK OVERLAY
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.35),
            ),
          ),

          // 🔙 BUTON BACK MIC
          Positioned(
            top: top + 14,
            left: 14,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => HomePage(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // 🔥 CARDUL ALB (FĂRĂ HEIGHT FIX, FĂRĂ BARĂ JOS)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomCard(context, premiumUnlocked),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🔥 CARDUL DE JOS — SE MĂREȘTE NATURAL (NO MORE WHITE BAR)
  // ============================================================
  Widget _buildBottomCard(BuildContext context, bool premiumUnlocked) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 30, 22, 30),
      constraints: const BoxConstraints(minHeight: 350), // 🔥 FĂRĂ height FIX
      decoration: BoxDecoration(
        color: AppState.instance.isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(34),
          topRight: Radius.circular(34),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Alege durata traseului",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppState.instance.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),

          const SizedBox(height: 22),

          // LISTA ZILELOR — se întinde fără spațiu gol
          Flexible(
            child: ListView(
              padding: EdgeInsets.zero,
              children: _buildDayButtons(context, premiumUnlocked),
              shrinkWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LISTA ZILELOR
  // ============================================================
  List<Widget> _buildDayButtons(
    BuildContext context,
    bool premiumUnlocked,
  ) {
    final zile = [1, 2, 3, 4, 5];

    return zile.map((zi) {
      final locked = zi >= 3 && !premiumUnlocked;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () {
            if (locked) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PremiumUnlockPage(),
                ),
              ).then((_) => setState(() {}));
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TraseuMultiDayPage(totalDays: zi),
              ),
            );
          },
          child: _dayCard(zi, locked),
        ),
      );
    }).toList();
  }

  // ============================================================
  // CARD ZI
  // ============================================================
  Widget _dayCard(int zi, bool locked) {
    final isDark = AppState.instance.isDarkMode;
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isDark
                ? (locked ? const Color(0xFF2C2C2E) : const Color(0xFF1C1C1E))
                : (locked ? const Color(0xFFE8E3DC) : const Color(0xFFF6F6F6)),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF3A3A3C)
                  : (locked ? const Color(0xFFC7BFB6) : const Color(0xFFDDDDDD)),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(locked ? 0.15 : 0.08),
                blurRadius: locked ? 14 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: locked
                  ? const Color(0xFF6A5F52)
                  : (isDark ? const Color(0xFF004E64) : Colors.black87),
              child: locked
                  ? const Icon(Icons.lock, color: Colors.white, size: 20)
                  : Text(
                      "$zi",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            title: Text(
              "Traseu de $zi zi${zi == 1 ? '' : 'le'}",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? Colors.white
                    : (locked ? const Color(0xFF443C34) : Colors.black87),
              ),
            ),
            subtitle: Text(
              locked
                  ? "Premium — Itinerariu extins"
                  : "Disponibil — Descoperă orașul",
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? Colors.white60
                    : (locked ? const Color(0xFF6D6257) : Colors.black54),
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: isDark
                  ? Colors.white38
                  : (locked ? const Color(0xFF776B5E) : Colors.grey.shade700),
            ),
          ),
        ),

        // BADGE GRATIS
        if (!locked && zi <= 2)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: const Text(
                "GRATIS",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        // BADGE PREMIUM
        if (locked)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: const BoxDecoration(
                color: Color(0xFF6A5F52),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: const Text(
                "PREMIUM",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
