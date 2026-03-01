import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:ui';

// ✅ NEW: tutorial doar la prima deschidere
import 'package:shared_preferences/shared_preferences.dart';

import 'services/app_state.dart';
import 'l10n/app_strings.dart';
import 'utils/app_theme.dart';

// paginile tale existente
import 'package:viziteaza_oradea/biserici_page.dart';
import 'package:viziteaza_oradea/cafenele_page.dart';
import 'package:viziteaza_oradea/catedrale_page.dart';
import 'package:viziteaza_oradea/distractii_page.dart';
import 'package:viziteaza_oradea/faq_page.dart';
import 'package:viziteaza_oradea/galerie_page.dart';
import 'package:viziteaza_oradea/muzee_page.dart';
import 'package:viziteaza_oradea/restaurante_page.dart';
import 'package:viziteaza_oradea/stranduri_page.dart';
import 'package:viziteaza_oradea/fast_food_page.dart';
import 'package:viziteaza_oradea/trasee_page.dart';

import 'evenimente_page.dart';
import 'filarmonica_page.dart';
import 'package:viziteaza_oradea/teatru_page.dart';
import 'widgets/custom_footer.dart';
import 'favorite_page.dart';

// ✅ NEW: paginile cerute în secțiunea "Termeni"
import 'package:viziteaza_oradea/ajutor_page.dart';
import 'package:viziteaza_oradea/termeni_page.dart';

