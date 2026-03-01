import 'package:viziteaza_oradea/services/app_state.dart';

class S {
  S._();

  static const Map<String, Map<String, String>> _strings = {
    // Navigation
    'nav_events': {'ro': 'Evenimente', 'en': 'Events'},
    'nav_gallery': {'ro': 'Galerie', 'en': 'Gallery'},
    'nav_routes': {'ro': 'Trasee', 'en': 'Routes'},
    'nav_help': {'ro': 'Ajutor', 'en': 'Help'},
    // Home
    'today': {'ro': 'Astăzi', 'en': 'Today'},
    'city_map': {'ro': 'Harta orașului', 'en': 'City Map'},
    'most_popular': {'ro': 'Cele mai accesate', 'en': 'Most Popular'},
    'welcome': {'ro': 'Bine ai venit în Oradea', 'en': 'Welcome to Oradea'},
    'tagline': {
      'ro': 'Locul unde trecutul și prezentul dansează împreună!',
      'en': 'Where history and modern life dance together!'
    },
    'explore': {
      'ro': 'Descoperă orașul pas cu pas',
      'en': 'Discover the city step by step'
    },
    'tourist_banner': {
      'ro': 'Turist în Oradea? Ai ajuns în locul potrivit!',
      'en': 'Visiting Oradea? You\'ve come to the right place!'
    },
    // Drawer categories
    'menu_suggestions': {'ro': 'Sugestii', 'en': 'Suggestions'},
    'menu_food': {'ro': 'Mâncare', 'en': 'Food'},
    'menu_activities': {'ro': 'Activități', 'en': 'Activities'},
    'menu_culture': {'ro': 'Cultură', 'en': 'Culture'},
    'menu_contact': {'ro': 'Contact', 'en': 'Contact'},
    // Drawer items
    'photos': {'ro': 'Poze Oradea', 'en': 'Oradea Photos'},
    'favorites': {'ro': 'Favorite', 'en': 'Favorites'},
    'routes': {'ro': 'Trasee', 'en': 'Routes'},
    'cafenele': {'ro': 'Cafenele', 'en': 'Coffee Shops'},
    'restaurante': {'ro': 'Restaurante', 'en': 'Restaurants'},
    'fastfood': {'ro': 'FastFood', 'en': 'Fast Food'},
    'muzee': {'ro': 'Muzee', 'en': 'Museums'},
    'stranduri': {'ro': 'AquaPark', 'en': 'AquaPark'},
    'distractii': {'ro': 'Distracții', 'en': 'Entertainment'},
    'teatru': {'ro': 'Teatru', 'en': 'Theatre'},
    'filarmonica': {'ro': 'Filarmonica', 'en': 'Philharmonic'},
    'evenimente': {'ro': 'Evenimente', 'en': 'Events'},
    'cathedrals': {'ro': 'Catedrale / Mănăstiri', 'en': 'Cathedrals / Monasteries'},
    'churches': {'ro': 'Biserici', 'en': 'Churches'},
    'faq': {'ro': 'FAQ', 'en': 'FAQ'},
    'terms': {'ro': 'Termeni și condiții', 'en': 'Terms & Conditions'},
    'about': {'ro': 'Despre aplicație', 'en': 'About the app'},
    // Settings
    'dark_mode': {'ro': 'Mod Întunecat', 'en': 'Dark Mode'},
    'language': {'ro': 'Limbă', 'en': 'Language'},
    // Common
    'details': {'ro': 'Detalii', 'en': 'Details'},
    'expand_map': {'ro': 'Extinde harta', 'en': 'Expand map'},
    'all': {'ro': 'Toate', 'en': 'All'},
    'recommended': {'ro': 'Recomandate', 'en': 'Recommended'},
    // Help page
    'help_title': {'ro': 'Ajutor', 'en': 'Help'},
    'help_name': {'ro': 'Nume', 'en': 'First Name'},
    'help_surname': {'ro': 'Prenume', 'en': 'Last Name'},
    'help_email': {'ro': 'Email', 'en': 'Email'},
    'help_message': {'ro': 'Mesaj', 'en': 'Message'},
    'help_send': {'ro': 'Trimite mesaj', 'en': 'Send message'},
    'help_success': {'ro': 'Mesaj trimis cu succes!', 'en': 'Message sent successfully!'},
    'help_error': {'ro': 'Eroare la trimitere.', 'en': 'Error sending message.'},
    // Tour brand
    'brand': {'ro': 'Tour Oradea', 'en': 'Tour Oradea'},
    'copyright': {'ro': '— Tour Oradea © 2025 —', 'en': '— Tour Oradea © 2025 —'},
  };

  static String of(String key) {
    final lang = AppState.instance.language;
    final map = _strings[key];
    if (map == null) return key;
    return map[lang] ?? map['ro'] ?? key;
  }
}
