import 'package:flutter/material.dart';

/// === MODEL GENERAL PENTRU LOCAȚII ===
class LocationItem {
  final String name; // Numele locației
  final String category; // Categoria (ex: Biserici, Cafenele etc.)
  final String address; // Adresa completă
  final String imagePath; // Calea imaginii din assets
  final String schedule; // Programul (dacă există)
  final Widget? page; // Opțional: pagina către care navighează

  const LocationItem({
    required this.name,
    required this.category,
    required this.address,
    required this.imagePath,
    this.schedule = "-",
    this.page,
  });
}

/// === LISTA GENERALĂ CU TOATE LOCAȚIILE ===
final List<LocationItem> allLocations = [
  // 🕍 BISERICI ORTODOXE
  LocationItem(
    name: "Biserica cu Luna",
    category: "Biserici Ortodoxe",
    address: "📍 Piața Unirii, numărul 10",
    imagePath: "assets/images/biserica_cu_luna.jpg",
    schedule: "Luni - Închis | Marți - Duminică: 10:00 - 18:00",
  ),
  LocationItem(
    name: "Biserica Albastră - Sfântul Ierarh Nicolae",
    category: "Biserici Ortodoxe",
    address: "📍 Strada Traian Lalescu, Oradea",
    imagePath: "assets/images/biserica_albastra.jpg",
  ),
  LocationItem(
    name: "Biserica Sfinții Trei Ierarhi",
    category: "Biserici Ortodoxe",
    address: "📍 Strada Șelimbărului, Oradea",
    imagePath: "assets/images/biserica_sfintii_trei_ierarhi.jpg",
  ),
  LocationItem(
    name: "Biserica Sfântul Duh Mângâietorul",
    category: "Biserici Ortodoxe",
    address: "📍 Str. Alexandru Cazaban 37A, Bihor 410282",
    imagePath: "assets/images/biserica_sfantul_duh.jpg",
    schedule: "Luni, Marți, Joi - Închis",
  ),
  LocationItem(
    name: "Biserica Ortodoxă Sfântul Nicolae",
    category: "Biserici Ortodoxe",
    address: "📍 Strada Jimboliei, Oradea",
    imagePath: "assets/images/biserica_sfantul_nicolae.jpg",
  ),
  LocationItem(
    name: "Biserica Duminica Tuturor Sfinților",
    category: "Biserici Ortodoxe",
    address: "📍 Calea Aradului, Oradea",
    imagePath: "assets/images/biserica_duminica_tuturor_sfintilor.jpg",
  ),
  LocationItem(
    name: "Biserica Buna Vestire",
    category: "Biserici Ortodoxe",
    address: "📍 Piața Rahovei 2, Oradea",
    imagePath: "assets/images/biserica_buna_vestire.jpg",
  ),
  LocationItem(
    name: "Protopopiatul Ortodox Român Oradea",
    category: "Biserici Ortodoxe",
    address: "📍 Strada Episcop Roman Ciorogariu 10, Oradea 410017",
    imagePath: "assets/images/biserica_prototopiatul_roman.jpg",
  ),
  LocationItem(
    name: "Biserica Izvorul Tămăduirii",
    category: "Biserici Ortodoxe",
    address: "📍 Strada Louis Pasteur, Oradea",
    imagePath: "assets/images/biserica_izvorul_tamaduirii.jpg",
    schedule: "Luni - Sâmbătă: 07:00 - 10:00 | Duminică: 08:00 - 12:00",
  ),
  LocationItem(
    name: "Biserica Ortodoxă Sfinții Petru și Pavel",
    category: "Biserici Ortodoxe",
    address: "📍 Parcul Traian, Oradea",
    imagePath: "assets/images/biserica_sfintii_petru_pavel.jpg",
  ),
  LocationItem(
    name: "Biserica Militară a Garnizoanei",
    category: "Biserici Ortodoxe",
    address: "📍 Calea Armatei Române 1C, Oradea",
    imagePath: "assets/images/biserica_militara.jpg",
  ),
  LocationItem(
    name: "Biserica Sfinții Arhangheli Mihail și Gavril",
    category: "Biserici Ortodoxe",
    address: "📍 Strada Anton Bacalbașa, Oradea",
    imagePath: "assets/images/biserica_sfintii_arhangheli.jpg",
  ),
  LocationItem(
    name: "Biserica Cuvioasa Paraschiva",
    category: "Biserici Ortodoxe",
    address: "📍 Strada Ștefan Zweig, Oradea",
    imagePath: "assets/images/biserica_cuvioasa_paraschiva.jpg",
  ),
  LocationItem(
    name: "Biserica Ortodoxă Sf. Ierarh Nicolae",
    category: "Biserici Ortodoxe",
    address: "📍 Strada Nufărului, Oradea",
    imagePath: "assets/images/biserica_ierarh_nicolae.png",
    schedule: "Deschis Non-Stop",
  ),
  LocationItem(
    name: "Biserica Sfântul Vasile cel Mare și Sfântul Pantelimon",
    category: "Biserici Ortodoxe",
    address: "📍 Strada General Nicolae Șova, Oradea",
    imagePath: "assets/images/biserica_sfantul_vasile_cel_mare.jpg",
  ),
  LocationItem(
    name: "Biserica Ortodoxă Învierea Domnului",
    category: "Biserici Ortodoxe",
    address: "📍 DN1 139, Oradea 410522",
    imagePath: "assets/images/biserica_invierea_domnului.jpg",
  ),

  // ⛪ BISERICI CATOLICE
  LocationItem(
    name: "Biserica Romano-Catolică Sfânta Ecaterina",
    category: "Biserici Catolice",
    address: "📍 Strada Sovata 51, Oradea 410298",
    imagePath: "assets/images/biserica_sfanta_ecaterina.jpg",
  ),
  LocationItem(
    name: "Biserica Adormirea Maicii Domnului Oradea",
    category: "Biserici Catolice",
    address: "📍 Strada Corneliu Coposu nr. 2/A, Oradea 410469",
    imagePath: "assets/images/biserica_adormirea_maicii_domnului.jpg",
  ),
  LocationItem(
    name: "Biserica Romano-Catolică Sfânta Tereza",
    category: "Biserici Catolice",
    address: "📍 Strada Gheorghe Pop de Băsești, Oradea",
    imagePath: "assets/images/biserica_sfanta_tereza.jpeg",
  ),
  LocationItem(
    name: "Biserica Greco-Catolică Sfântul Gheorghe",
    category: "Biserici Catolice",
    address: "📍 Strada Louis Pasteur, Oradea",
    imagePath: "assets/images/biserica_sfantul_gheorghe.jpg",
  ),
  LocationItem(
    name: "Biserica Romano Catolică Coborârea Sfântului Duh",
    category: "Biserici Catolice",
    address: "📍 Strada Dunărea, Oradea",
    imagePath: "assets/images/biserica_coborarea_sfantului_duh.jpg",
  ),
  LocationItem(
    name: "Biserica Romano-Catolică Sfânta Ana",
    category: "Biserici Catolice",
    address: "📍 Calea Republicii, Oradea",
    imagePath: "assets/images/biserica_sfanta_ana.jpg",
  ),
  LocationItem(
    name: "Biserica Sfântul Gheorghe",
    category: "Biserici Catolice",
    address: "📍 Parcul Traian 8, Oradea",
    imagePath: "assets/images/biserica_sfantul_gheorge_x2.jpg",
  ),
  LocationItem(
    name: "Biserica Romano-Catolică Sfânta Maria",
    category: "Biserici Catolice",
    address: "📍 Oradea",
    imagePath: "assets/images/biserica_sfanta_maria.jpg",
  ),
  LocationItem(
    name: "Biserica Oradea-Cetate",
    category: "Biserici Catolice",
    address: "📍 Strada Constantin Dobrogeanu Gherea 1, Oradea",
    imagePath: "assets/images/biserica_oradea_cetate.jpg",
    schedule: "Luni - Sâmbătă: Închis | Duminică: 10:00 - 11:00",
  ),
  LocationItem(
    name: "Biserica Greco-Catolică Schimbarea la Faţă",
    category: "Biserici Catolice",
    address: "📍 Strada Alexandru Andrițoiu, Oradea",
    imagePath: "assets/images/biserica_schimbarea_la_fata.jpg",
  ),

  // ✝️ BISERICI NEOPROTESTANTE
  LocationItem(
    name: "Campusul BBSO (Biserica Baptistă Speranța Oradea)",
    category: "Biserici Neoprotestante",
    address: "📍 Strada Thurzó Sándor 19, Oradea",
    imagePath: "assets/images/biserica_bbso.jpg",
    schedule: "Joi: 18:30 - 20:00 | Duminică: 09:30 - 13:30",
  ),
  LocationItem(
    name: "Biserica Lumina Oradea",
    category: "Biserici Neoprotestante",
    address: "📍 Calea Clujului 207, Oradea",
    imagePath: "assets/images/biserica_lumina.jpg",
    schedule:
        "Miercuri: 18:30 - 20:00 | Duminică: 10:00 - 12:00, 18:00 - 20:00 | Luni: 18:00 - 20:00",
  ),
  LocationItem(
    name: "Biserica Betel",
    category: "Biserici Neoprotestante",
    address: "📍 Strada Ion Ghica Nr. 13, Oradea",
    imagePath: "assets/images/biserica_betel.jpg",
    schedule:
        "Marți, Miercuri, Joi: 18:00 - 20:00 | Duminică: 09:00 - 12:00, 18:00 - 20:00",
  ),
  LocationItem(
    name: "Biserica Emanuel",
    category: "Biserici Neoprotestante",
    address: "📍 Bulevardul Decebal 65, Oradea",
    imagePath: "assets/images/biserica_emanuel.jpg",
    schedule:
        "Joi, Vineri: 18:00 - 20:00 | Duminică: 10:00 - 12:00, 17:00 - 19:00",
  ),
  LocationItem(
    name: "Biserica Maranata",
    category: "Biserici Neoprotestante",
    address: "📍 Strada Greierului 17, Oradea 410258",
    imagePath: "assets/images/biserica_maranata.jpg",
    schedule:
        "Miercuri, Vineri: 18:30 - 20:30 | Joi: 19:00 - 20:30 | Duminică: 09:30 - 12:00, 18:00 - 20:00",
  ),

  // 🕊️ CATEDRALE ȘI MĂNĂSTIRI
  LocationItem(
    name: "Mănăstirea Sfânta Cruce",
    category: "Catedrale/Manastiri",
    address: "📍 Strada Făcliei 24A, Oradea 410181",
    imagePath: "assets/images/manastirea_sfanta_cruce.jpg",
    schedule: "Deschis Non Stop",
  ),
  LocationItem(
    name: "Mănăstirea Franciscană Maica Domnului",
    category: "Catedrale/Manastiri",
    address: "📍 Str. Spartacus 33, Oradea 410466",
    imagePath: "assets/images/manastirea_franciscana.jpg",
  ),
  LocationItem(
    name: "Mănăstirea Capucinilor",
    category: "Catedrale/Manastiri",
    address: "📍 Strada General Traian Moșoiu 21, Oradea",
    imagePath: "assets/images/manastirea_capucinilor.jpg",
    schedule: "Deschis Non Stop",
  ),
  LocationItem(
    name: "Catedrala Romano-Catolică",
    category: "Catedrale/Manastiri",
    address: "📍 Strada Șirul Canonicilor 2, Oradea",
    imagePath: "assets/images/catedrala_romano_catolica.jpg",
    schedule: "Luni - Duminică: 07:00 - 19:00",
  ),
  LocationItem(
    name: "Catedrala Greco-Catolică Sfântul Nicolae",
    category: "Catedrale/Manastiri",
    address: "📍 Strada Iuliu Maniu nr. 3, Oradea 410104",
    imagePath: "assets/images/catedrala_greo_catolica_sf_nicolae.jpg",
    schedule: "Luni - Duminică: 07:30 - 19:00",
  ),
  LocationItem(
    name: "Catedrala Veche Adormirea Maicii Domnului",
    category: "Catedrale/Manastiri",
    address: "📍 Piața Unirii 2, Oradea",
    imagePath: "assets/images/catedrala_veche_adormirea_maicii_domnului.jpg",
  ),
  LocationItem(
    name: "Catedrala Episcopală Învierea Domnului și Sf. Ierarh Andrei Șaguna",
    category: "Catedrale/Manastiri",
    address: "📍 Piața Emanuil Gojdu 43, Oradea 410067",
    imagePath: "assets/images/catedrala_episcopala_invierea_domnului.jpg",
    schedule: "Luni - Sâmbătă: 06:30 - 20:00 | Duminică: 07:30 - 20:00",
  ),

  // ☕ CAFENELE
  LocationItem(
    name: "Ristretto",
    category: "Cafenele",
    address: "📍 2 locații: Calea Republicii 11 / Piața Unirii 5",
    imagePath: "assets/images/ristretto.jpg",
  ),
  LocationItem(
    name: "Tucano Coffee",
    category: "Cafenele",
    address: "📍 Strada Ștefan Octavian Iosif 7, Lotus Retail Park",
    imagePath: "assets/images/tucano.jpg",
  ),
  LocationItem(
    name: "Street Coffee Roasters",
    category: "Cafenele",
    address:
        "📍 13 locații în Oradea (Piața Unirii, Lotus Center, Aushopping, BBSO etc.)",
    imagePath: "assets/images/street.jpg",
  ),
  LocationItem(
    name: "Starbucks",
    category: "Cafenele",
    address: "📍 Strada Nufărului 30, Lotus Center",
    imagePath: "assets/images/starbucks.jpg",
  ),
  LocationItem(
    name: "Spitze Coffee & Cycling",
    category: "Cafenele",
    address: "📍 Strada Lazăr Aurel 1, Oradea",
    imagePath: "assets/images/spitze.jpg",
  ),
  LocationItem(
    name: "The Sip",
    category: "Cafenele",
    address: "📍 Parcul Traian 11, Oradea",
    imagePath: "assets/images/the_sip.jpg",
  ),
  LocationItem(
    name: "Meron Alecsandri",
    category: "Cafenele",
    address: "📍 Strada Vasile Alecsandri 6, Oradea",
    imagePath: "assets/images/meron.jpg",
  ),
  LocationItem(
    name: "Snoozz",
    category: "Cafenele",
    address: "📍 Parcul Traian nr. 7, ap. 17, Oradea",
    imagePath: "assets/images/snoozz.jpg",
  ),
  LocationItem(
    name: "Radical Coffee",
    category: "Cafenele",
    address: "📍 Strada Iuliu Maniu nr. 59, Oradea",
    imagePath: "assets/images/radical.jpg",
  ),
  LocationItem(
    name: "The Dripper",
    category: "Cafenele",
    address: "📍 Strada Vasile Alecsandri nr. 9, Oradea",
    imagePath: "assets/images/dripper.jpg",
  ),
  LocationItem(
    name: "Mr. Bean Coffee",
    category: "Cafenele",
    address: "📍 Strada Moscovei nr. 1, Oradea",
    imagePath: "assets/images/mrbean.jpg",
  ),
  LocationItem(
    name: "Madal Cafe Oradea",
    category: "Cafenele",
    address: "📍 Calea Republicii 3-5, Oradea",
    imagePath: "assets/images/madal.jpg",
  ),
  LocationItem(
    name: "Sago",
    category: "Cafenele",
    address: "📍 Lotus Trade Center, Strada Nufărului 28, Oradea",
    imagePath: "assets/images/sago.jpg",
  ),
  LocationItem(
    name: "Avoca",
    category: "Cafenele",
    address: "📍 Piața 1 Decembrie nr. 1, Oradea",
    imagePath: "assets/images/avoca.jpg",
  ),
  LocationItem(
    name: "Pellini Evolution",
    category: "Cafenele",
    address: "📍 Strada Nufărului nr. 30, Lotus Center, Oradea",
    imagePath: "assets/images/pellini.jpg",
  ),
  LocationItem(
    name: "Ted's Coffee Co.",
    category: "Cafenele",
    address: "📍 Parcul Traian nr. 11, Oradea",
    imagePath: "assets/images/teds.jpg",
  ),
  LocationItem(
    name: "Captain Bean",
    category: "Cafenele",
    address: "📍 Piața 1 Decembrie nr. 5, Oradea",
    imagePath: "assets/images/captainbean.jpg",
  ),
];