// ✅ premium
import 'package:viziteaza_oradea/services/iap_service.dart';
import 'package:viziteaza_oradea/traseu_multiday_page.dart';
import 'package:viziteaza_oradea/models/restaurant_model.dart';
import 'package:viziteaza_oradea/cafenea_detalii_page.dart';
import 'package:viziteaza_oradea/restaurant_detalii_page.dart';
import 'package:viziteaza_oradea/fast_food_detalii_page.dart';
import 'package:viziteaza_oradea/muzeu_detalii_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:viziteaza_oradea/widgets/category_map_preview.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // -------------------------------------------------------------
  // ✅ Theme constants (păstrează culorile tale)
  // -------------------------------------------------------------
  static const Color kBrand = Color(0xFF004E64);
  static const Color kBg = Color(0xFFE8F1F4);

  // -------------------------------------------------------------
  // ✅ Scroll controller (îl păstrăm, chiar dacă header-ul e vizibil din start)
  // -------------------------------------------------------------
  final ScrollController _scrollController = ScrollController();

  // =============================================================
  // ✅ NEW: Tutorial BASIC (fără interacțiuni complicate)
  //  - 4 pași FIX: footer -> meniu -> data -> trasee
  //  - apare doar prima dată după instalare
  // =============================================================
  static const String _kTutorialSeenKey = 'home_basic_tutorial_seen_v1';
  bool _showTutorial = false;
  int _tutorialStep = 0;

  // Ținte pentru highlight (doar ca să arate frumos; tutorialul nu depinde de ele)
  final GlobalKey _kFooter = GlobalKey();
  final GlobalKey _kMenuButton = GlobalKey();
  final GlobalKey _kDatePill = GlobalKey();
  final GlobalKey _kTraseeCard = GlobalKey();

  @override
  void initState() {
    super.initState();
    _maybeShowTutorialFirstRun();
    AppState.instance.addListener(_onAppStateChanged);
  }

  void _onAppStateChanged() => setState(() {});

  Future<void> _maybeShowTutorialFirstRun() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getBool(_kTutorialSeenKey) ?? false;
      if (seen) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _showTutorial = true;
          _tutorialStep = 0;
        });
      });
    } catch (_) {
      // dacă nu merge prefs, nu stricăm app-ul
    }
  }

  Future<void> _markTutorialSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kTutorialSeenKey, true);
    } catch (_) {}
  }

  void _tutorialNext() {
    if (!_showTutorial) return;
    if (_tutorialStep >= 3) {
      _tutorialClose();
      return;
    }
    setState(() => _tutorialStep++);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  void _tutorialBack() {
    if (!_showTutorial) return;
    if (_tutorialStep <= 0) return;
    setState(() => _tutorialStep--);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  void _tutorialClose() {
    if (!_showTutorial) return;
    setState(() => _showTutorial = false);
    _markTutorialSeen();
  }

  Rect? _rectForKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final ro = ctx.findRenderObject();
    if (ro is! RenderBox) return null;
    final pos = ro.localToGlobal(Offset.zero);
    return pos & ro.size;
  }

  Rect? _tutorialTargetRect() {
    switch (_tutorialStep) {
      case 0:
        return _rectForKey(_kFooter);
      case 1:
        return _rectForKey(_kMenuButton);
      case 2:
        return _rectForKey(_kDatePill);
      case 3:
        return _rectForKey(_kTraseeCard);
      default:
        return null;
    }
  }

  String _tutorialText() {
    // EXACT ce ai cerut, în limbaj pentru clienți
    switch (_tutorialStep) {
      case 0:
        return "În partea de jos se află meniul. Puteți naviga mereu spre casă, la pagina de evenimente, Galerie, Trasee, sau Ajutor, unde ne puteți contacta oricând pentru orice nelămurire. ";
      case 1:
        return "În stânga găsiți meniul principal, unde se află toate paginile de care aveți nevoie. Aici veți găsi: toate restaurantele si cafenelele din oraș( plus recomandări din partea noastră ), scene de teatru si filarmonică săptămânale, muzee, catedrale, ștranduri, galerie poze Oradea, evenimente, Biserici etc.";
      case 2:
        return "Sus se află data în care ne aflăm azi, pentru a vă sincroniza rapid cu programele la Teatru, Filarmonica, sau eveniementele locale.";
      case 3:
        return "Pentru ghidul turistic digital, accesați pagina „Trasee\", apăsând aici, sau din meniul Principal. \n \n Distracție plăcută în Oradea!";
      default:
        return "";
    }
  }

  // -------------------------------------------------------------
  // ✅ SINGLE SOURCE: deschide Trasee doar dacă user are Premium
  // -------------------------------------------------------------
  Future<void> _openTraseePremium(BuildContext context) async {
    // ✅ Închide drawer DOAR dacă este deschis (NU mai folosim canPop)
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold != null && scaffold.isDrawerOpen) {
      Navigator.pop(context); // închide drawer
    }

    final ok = await IAPService.instance.ensurePremium(context);
    if (!ok) return;
    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const TraseuMultiDayPage(totalDays: 5),
      ),
    );
  }

  void _openFromHome(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_onAppStateChanged);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat("d MMMM", "ro_RO").format(DateTime.now());
    final topSafe = MediaQuery.of(context).padding.top;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        extendBodyBehindAppBar: true,
        extendBody: true,

        // =========================================================
        // DRAWER (păstrat) + ✅ butoane puțin mai mici
        // =========================================================
        drawer: SizedBox(
          width: MediaQuery.of(context).size.width * 0.80,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Drawer(
                backgroundColor: AppTheme.drawerBg(context),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // 🔹 HEADER MENIU (mai modern)
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(32),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              kBrand.withOpacity(0.16),
                              Colors.white.withOpacity(0.08),
                            ],
                          ),
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white.withOpacity(0.35),
                              width: 1,
                            ),
                          ),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              20,
                              topSafe + 46,
                              20,
                              22,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                Text(
                                  "Tour Oradea",
                                  style: TextStyle(
                                    color: AppState.instance.isDarkMode
                                        ? Colors.white
                                        : kBrand,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  S.of('explore'),
                                  style: TextStyle(
                                    color: AppState.instance.isDarkMode
                                        ? Colors.white.withOpacity(0.70)
                                        : kBrand.withOpacity(0.90),
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w500,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    _buildDarkModeToggle(context),
                    const SizedBox(height: 4),
                    _buildCategoryHeader(S.of('menu_suggestions')),
                    _buildMenuItem(
                      context,
                      title: S.of('photos'),
                      icon: Icons.photo_library_outlined,
                      destination: GaleriePage(),
                    ),
                    _buildMenuItem(
                      context,
                      title: S.of('favorites'),
                      icon: Icons.favorite_border,
                      destination: const FavoritePage(),
                    ),

                    // ⭐️ Trasee = Premium gate
                    _buildMenuItem(
                      context,
                      title: S.of('routes'),
                      icon: Icons.route_outlined,
                      destination: const TraseePage(),
                      premiumGlow: true,
                      onTap: () => _openTraseePremium(context),
                    ),

                    _buildCategoryHeader(S.of('menu_food')),
                    _buildMenuItem(
                      context,
                      title: S.of('cafenele'),
                      icon: Icons.local_cafe_outlined,
                      destination: CafenelePage(),
                    ),
                    _buildMenuItem(
                      context,
                      title: S.of('restaurante'),
                      icon: Icons.restaurant_outlined,
                      destination: RestaurantePage(),
                    ),
                    _buildMenuItem(
                      context,
                      title: S.of('fastfood'),
                      icon: Icons.fastfood_outlined,
                      destination: FastFoodPage(),
                    ),

                    _buildCategoryHeader(S.of('menu_activities')),
                     _buildMenuItem(
                      context,
                      title: S.of('evenimente'),
                      icon: Icons.event_outlined,
                      destination: EvenimentePage(),
                    ),
                    _buildMenuItem(
                      context,
                      title: S.of('teatru'),
                      icon: Icons.theater_comedy_outlined,
                      destination: const TeatruPage(),
                    ),
                    _buildMenuItem(
                      context,
                      title: S.of('filarmonica'),
                      icon: Icons.music_note_outlined,
                      destination: FilarmonicaPage(),
                    ),
                    _buildMenuItem(
                      context,
                      title: S.of('stranduri'),
                      icon: Icons.pool_outlined,
                      destination: const StranduriPage(),
                    ),
                   
                    _buildMenuItem(
                      context,
                      title: S.of('distractii'),
                      icon: Icons.celebration_outlined,
                      destination: DistractiiPage(),
                    ),

                    _buildCategoryHeader(S.of('menu_culture')),
                    _buildMenuItem(
                      context,
                      title: S.of('muzee'),
                      icon: Icons.museum_outlined,
                      destination: MuzeePage(),
                    ),
                    _buildMenuItem(
                      context,
                      title: S.of('churches'),
                      icon: Icons.church_outlined,
                      destination: BisericiPage(),
                    ),
                    _buildMenuItem(
                      context,
                      title: S.of('cathedrals'),
                      icon: Icons.account_balance_outlined,
                      destination: CatedralePage(),
                    ),

                    _buildCategoryHeader(S.of('menu_contact')),
                    _buildMenuItem(
                      context,
                      title: S.of('nav_help'),
                      icon: Icons.help_outline,
                      destination: const AjutorPage(),
                    ),
                    _buildMenuItem(
                      context,
                      title: S.of('faq'),
                      icon: Icons.question_answer_outlined,
                      destination: const FAQPage(),
                    ),
                    _buildMenuItem(
                      context,
                      title: S.of('terms'),
                      icon: Icons.gavel_outlined,
                      destination: const TermeniPage(),
                    ),

                    const SizedBox(height: 18),
                    ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(vertical: -4),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 2,
                      ),
                      minVerticalPadding: 0,
                      leading: Icon(
                        Icons.info_outline,
                        color: AppTheme.textSecondary(context),
                      ),
                      title: Text(
                        S.of('about'),
                        style: TextStyle(color: AppTheme.textPrimary(context)),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FAQPage()),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),

        // =========================================================
        // BODY (Stack)
        // =========================================================
        body: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(
                  16,
                  topSafe + 64, // ✅ spațiu ca să nu intre sub header-ul de sus
                  16,
                  18 + 90,
                ),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of('welcome'),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary(context),
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      S.of('tagline'),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15.5,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary(context),
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg(context).withOpacity(0.85),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kBrand.withOpacity(0.10)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: kBrand,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.info_outline_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              S.of('tourist_banner'),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary(context).withOpacity(0.78),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    const FirestoreHeaderImage(),

                    const SizedBox(height: 14),

                    const _HomeMapSection(),

                    const SizedBox(height: 16),

                    const SizedBox(height: 2),

                    Text(
                      S.of('most_popular'),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 10),

                    _QuickActionsGrid(
                      brandColor: kBrand,
                      items: [
                        _QuickActionItem(
                          icon: Icons.local_cafe_rounded,
                          label: S.of('cafenele'),
                          onTap: () => _openFromHome(context, CafenelePage()),
                        ),
                        _QuickActionItem(
                          icon: Icons.restaurant_rounded,
                          label: S.of('restaurante'),
                          onTap: () =>
                              _openFromHome(context, RestaurantePage()),
                        ),
                        _QuickActionItem(
                          icon: Icons.photo_library_rounded,
                          label: S.of('photos'),
                          onTap: () => _openFromHome(context, GaleriePage()),
                        ),
                        _QuickActionItem(
                          icon: Icons.theater_comedy_rounded,
                          label: S.of('teatru'),
                          onTap: () =>
                              _openFromHome(context, const TeatruPage()),
                        ),
                        _QuickActionItem(
                          icon: Icons.event_rounded,
                          label: S.of('evenimente'),
                          onTap: () => _openFromHome(context, EvenimentePage()),
                        ),
                        _QuickActionItem(
                          icon: Icons.museum_rounded,
                          label: S.of('muzee'),
                          onTap: () => _openFromHome(context, MuzeePage()),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 6),
                      child: Center(
                        child: Text(
                          S.of('copyright'),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),

            // =========================================================
            // ✅ HEADER FIX (vizibil din start)
            // =========================================================
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(left: 6, right: 12, top: 6),
                  child: Row(
                    children: [
                      Builder(
                        builder: (context) => _iconPillButton(
                          key: _kMenuButton, // ✅ tutorial target
                          icon: Icons.segment,
                          onTap: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            key: _kDatePill, // ✅ tutorial target
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.isDarkGlobal ? Colors.black : AppTheme.cardBg(context).withOpacity(0.90),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: AppTheme.isDarkGlobal ? Colors.white : Colors.white.withOpacity(0.55),
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
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.isDarkGlobal ? Colors.white : kBrand,
                                ),
                                children: [
                                  TextSpan(text: "${S.of('today')} • "),
                                  TextSpan(
                                    text: formattedDate,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.isDarkGlobal ? Colors.white : kBrand,
                                    ),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const SizedBox(width: 42), // language button hidden for now
                    ],
                  ),
                ),
              ),
            ),

            // ✅ FOOTER "floating"
            Align(
              alignment: Alignment.bottomCenter,
              child: KeyedSubtree(
                key: _kFooter, // ✅ tutorial target
                child: const CustomFooter(isHome: true),
              ),
            ),

            // =========================================================
            // ✅ NEW: Tutorial BASIC overlay
            // =========================================================
            if (_showTutorial)
              _BasicTutorialOverlay(
                targetRect: _tutorialTargetRect(),
                text: _tutorialText(),
                brand: kBrand,
                step: _tutorialStep,
                isLast: _tutorialStep == 3,
                onNext: _tutorialNext,
                onBack: _tutorialBack,
                onClose: _tutorialClose,
              ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // UI helpers
  // =============================================================

  Widget _langPillButton(BuildContext context) {
    final lang = AppState.instance.language.toUpperCase();
    final isDark = AppState.instance.isDarkMode;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: isDark ? Colors.black : Colors.white.withOpacity(0.35),
          child: InkWell(
            onTap: () => AppState.instance.toggleLanguage(),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isDark ? Colors.white : Colors.white.withOpacity(0.6),
                ),
              ),
              child: Center(
                child: Text(
                  lang,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : kBrand,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDarkModeToggle(BuildContext context) {
    final isDark = AppState.instance.isDarkMode;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context).withOpacity(0.94),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBrand.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 12,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: kBrand,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDark ? Icons.nightlight_round : Icons.wb_sunny_outlined,
              size: 17,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              S.of('dark_mode'),
              style: TextStyle(
                fontSize: 14.6,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          CupertinoSwitch(
            value: isDark,
            activeColor: kBrand,
            onChanged: (val) => AppState.instance.setDarkMode(val),
          ),
        ],
      ),
    );
  }

  Widget _iconPillButton({
    Key? key,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = AppState.instance.isDarkMode;
    return ClipRRect(
      key: key,
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: isDark ? Colors.black : Colors.white.withOpacity(0.35),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isDark ? Colors.white : Colors.white.withOpacity(0.6),
                ),
              ),
              child: Icon(icon, color: isDark ? Colors.white : kBrand, size: 22),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Helper Widgets ----------
  static Widget _buildCategoryHeader(String title) {
    final isDark = AppState.instance.isDarkMode;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12.0,
          letterSpacing: 0.9,
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white.withOpacity(0.55) : kBrand.withOpacity(0.75),
        ),
      ),
    );
  }

  static Widget _buildMenuItem(
    BuildContext context, {
    Key? key, // ✅ NEW (nu schimbă funcționalitatea)
    required String title,
    required IconData icon,
    required Widget destination,
    bool premiumGlow = false,
    VoidCallback? onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.82, end: 1.0),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            key: key,
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.94),
              borderRadius: BorderRadius.circular(14),
              border: premiumGlow
                  ? Border.all(
                      color: const Color(0xFFFFC800).withOpacity(0.90),
                      width: 1.6,
                    )
                  : Border.all(color: kBrand.withOpacity(0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.045),
                  blurRadius: 12,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: ListTile(
        dense: true,
        visualDensity: const VisualDensity(vertical: -1.2),
        minLeadingWidth: 20,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: premiumGlow ? const Color(0xFFFFC800) : kBrand,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 17,
            color: Colors.white,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.6,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary(context),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: 20,
          color: AppTheme.textSecondary(context),
        ),
        onTap: onTap ??
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => destination),
              );
            },
      ),
    );
  }
}

