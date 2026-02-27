import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'services/iap_service.dart';

// 🔹 Pagini
import 'home.dart';
import 'evenimente_page.dart';
import 'galerie_page.dart';
import 'ajutor_page.dart';
import 'traseu_multiday_page.dart';

// 🔹 Footer
import 'widgets/custom_footer.dart';

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

  // ✅ IMPORTANT pentru IAP:
  // - init înainte de runApp ca PremiumUnlockPage să poată avea product/price
  // - include restore automat în IAPService (din versiunea pe care ți-am dat-o)
  try {
    await IAPService.instance.init();
  } catch (e) {
    // ignore: avoid_print
    print("Eroare IAP init: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vizitează Oradea',

      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),

      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaleFactor: 1.0,
            boldText: false,
          ),
          child: child!,
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
