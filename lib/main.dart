import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'services/iap_service.dart';
import 'services/app_state.dart';
import 'utils/app_theme.dart';
import 'widgets/premium_promo_popup.dart';

// 🔹 Pagini
import 'home.dart';
import 'evenimente_page.dart';
import 'galerie_page.dart';
import 'ajutor_page.dart';
import 'traseu_multiday_page.dart';

// 🔹 Footer
import 'widgets/custom_footer.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // ignore: avoid_print
    print("Eroare Firebase: $e");
  }

  // Orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Locale
  await initializeDateFormatting('ro_RO', null);

  // Widget pentru erori (păstrat)
  ErrorWidget.builder = (details) => Container(color: Colors.white);

  // Load persisted language + dark mode BEFORE runApp
  await AppState.instance.loadPreferences();

  // ✅ IMPORTANT pentru IAP:
  try {
    await IAPService.instance.init();
  } catch (e) {
    // ignore: avoid_print
    print("Eroare IAP init: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Timer? _promoTimer;
  bool _promoVisible = false;

  @override
  void initState() {
    super.initState();
    AppState.instance.addListener(_onAppStateChanged);
    _startPromoTimer();
  }

  void _startPromoTimer() {
    Timer(const Duration(seconds: 20), () {
      _triggerPromo();
      _promoTimer = Timer.periodic(
        const Duration(seconds: 90),
        (_) => _triggerPromo(),
      );
    });
  }

  void _triggerPromo() {
    if (!mounted) return;
    if (IAPService.instance.premiumUnlocked) return;
    setState(() => _promoVisible = true);
  }

  void _dismissPromo() {
    if (!mounted) return;
    setState(() => _promoVisible = false);
  }

  @override
  void dispose() {
    _promoTimer?.cancel();
    AppState.instance.removeListener(_onAppStateChanged);
    super.dispose();
  }

  void _onAppStateChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final isDark = AppState.instance.isDarkMode;

    return MaterialApp(
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Vizitează Oradea',

      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final scaled = MediaQuery(
          data: mediaQuery.copyWith(
            textScaleFactor: 1.0,
            boldText: false,
          ),
          child: child!,
        );
        return Stack(
          children: [
            scaled,
            if (_promoVisible)
              PremiumPromoOverlay(onDismiss: _dismissPromo),
          ],
        );
      },

      // ✅ IMPORTANT: folosim routes + initialRoute ca footerul să știe tabul activ
      initialRoute: CustomFooter.routeHome,
      routes: {
        CustomFooter.routeHome: (_) =>
            FooterBackInterceptor(child: HomePage()),

        CustomFooter.routeEvents: (_) =>
            FooterBackInterceptor(child: EvenimentePage()),

        CustomFooter.routeGallery: (_) =>
            FooterBackInterceptor(child: GaleriePage()),

        CustomFooter.routeHelp: (_) =>
            const FooterBackInterceptor(child: AjutorPage()),

        // Opțional: ruta directă către trasee (footerul oricum face premium gate)
        CustomFooter.routeRoutes: (_) => const FooterBackInterceptor(
              child: TraseuMultiDayPage(totalDays: 5),
            ),
      },
    );
  }
}
