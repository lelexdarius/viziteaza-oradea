import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viziteaza_oradea/models/favorite_item.dart';

class FavoriteService {
  static const String key = "favorite_items";

  static Future<List<FavoriteItem>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(key) ?? [];

    return list.map((e) {
      return FavoriteItem.fromJson(jsonDecode(e));
    }).toList();
  }

  static Future<bool> isFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(key) ?? [];

    return list.any((e) {
      final item = FavoriteItem.fromJson(jsonDecode(e));
      return item.id == id;
    });
  }

  static Future<void> toggleFavorite(FavoriteItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(key) ?? [];

    final exists = list.any((e) {
      final fav = FavoriteItem.fromJson(jsonDecode(e));
      return fav.id == item.id;
    });

    if (exists) {
      list.removeWhere((e) {
        final fav = FavoriteItem.fromJson(jsonDecode(e));
        return fav.id == item.id;
      });
    } else {
      list.add(jsonEncode(item.toJson()));
    }

    await prefs.setStringList(key, list);
  }
}