// ===============================================================
// ✅ NEW: Overlay simplu + highlight (BASIC, robust)
//   - Nu blochează aplicația
//   - Cardul se mută sus dacă ținta e jos (ex: footer)
// ===============================================================
class _BasicTutorialOverlay extends StatelessWidget {
  final Rect? targetRect;
  final String text;
  final Color brand;
  final int step;
  final bool isLast;

  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onClose;

  const _BasicTutorialOverlay({
    required this.targetRect,
    required this.text,
    required this.brand,
    required this.step,
    required this.isLast,
    required this.onNext,
    required this.onBack,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final safeTop = media.padding.top;
    final safeBottom = media.padding.bottom;

    final rect = targetRect;
    final bool targetIsBottom =
        rect != null ? rect.center.dy > size.height * 0.60 : true;

    return Positioned.fill(
      child: Stack(
        children: [
          // fundal + gaură, dar NU blocăm interacțiunea (IgnorePointer)
          IgnorePointer(
            ignoring: true,
            child: ClipPath(
              clipper: _SpotlightClipper(
                rect: rect,
                padding: 10,
                radius: 18,
              ),
              child: Container(color: Colors.black.withOpacity(0.60)),
            ),
          ),

          Positioned(
            left: 14,
            right: 14,
            top: targetIsBottom ? safeTop + 10 : null,
            bottom: targetIsBottom ? null : 12 + safeBottom,
            child: Material(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: brand.withOpacity(0.16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: brand,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.info_outline_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Ghid rapid (${step + 1}/4)",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14.8,
                              fontWeight: FontWeight.w800,
                              color: Colors.black.withOpacity(0.86),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: onClose,
                          child: Text(
                            "Închide",
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.55),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        text,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.3,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withOpacity(0.78),
                          height: 1.35,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (step > 0)
                          _pill(
                            label: "Înapoi",
                            onTap: onBack,
                            filled: false,
                            brand: brand,
                          ),
                        if (step > 0) const SizedBox(width: 10),
                        Expanded(child: Container()),
                        _pill(
                          label: isLast ? "Gata" : "Continuă",
                          onTap: onNext,
                          filled: true,
                          brand: brand,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill({
    required String label,
    required VoidCallback onTap,
    required bool filled,
    required Color brand,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: filled ? brand : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: brand.withOpacity(filled ? 0.0 : 0.25)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13.5,
            fontWeight: FontWeight.w900,
            color: filled ? Colors.white : brand,
          ),
        ),
      ),
    );
  }
}

class _SpotlightClipper extends CustomClipper<Path> {
  final Rect? rect;
  final double padding;
  final double radius;

  _SpotlightClipper({
    required this.rect,
    required this.padding,
    required this.radius,
  });

  @override
  Path getClip(Size size) {
    final full = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    if (rect == null) return full;

    final r = rect!.inflate(padding);
    final hole = Path()
      ..addRRect(
        RRect.fromRectAndRadius(r, Radius.circular(radius)),
      );

    return Path.combine(PathOperation.difference, full, hole);
  }

  @override
  bool shouldReclip(covariant _SpotlightClipper oldClipper) {
    return oldClipper.rect != rect ||
        oldClipper.padding != padding ||
        oldClipper.radius != radius;
  }
}

// ===============================================================
// ✅ Secțiune "Cele mai accesate" (grid modern)
// ===============================================================
class _QuickActionsGrid extends StatelessWidget {
  final List<_QuickActionItem> items;
  final Color brandColor;

  const _QuickActionsGrid({
    required this.items,
    required this.brandColor,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      primary: false,
      padding: EdgeInsets.zero,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.06,
      children: items.map((it) {
        return _QuickActionTile(
          item: it,
          brandColor: brandColor,
        );
      }).toList(),
    );
  }
}

class _QuickActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _QuickActionTile extends StatelessWidget {
  final _QuickActionItem item;
  final Color brandColor;

  const _QuickActionTile({
    required this.item,
    required this.brandColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDarkGlobal;
    final iconContainerColor = isDark
        ? Colors.white.withOpacity(0.15)
        : brandColor.withOpacity(0.10);
    final iconColor = isDark ? Colors.white : brandColor;

    return Material(
      color: Theme.of(context).cardColor.withOpacity(0.92),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: item.onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: brandColor.withOpacity(0.10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 14,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconContainerColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  item.icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary(context),
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// Card modern reutilizabil (CTA NU mai trece peste text)
// ===============================================================
class _ModernFeatureCard extends StatelessWidget {
  final double height;
  final String imagePath;
  final String title;
  final String subtitle;
  final String cta;
  final Color brandColor;
  final bool lightCta;
  final VoidCallback onTap;

  final String? badgeText;
  final Color? badgeColor;

  const _ModernFeatureCard({
    required this.height,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.brandColor,
    required this.onTap,
    this.lightCta = false,
    this.badgeText,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.14),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(imagePath, fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.74),
                      Colors.black.withOpacity(0.30),
                      brandColor.withOpacity(0.12),
                    ],
                    stops: const [0.0, 0.58, 1.0],
                  ),
                ),
              ),
              if (badgeText != null)
                Positioned(
                  left: 14,
                  top: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? brandColor).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          badgeText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.12,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.92),
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ctaPill(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ctaPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: lightCta
            ? Colors.white.withOpacity(0.92)
            : brandColor.withOpacity(0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withOpacity(lightCta ? 0.9 : 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            cta,
            style: TextStyle(
              color: lightCta ? brandColor : Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_rounded,
            size: 18,
            color: lightCta ? brandColor : Colors.white,
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// Secțiunea hartă compactă + full-screen
// ===============================================================
class _HomeMapSection extends StatefulWidget {
  const _HomeMapSection();

  @override
  State<_HomeMapSection> createState() => _HomeMapSectionState();
}

class _HomeMapSectionState extends State<_HomeMapSection> {
  static const Color kBrand = Color(0xFF004E64);

  Set<Marker> _markers = {};
  BitmapDescriptor? _cafeIcon;
  BitmapDescriptor? _restIcon;
  BitmapDescriptor? _ffIcon;
  BitmapDescriptor? _muzIcon;
  bool _iconsReady = false;
  GoogleMapController? _mapController;

  List<QueryDocumentSnapshot> _cafeDocs = [];
  List<QueryDocumentSnapshot> _restDocs = [];
  List<QueryDocumentSnapshot> _ffDocs = [];
  List<QueryDocumentSnapshot> _muzDocs = [];
  final List<StreamSubscription<QuerySnapshot>> _subs = [];

  @override
  void initState() {
    super.initState();
    _buildIconsThenSubscribe();
    AppState.instance.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    if (_mapController != null) AppTheme.applyMapStyle(_mapController!);
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_onThemeChanged);
    for (final s in _subs) s.cancel();
    super.dispose();
  }

  Future<void> _buildIconsThenSubscribe() async {
    _cafeIcon = await buildCircleMarkerIcon(Icons.local_cafe, const Color(0xFF1565C0), size: 80);
    _restIcon = await buildCircleMarkerIcon(Icons.restaurant, const Color(0xFFD84315), size: 80);
    _ffIcon   = await buildCircleMarkerIcon(Icons.fastfood, const Color(0xFFF57F17), size: 80);
    _muzIcon  = await buildCircleMarkerIcon(Icons.museum, const Color(0xFF6A1B9A), size: 80);
    if (!mounted) return;
    setState(() => _iconsReady = true);
    _subscribeToStreams();
  }

  void _subscribeToStreams() {
    final db = FirebaseFirestore.instance;
    _subs.add(db.collection('cafenele').snapshots().listen((snap) {
      _cafeDocs = snap.docs;
      _rebuildMarkers();
    }));
    _subs.add(db.collection('restaurante').snapshots().listen((snap) {
      _restDocs = snap.docs;
      _rebuildMarkers();
    }));
    _subs.add(db.collection('fast_food').snapshots().listen((snap) {
      _ffDocs = snap.docs;
      _rebuildMarkers();
    }));
    _subs.add(db.collection('muzee').snapshots().listen((snap) {
      _muzDocs = snap.docs;
      _rebuildMarkers();
    }));
  }

  void _rebuildMarkers() {
    if (!_iconsReady) return;
    final markers = <Marker>{};
    int id = 0;

    // GeoPoint-based collections (cafenele, restaurante, fast_food)
    void addGeoPointDocs(
      List<QueryDocumentSnapshot> docs,
      BitmapDescriptor icon,
      String prefix,
    ) {
      for (final doc in docs) {
        final data = doc.data() as Map<String, dynamic>;
        final locs = data['locations'];
        final title = data['title']?.toString() ?? '';
        final List<LatLng> points = [];
        if (locs is List) {
          for (final l in locs) {
            if (l is GeoPoint) points.add(LatLng(l.latitude, l.longitude));
          }
        } else if (locs is GeoPoint) {
          points.add(LatLng(locs.latitude, locs.longitude));
        }
        for (final p in points) {
          markers.add(Marker(
            markerId: MarkerId('${prefix}_${id++}'),
            position: p,
            icon: icon,
            infoWindow: InfoWindow(title: title),
          ));
        }
      }
    }

    addGeoPointDocs(_cafeDocs, _cafeIcon!, 'cafe');
    addGeoPointDocs(_restDocs, _restIcon!, 'rest');
    addGeoPointDocs(_ffDocs, _ffIcon!, 'ff');

    // Muzee use separate latitude/longitude numeric fields
    for (final doc in _muzDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final lat = (data['latitude'] is num) ? (data['latitude'] as num).toDouble() : null;
      final lng = (data['longitude'] is num) ? (data['longitude'] as num).toDouble() : null;
      if (lat != null && lng != null) {
        markers.add(Marker(
          markerId: MarkerId('muz_${id++}'),
          position: LatLng(lat, lng),
          icon: _muzIcon!,
          infoWindow: InfoWindow(title: data['title']?.toString() ?? 'Muzeu'),
        ));
      }
    }

    if (mounted) setState(() => _markers = markers);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Harta orașului",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary(context),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const _FullScreenMapPage(),
                fullscreenDialog: true,
              ),
            );
          },
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  AbsorbPointer(
                    child: GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(47.0722, 21.9217),
                        zoom: 13,
                      ),
                      markers: _markers,
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                      compassEnabled: false,
                      mapToolbarEnabled: false,
                      onMapCreated: (controller) {
                        _mapController = controller;
                        AppTheme.applyMapStyle(controller);
                      },
                    ),
                  ),
                  if (!_iconsReady)
                    const Center(child: CircularProgressIndicator()),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: kBrand.withOpacity(0.90),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.fullscreen, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            "Extinde harta",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FullScreenMapPage extends StatefulWidget {
  const _FullScreenMapPage();

  @override
  State<_FullScreenMapPage> createState() => _FullScreenMapPageState();
}

class _FullScreenMapPageState extends State<_FullScreenMapPage> {
  static const Color kBrand = Color(0xFF004E64);
  Set<Marker> _markers = {};
  bool _iconsReady = false;
  bool _isLoading = true;
  Position? _userPosition;
  bool _locationEnabled = false;
  String? _activeFilter; // null = all, 'cafe' | 'rest' | 'ff' | 'muz'

  BitmapDescriptor? _cafeIcon;
  BitmapDescriptor? _restIcon;
  BitmapDescriptor? _ffIcon;
  BitmapDescriptor? _muzIcon;

  List<QueryDocumentSnapshot> _cafeDocs = [];
  List<QueryDocumentSnapshot> _restDocs = [];
  List<QueryDocumentSnapshot> _ffDocs = [];
  List<QueryDocumentSnapshot> _muzDocs = [];
  final List<StreamSubscription<QuerySnapshot>> _subs = [];

  @override
  void initState() {
    super.initState();
    _initLocationAndMarkers();
    _maybeShowFilterHint();
  }

  @override
  void dispose() {
    for (final s in _subs) s.cancel();
    super.dispose();
  }

  Future<void> _maybeShowFilterHint() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('map_filter_hint_shown') ?? false) return;
    await prefs.setBool('map_filter_hint_shown', true);
    // Wait for the map to render before showing the dialog
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        backgroundColor: const Color(0xFF004E64),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.filter_list_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(height: 16),
              const Text(
                "Filtrează harta",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Apasă pe una din categoriile din stânga sus pentru a vedea doar locațiile dorite!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.5,
                  height: 1.55,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF004E64),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Am înțeles!",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF004E64),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _initLocationAndMarkers() async {
    // Request location
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 6),
        );
        if (mounted) {
          setState(() {
            _userPosition = pos;
            _locationEnabled = true;
          });
        }
      }
    } catch (_) {}

    // Build custom marker icons
    _cafeIcon = await buildCircleMarkerIcon(Icons.local_cafe, const Color(0xFF1565C0), size: 96);
    _restIcon = await buildCircleMarkerIcon(Icons.restaurant, const Color(0xFFD84315), size: 96);
    _ffIcon   = await buildCircleMarkerIcon(Icons.fastfood, const Color(0xFFF57F17), size: 96);
    _muzIcon  = await buildCircleMarkerIcon(Icons.museum, const Color(0xFF6A1B9A), size: 96);
    if (!mounted) return;
    setState(() { _iconsReady = true; _isLoading = false; });
    _subscribeToStreams();
  }

  String _distanceSnippet(double lat, double lng) {
    final pos = _userPosition;
    if (pos == null) return 'Atinge pentru detalii';
    final meters = Geolocator.distanceBetween(pos.latitude, pos.longitude, lat, lng);
    return meters < 1000
        ? '${meters.round()} m distanță • Atinge pentru detalii'
        : '${(meters / 1000).toStringAsFixed(1)} km distanță • Atinge pentru detalii';
  }

  void _subscribeToStreams() {
    final db = FirebaseFirestore.instance;
    _subs.add(db.collection('cafenele').snapshots().listen((snap) {
      _cafeDocs = snap.docs;
      _rebuildAllMarkers();
    }));
    _subs.add(db.collection('restaurante').snapshots().listen((snap) {
      _restDocs = snap.docs;
      _rebuildAllMarkers();
    }));
    _subs.add(db.collection('fast_food').snapshots().listen((snap) {
      _ffDocs = snap.docs;
      _rebuildAllMarkers();
    }));
    _subs.add(db.collection('muzee').snapshots().listen((snap) {
      _muzDocs = snap.docs;
      _rebuildAllMarkers();
    }));
  }

  void _rebuildAllMarkers() {
    if (!_iconsReady) return;
    final markers = <Marker>{};
    int id = 0;

    final f = _activeFilter;

    // ── Cafenele ──────────────────────────────────────────────────
    if (f == null || f == 'cafe') {
      for (final doc in _cafeDocs) {
        final cafe = Cafenea.fromFirestore(doc);
        for (final loc in cafe.locations ?? []) {
          final mid = 'cafe_${id++}';
          final snap = cafe;
          markers.add(Marker(
            markerId: MarkerId(mid),
            position: LatLng(loc.latitude, loc.longitude),
            icon: _cafeIcon!,
            infoWindow: InfoWindow(
              title: cafe.title,
              snippet: _distanceSnippet(loc.latitude, loc.longitude),
              onTap: () {
                if (!mounted) return;
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => CafeneaDetaliiPage(cafe: snap),
                ));
              },
            ),
          ));
        }
      }
    }

    // ── Restaurante ───────────────────────────────────────────────
    if (f == null || f == 'rest') {
      for (final doc in _restDocs) {
        final rest = Restaurant.fromFirestore(doc);
        for (final loc in rest.locations ?? []) {
          final mid = 'rest_${id++}';
          final snap = rest;
          markers.add(Marker(
            markerId: MarkerId(mid),
            position: LatLng(loc.latitude, loc.longitude),
            icon: _restIcon!,
            infoWindow: InfoWindow(
              title: rest.title,
              snippet: _distanceSnippet(loc.latitude, loc.longitude),
              onTap: () {
                if (!mounted) return;
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => RestaurantDetaliiPage(restaurant: snap),
                ));
              },
            ),
          ));
        }
      }
    }

    // ── Fast Food ─────────────────────────────────────────────────
    if (f == null || f == 'ff') {
      for (final doc in _ffDocs) {
        final ff = FastFood.fromFirestore(doc);
        for (final loc in ff.locations ?? []) {
          final mid = 'ff_${id++}';
          final snap = ff;
          markers.add(Marker(
            markerId: MarkerId(mid),
            position: LatLng(loc.latitude, loc.longitude),
            icon: _ffIcon!,
            infoWindow: InfoWindow(
              title: ff.title,
              snippet: _distanceSnippet(loc.latitude, loc.longitude),
              onTap: () {
                if (!mounted) return;
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => FastFoodDetaliiPage(fastfood: snap),
                ));
              },
            ),
          ));
        }
      }
    }

    // ── Muzee ─────────────────────────────────────────────────────
    if (f == null || f == 'muz') {
      for (final doc in _muzDocs) {
        final muz = Muzeu.fromFirestore(doc);
        if (muz.latitude != null && muz.longitude != null) {
          final mid = 'muz_${id++}';
          final snap = muz;
          markers.add(Marker(
            markerId: MarkerId(mid),
            position: LatLng(muz.latitude!, muz.longitude!),
            icon: _muzIcon!,
            infoWindow: InfoWindow(
              title: muz.title,
              snippet: _distanceSnippet(muz.latitude!, muz.longitude!),
              onTap: () {
                if (!mounted) return;
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => MuzeuDetaliiPage(muzeu: snap),
                ));
              },
            ),
          ));
        }
      }
    }

    if (mounted) setState(() => _markers = markers);
  }

  Widget _filterItem(String key, Color color, IconData icon, String label) {
    final isSelected = _activeFilter == key;
    final isActive   = _activeFilter == null || isSelected;
    return GestureDetector(
      onTap: () {
        _activeFilter = isSelected ? null : key;
        _rebuildAllMarkers();
      },
      child: AnimatedOpacity(
        opacity: isActive ? 1.0 : 0.35,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: isSelected
              ? const EdgeInsets.symmetric(horizontal: 6, vertical: 3)
              : const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
          decoration: isSelected
              ? BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.40)),
                )
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 13),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? color : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(47.0722, 21.9217),
              zoom: 14,
            ),
            markers: _markers,
            myLocationEnabled: _locationEnabled,
            myLocationButtonEnabled: _locationEnabled,
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
            onMapCreated: (controller) => AppTheme.applyMapStyle(controller),
          ),
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.6),
              child: const Center(
                child: CircularProgressIndicator(color: kBrand),
              ),
            ),
          // Buton X închidere
          Positioned(
            top: topPadding + 12,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.20),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.close, color: Colors.black87, size: 22),
              ),
            ),
          ),
          // Legendă / Filtre
          Positioned(
            top: topPadding + 12,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _filterItem('cafe', const Color(0xFF1565C0), Icons.local_cafe, "Cafenele"),
                  const SizedBox(height: 6),
                  _filterItem('rest', const Color(0xFFD84315), Icons.restaurant, "Restaurante"),
                  const SizedBox(height: 6),
                  _filterItem('ff',   const Color(0xFFF57F17), Icons.fastfood,   "Fast Food"),
                  const SizedBox(height: 6),
                  _filterItem('muz',  const Color(0xFF6A1B9A), Icons.museum,     "Muzee"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;

  const _LegendItem({required this.color, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 13),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

/// 🔹 Imagine principală din Firestore (înlocuiește caruselul)
class FirestoreHeaderImage extends StatelessWidget {
  const FirestoreHeaderImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: _HomePageState.kBrand.withOpacity(0.10)),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('homeImage')
                .limit(1)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 170,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: _HomePageState.kBrand,
                    ),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SizedBox(
                  height: 170,
                  child: Center(
                    child: Text(
                      "Imaginea principală nu este disponibilă momentan.",
                      style: TextStyle(color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final url = snapshot.data!.docs.first['imageUrl'] as String? ?? '';

              return CachedNetworkImage(imageUrl: 
                url,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 450,
                placeholder: (_, __) => Container(color: const Color(0xFFE8F1F4)),
                errorWidget: (_, __, ___) => const SizedBox(
                  height: 450,
                  child: Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 42,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
