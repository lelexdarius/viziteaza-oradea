import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:viziteaza_oradea/services/app_state.dart';

class AppTheme {
  AppTheme._();

  static const Color kBrand = Color(0xFF004E64);
  // Dark-mode accent: Apple blue (#2997FF) — matches Apple dark mode
  static const Color kBrandDark = Color(0xFF1FA3B1);

  // ─── Light theme ───────────────────────────────────────────────
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: kBrand,
      scaffoldBackgroundColor: const Color(0xFFE8F1F4),
      cardColor: Colors.white,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.light(
        primary: kBrand,
        surface: Colors.white,
        background: const Color(0xFFE8F1F4),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: kBrand,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.black87),
        bodySmall: TextStyle(color: Colors.black54),
      ),
    );
  }

  // ─── Dark theme ────────────────────────────────────────────────
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: kBrandDark,
      scaffoldBackgroundColor: const Color(0xFF000000),
      cardColor: const Color(0xFF1C1C1E),
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.dark(
        primary: kBrandDark,
        surface: const Color(0xFF1C1C1E),
        background: const Color(0xFF000000),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Color(0xFF8E8E93)),
      ),
    );
  }

  // ─── Adaptive helpers ──────────────────────────────────────────
  static bool _isDark(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark;

  /// kBrand in light, kBrandDark (#0A84FF) in dark
  static Color accent(BuildContext ctx) =>
      _isDark(ctx) ? kBrandDark : kBrand;

  /// Same as accent but without context (reads AppState directly)
  static Color get accentGlobal =>
      isDarkGlobal ? kBrandDark : kBrand;

  static Color gradient1(BuildContext ctx) =>
      _isDark(ctx) ? const Color(0xFF000000) : const Color(0xFFB2EBF2);

  static Color gradient2(BuildContext ctx) =>
      _isDark(ctx) ? const Color(0xFF000000) : const Color(0xFFFFFFFF);

  static Color cardBg(BuildContext ctx) =>
      _isDark(ctx) ? const Color(0xFF1C1C1E) : Colors.white;

  /// Glass card surface — white/translucent in light, medium gray in dark
  static Color glassSurface(BuildContext ctx) =>
      _isDark(ctx) ? const Color(0xFF3A3A3C) : Colors.white.withOpacity(0.92);

  /// Subtle tint on top of scaffold (secondary cards, chips bg)
  static Color secondarySurface(BuildContext ctx) =>
      _isDark(ctx) ? const Color(0xFF1C1C1E) : const Color(0xFFE8F1F4);

  static Color textPrimary(BuildContext ctx) =>
      _isDark(ctx) ? Colors.white : Colors.black87;

  static Color textSecondary(BuildContext ctx) =>
      _isDark(ctx) ? const Color(0xFF8E8E93) : Colors.black54;

  static Color drawerBg(BuildContext ctx) =>
      _isDark(ctx)
          ? const Color(0xFF0A0A0A).withOpacity(0.97)
          : Colors.white.withOpacity(0.72);

  /// Border color for cards
  static Color cardBorder(BuildContext ctx) =>
      _isDark(ctx)
          ? kBrandDark.withOpacity(0.25)
          : kBrand.withOpacity(0.10);

  // Convenience: is dark from AppState (no context needed)
  static bool get isDarkGlobal => AppState.instance.isDarkMode;

  // ─── Google Maps dark style ────────────────────────────────────
  static const String darkMapStyle = '''[
    {"elementType":"geometry","stylers":[{"color":"#212121"}]},
    {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
    {"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
    {"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},
    {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},
    {"featureType":"administrative.country","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},
    {"featureType":"administrative.land_parcel","stylers":[{"visibility":"off"}]},
    {"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},
    {"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
    {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#181818"}]},
    {"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},
    {"featureType":"poi.park","elementType":"labels.text.stroke","stylers":[{"color":"#1b1b1b"}]},
    {"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#2c2c2c"}]},
    {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},
    {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},
    {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},
    {"featureType":"road.highway.controlled_access","elementType":"geometry","stylers":[{"color":"#4e4e4e"}]},
    {"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},
    {"featureType":"transit","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
    {"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]},
    {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#3d3d3d"}]}
  ]''';

  /// Apply dark map style to a controller if dark mode is active.
  static Future<void> applyMapStyle(GoogleMapController controller) async {
    if (AppState.instance.isDarkMode) {
      await controller.setMapStyle(darkMapStyle);
    } else {
      await controller.setMapStyle(null); // reset to default
    }
  }
}
