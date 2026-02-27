import 'dart:ui';
import 'package:flutter/material.dart';

// 🔹 Pagini
import 'package:viziteaza_oradea/home.dart';
import 'package:viziteaza_oradea/ajutor_page.dart';
import 'package:viziteaza_oradea/galerie_page.dart';
import 'package:viziteaza_oradea/evenimente_page.dart';

// 🔹 Premium + trasee
import 'package:viziteaza_oradea/services/iap_service.dart';
import 'package:viziteaza_oradea/traseu_multiday_page.dart';
import 'package:viziteaza_oradea/premium_unlock_page.dart';

enum FooterTab { home, events, gallery, routes, help, other }

class CustomFooter extends StatelessWidget {
  final bool isHome;
  const CustomFooter({Key? key, this.isHome = false}) : super(key: key);

  static const String routeHome = '/home';
  static const String routeEvents = '/evenimente';
  static const String routeGallery = '/galerie';
  static const String routeRoutes = '/trasee';
  static const String routeHelp = '/ajutor';

  static const Color appBlue = Color(0xFF004E64);

  @override
  Widget build(BuildContext context) {
    final tab = _detectCurrentTab(context);

    final bottomInset = MediaQuery.of(context).padding.bottom;
    final double bottomGap = bottomInset > 0 ? 1 : 8;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(14, 0, 14, bottomGap),
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              _GlassCircleUltraLight(
                size: 50,
                selected: tab == FooterTab.home,
                icon: Icons.home_outlined,
                onTap: () {
                  _goToRoot(context, HomePage(), routeHome);
                },
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GlassPillUltraLight(
                  radius: 34,
                  child: Row(
                    children: [
                      _tabItem(
                        context,
                        selected: tab == FooterTab.events,
                        icon: Icons.event_outlined,
                        label: "Evenimente",
                        onTap: () => _goToRoot(
                          context,
                          FooterBackInterceptor(child: EvenimentePage()),
                          routeEvents,
                        ),
                      ),
                      _tabItem(
                        context,
                        selected: tab == FooterTab.gallery,
                        icon: Icons.photo_library_outlined,
                        label: "Galerie",
                        onTap: () => _goToRoot(
                          context,
                          FooterBackInterceptor(child: GaleriePage()),
                          routeGallery,
                        ),
                      ),
                      _tabItem(
                        context,
                        selected: tab == FooterTab.routes,
                        icon: Icons.route_outlined,
                        label: "Trasee",
                        onTap: () => _openTraseePremium(context),
                      ),
                      _tabItem(
                        context,
                        selected: tab == FooterTab.help,
                        icon: Icons.help_outline,
                        label: "Ajutor",
                        onTap: () => _goToRoot(
                          context,
                          const FooterBackInterceptor(child: AjutorPage()),
                          routeHelp,
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
    );
  }

  Widget _tabItem(
    BuildContext context, {
    required bool selected,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final Color iconColor = selected ? appBlue : Colors.white;
    final Color textColor = selected ? appBlue : Colors.white;

    final BoxDecoration bubble = BoxDecoration(
      color: selected ? Colors.white.withOpacity(0.28) : Colors.transparent,
      borderRadius: BorderRadius.circular(22),
    );

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          splashColor: appBlue.withOpacity(0.10),
          highlightColor: appBlue.withOpacity(0.06),
          onTap: onTap,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              decoration: bubble,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20, color: iconColor),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      color: textColor,
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

  FooterTab _detectCurrentTab(BuildContext context) {
    if (isHome) return FooterTab.home;

    final name = ModalRoute.of(context)?.settings.name;

    switch (name) {
      case routeHome:
      case '/':
        return FooterTab.home;
      case routeEvents:
        return FooterTab.events;
      case routeGallery:
        return FooterTab.gallery;
      case routeRoutes:
        return FooterTab.routes;
      case routeHelp:
        return FooterTab.help;
    }

    return FooterTab.other;
  }

  /// 🔥 FUNCȚIONEAZĂ DIN ABSOLUT ORICE PAGINĂ
  void _goToRoot(BuildContext context, Widget page, String routeName) {
    final navigator = Navigator.of(context, rootNavigator: true);

    navigator.pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        settings: RouteSettings(name: routeName),
        pageBuilder: (_, __, ___) => page,
      ),
      (route) => false,
    );
  }

  Future<void> _openTraseePremium(BuildContext context) async {
    if (IAPService.instance.premiumUnlocked == true) {
      _goToRoot(
        context,
        const FooterBackInterceptor(
          child: TraseuMultiDayPage(totalDays: 5),
        ),
        routeRoutes,
      );
      return;
    }

    final ok = await Navigator.of(context, rootNavigator: true).push<bool>(
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => const PremiumUnlockPage(),
      ),
    );

    if (ok == true || IAPService.instance.premiumUnlocked == true) {
      _goToRoot(
        context,
        const FooterBackInterceptor(
          child: TraseuMultiDayPage(totalDays: 5),
        ),
        routeRoutes,
      );
    }
  }
}

// -------------------- GLASS UI --------------------

class _GlassPillUltraLight extends StatelessWidget {
  final Widget child;
  final double radius;

  const _GlassPillUltraLight({required this.child, required this.radius});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: Colors.white.withOpacity(0.01),
            border: Border.all(color: Colors.white.withOpacity(0.10), width: 0.6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlassCircleUltraLight extends StatelessWidget {
  final double size;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;

  const _GlassCircleUltraLight({
    required this.size,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = selected ? CustomFooter.appBlue : Colors.white;

    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.10),
                border: Border.all(color: Colors.white.withOpacity(0.10), width: 0.6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Center(
                child: Icon(icon, color: iconColor, size: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------- BACK INTERCEPTOR --------------------

class FooterBackInterceptor extends StatelessWidget {
  final Widget child;
  const FooterBackInterceptor({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          PageRouteBuilder(
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            settings: const RouteSettings(name: CustomFooter.routeHome),
            pageBuilder: (_, __, ___) => HomePage(),
          ),
          (route) => false,
        );
        return false;
      },
      child: child,
    );
  }
}
