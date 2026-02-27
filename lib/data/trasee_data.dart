class TraseuData {
  // Helpers: imagini default pe tip (ca să nu ai crash dacă uiți image)
  static String _imgForType(String type) {
    switch (type) {
      case "cafe":
        return "assets/images/cafea_trasee.jpeg.webp";
      case "food":
        return "assets/images/restaurant_rosecas_trasee.jpg.webp";
      case "museum":
        return "assets/images/muzeu_trasee.png.webp";
      case "walk":
        return "assets/images/trasee.png.webp";
      case "strand":
        return "assets/images/trasee.png.webp";
      default:
        return "assets/images/trasee.png.webp";
    }
  }

  // -------------------------------------------------------------
  // ZIUA 1: Inima Oradiei (Centrul Istoric & Arhitectură)
  // -------------------------------------------------------------
  static Map<String, dynamic> ziua1 = {
    "title": "Ziua 1",
    "heroImage": "assets/images/centrul_istoric.jpg.webp",
    "subtitle": "Inima Oradiei • Centru istoric & arhitectură",
    "activities": [
      {
        "id": "ziua1_cafea_street",
        "hour": "08:30",
        "title": "Street Coffee Roasters - Biserica cu Lună",
        "type": "cafe",
        "collection": "cafenele",
        "docId": "street_coffee_roasters",
        "image": "assets/images/street_coffee_roasters_traseu.png.webp",
      },
      {
        "id": "ziua1_walk_vulturul",
        "hour": "10:00",
        "title": "Palatul Vulturul Negru",
        "type": "walk",
        "collection": "walks",
        "docId": "Palatul Vulturul Negru Oradea",
        "image": "assets/images/palatul_vulturul_traseu.png.webp",
      },
      {
        "id": "ziua1_food_blackeagle",
        "hour": "11:00",
        "title": "Black Eagle Restaurant",
        "type": "food",
        "collection": "restaurante",
        "docId": "restaurant_black_eagle",
        "image": "assets/images/black_eagle_traseu.png.webp",
      },
      {
        "id": "ziua1_walk_unirii",
        "hour": "13:30",
        "title": "Piața Unirii",
        "type": "walk",
        "collection": "walks",
        "docId": "Piața Unirii",
        "image": "assets/images/piata_unirii_traseu.png.webp",
      },
      {
        "id": "ziua1_walk_republicii",
        "hour": "14:00",
        "title": "Calea Republicii",
        "type": "walk",
        "collection": "walks",
        "docId": "Calea Republicii",
        "image": "assets/images/calea_republicii_traseu.png.webp",
      },
      {
        "id": "ziua1_cafe_sip",
        "hour": "16:00",
        "title": "The Sip",
        "type": "cafe",
        "collection": "cafenele",
        "docId": "the_sip",
        "image": "assets/images/the_sip_traseu.png.webp",
      },
      {
        "id": "ziua1_walk_cetate",
        "hour": "18:00",
        "title": "Cetatea Oradea",
        "type": "walk",
        "collection": "walks",
        "docId": "Cetatea Oradea",
        "image": "assets/images/cetatea_oradea_traseu.png.webp",
      },
      {
        "id": "ziua1_food_meridian",
        "hour": "20:00",
        "title": "Meridian Zero",
        "type": "food",
        "collection": "restaurante",
        "docId": "restaurant_meridian_zero",
        "image": "assets/images/meridian_zero_traseu.png.webp",
      },
    ],
  };

  // -------------------------------------------------------------
  // ZIUA 2: Natură & Distracție
  // -------------------------------------------------------------
  static Map<String, dynamic> ziua2 = {
    "title": "Ziua 2",
    "heroImage": "assets/images/natura_si_distractie.jpg.webp",
    "subtitle": "Natură & distracție",
    "activities": [
      {
        "id": "ziua2_cafe_madam",
        "hour": "08:30",
        "title": "Madal Cafe",
        "type": "cafe",
        "collection": "cafenele",
        "docId": "madam_cafe",
        "image": "assets/images/madal_coffee_traseu.png.webp",
      },
      {
        "id": "ziua2_walk_zoo",
        "hour": "10:00",
        "title": "Grădina Zoologică Oradea",
        "type": "walk",
        "collection": "walks",
        "docId": "Grădina Zoologică Oradea",
        "image": "assets/images/gradina_zoologica_traseu.png.webp",
      },
      {
        "id": "ziua2_food_rivo",
        "hour": "12:30",
        "title": "Rivo",
        "type": "food",
        "collection": "restaurante",
        "docId": "restaurant_rivo",
        "image": "assets/images/rivo_restaurant_traseu.png.webp",
      },
      {
        "id": "ziua2_strand_nymphaea",
        "hour": "13:30",
        "title": "Aquapark Nymphaea",
        "type": "strand",
        "collection": "stranduri",
        "docId": "nymph_aqua_park",
        "image": "assets/images/aqua_park_traseu.png.webp",
      },
      {
        "id": "ziua2_food_piata9",
        "hour": "20:30",
        "title": "Piața 9",
        "type": "food",
        "collection": "restaurante",
        "docId": "restaurant_piata_noua",
        "image": "assets/images/piata9_traseu.png.webp",
      },
    ],
  };

  // -------------------------------------------------------------
  // ZIUA 3: Arhitectură & Istorie
  // -------------------------------------------------------------
  static Map<String, dynamic> ziua3 = {
    "title": "Ziua 3",
    "heroImage": "assets/images/arhitectura.jpg.webp",
    "subtitle": "Arhitectură & istorie",
    "activities": [
      {
        "id": "ziua3_cafe_ristretto",
        "hour": "08:30",
        "title": "Ristretto Piața Unirii",
        "type": "cafe",
        "collection": "cafenele",
        "docId": "ristretto",
        "image": "assets/images/ristrettoo_coffee_traseu.png.webp",
      },
      {
        "id": "ziua3_museum_tarii_crisurilor",
        "hour": "10:00",
        "title": "Muzeul Țării Crișurilor",
        "type": "museum",
        "collection": "muzee",
        "docId": "muzeul_tarii_crisurilor",
        "image": "assets/images/muzeul_tarii_crisurilor_traseu.png.webp",
      },
      {
        "id": "ziua3_museum_francmasonerie",
        "hour": "18:00",
        "title": "Templul Francmasoneriei",
        "type": "museum",
        "collection": "muzee",
        "docId": "templul_francmasoneriei",
        "image": "assets/images/templul_francmasoneriei_traseu.png.webp",
      },
      {
        "id": "ziua3_food_rosecas",
        "hour": "12:30",
        "title": "Rosecas",
        "type": "food",
        "collection": "restaurante",
        "docId": "restaurant_rosecas",
        "image": "assets/images/rosecas_traseu.png.webp",
      },
      {
        "id": "ziua3_walk_biserica_cu_luna",
        "hour": "14:00",
        "title": "Biserica cu Lună",
        "type": "walk",
        "collection": "walks",
        "docId": "Biserica cu Lună",
        "image": "assets/images/biserica_cu_luna_traseu.png.webp",
      },
      {
        "id": "ziua3_walk_darvas",
        "hour": "16:00",
        "title": "Casa Darvas-La Roche",
        "type": "walk",
        "collection": "walks",
        "docId": "Casa Darvas-La Roche",
        "image": "assets/images/casa_darvas_traseu.png.webp",
      },
      {
        "id": "ziua3_food_allegria",
        "hour": "19:30",
        "title": "Allegria",
        "type": "food",
        "collection": "restaurante",
        "docId": "restaurant_allegria",
        "image": "assets/images/allegria_traseu.png.webp",
      },
    ],
  };

  // -------------------------------------------------------------
  // ZIUA 4: Distracție Urbană & Chill
  // -------------------------------------------------------------
  static Map<String, dynamic> ziua4 = {
    "title": "Ziua 4",
    "heroImage": "assets/images/urban.jpg.webp",
    "subtitle": "Urban & chill",
    "activities": [
      {
        "id": "ziua4_cafe_semiramis",
        "hour": "08:30",
        "title": "SemiramiS Cafe",
        "type": "cafe",
        "collection": "cafenele",
        "docId": "semiramis_cafe",
        "image": "assets/images/semiramis_cafe_traseu.png.webp",
      },
      {
        "id": "ziua4_walk_turn_primarie",
        "hour": "10:00",
        "title": "Turnul Primăriei",
        "type": "walk",
        "collection": "walks",
        "docId": "Turnul Primăriei",
        "image": "assets/images/turnul_primariei_traseu.jpg.webp",
      },
      {
        "id": "ziua4_food_tochefs",
        "hour": "13:00",
        "title": "To Chefs",
        "type": "food",
        "collection": "restaurante",
        "docId": "restaurant_to_chefs",
        "image": "assets/images/to_chefs_traseu.png.webp",
      },
      {
        "id": "ziua4_walk_ciuperca",
        "hour": "16:00",
        "title": "Dealul Ciuperca",
        "type": "walk",
        "collection": "walks",
        "docId": "Dealul Ciuperca",
        "image": "assets/images/dealul_ciuperca_traseu.png.webp",
      },
      {
        "id": "ziua4_food_ciuperca_restaurant",
        "hour": "17:00",
        "title": "Ciuperca (Ceai / desert)",
        "type": "food",
        "collection": "restaurante",
        "docId": "ciuperca_restaurant",
        "image": "assets/images/restaurantul_ciuperca_traseu.png.webp",
      },
      {
        "id": "ziua4_food_enchante",
        "hour": "19:00",
        "title": "Enchante Rooftop & Social Lounge",
        "type": "food",
        "collection": "restaurante",
        "docId": "restaurant_enchante_rooftop",
        "image": "assets/images/enchante_rooftop_traseu.png.webp",
      },
    ],
  };

  // -------------------------------------------------------------
  // ZIUA 5: Relaxare & Experiențe locale
  // -------------------------------------------------------------
  static Map<String, dynamic> ziua5 = {
    "title": "Ziua 5",
    "heroImage": "assets/images/experiente_locale.jpg.webp",
    "subtitle": "Relaxare & experiențe locale",
    "activities": [
      {
        "id": "ziua5_food_dock",
        "hour": "08:30",
        "title": "Dock Oradea",
        "type": "food",
        "collection": "restaurante",
        "docId": "restaurant_dock",
        "image": "assets/images/dock_restaurant_traseu.png.webp",
      },
      {
        "id": "ziua5_walk_malul_crisului",
        "hour": "10:00",
        "title": "Malul Crișul Repede",
        "type": "walk",
        "collection": "walks",
        "docId": "Malul Crișul Repede",
        "image": "assets/images/malul_crisul_repede_traseu.png.webp",
      },
      {
        "id": "ziua5_food_via29",
        "hour": "12:30",
        "title": "Botanic By Armonia",
        "type": "food",
        "collection": "restaurante",
        "docId": "restaurant_botanic",
        "image": "assets/images/botanic_by_armonica_traseu.jpg.webp",
      },
      {
        "id": "ziua5_walk_lotus",
        "hour": "14:00",
        "title": "Lotus Mall",
        "type": "walk",
        "collection": "walks",
        "docId": "Lotus Mall",
        "image": "assets/images/lotus_mall_traseu.png.webp",
      },
      {
        "id": "ziua5_food_rewine",
        "hour": "20:00",
        "title": "ReWine Bistro",
        "type": "food",
        "collection": "restaurante",
        "docId": "rewine_bistro_restaurant",
        "image": "assets/images/rewine_bistro_traseu.png.webp",
      },
    ],
  };

  // -------------------------------------------------------------
  // FUNCȚIE GLOBALĂ
  // -------------------------------------------------------------
  static Map<String, dynamic> getDay(int zi) {
    switch (zi) {
      case 1:
        return ziua1;
      case 2:
        return ziua2;
      case 3:
        return ziua3;
      case 4:
        return ziua4;
      case 5:
        return ziua5;
      default:
        return ziua1;
    }
  }
}
