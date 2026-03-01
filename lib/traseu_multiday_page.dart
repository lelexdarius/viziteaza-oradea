import 'dart:io';
import 'dart:ui' as ui;
import 'package:viziteaza_oradea/utils/app_theme.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:viziteaza_oradea/data/trasee_data.dart';
import 'package:viziteaza_oradea/home.dart';

import 'package:viziteaza_oradea/cafenea_detalii_page.dart';
import 'package:viziteaza_oradea/models/restaurant_model.dart';
import 'package:viziteaza_oradea/restaurant_detalii_page.dart';
import 'package:viziteaza_oradea/muzeu_detalii_page.dart';
import 'package:viziteaza_oradea/walk_detalii_page.dart';
import 'cafenele_page.dart';
import 'muzee_page.dart';

class TraseuMultiDayPage extends StatefulWidget {
  final int totalDays;

  const TraseuMultiDayPage({
    Key? key,
    required this.totalDays,
  }) : super(key: key);

  @override
  State<TraseuMultiDayPage> createState() => _TraseuMultiDayPageState();
}

enum _ScreenMode { days, day }

class _TraseuMultiDayPageState extends State<TraseuMultiDayPage> with SingleTickerProviderStateMixin {
  // =========================
  // STYLE
  // =========================
  static const Color kBg = Color(0xFFF4F5F7);
  static const Color kText = Color(0xFF0B0C0F);

  // ✅ albastrul aplicației (nu mai folosim mov)
  static const Color kBrand = Color(0xFF004E64);
  static const Color kPrimary = Color(0xFF2B6CB0); // albastru
  static const Color kAccentMaps = Color(0xFF0F766E); // direcții
  static const Color kAccentGuide = Color(0xFFF59E0B);

  // ✅ cerut: progres verde peste tot
  static const Color kAccentSuccess = Color(0xFF16A34A);
  static const Color kAccentDanger = Color(0xFFEF4444);

  // =========================
  // PREF KEYS
  // =========================
  static const String _kPrefIntro = "traseu_multiday_intro_v6_shown";
  static String _kPrefDayIntro(int day) => "traseu_multiday_dayintro_v6_shown_day_$day";

  // ✅ TUTORIAL COACH: o singură dată ÎN TOATĂ APLICAȚIA (indiferent de zi)
  static const String _kPrefCoachOnce = "traseu_multiday_coach_once_v1_shown";

  // (opțional) păstrăm cheia veche ca fallback pentru utilizatori existenți
  static String _kPrefDayCoachLegacy(int day) => "traseu_multiday_daycoach_v1_shown_day_$day";

  // Saved checks:
  // activity_<id> : bool
  static const String _kActivityPrefix = "activity_";

  // reset limit: max 1 reset / zi (repeat traseu o singură dată)
  static String _kResetCountKey(int day) => "traseu_day_reset_count_v2_day_$day";

  // Route pentru strand detalii
  static const String _kStrandDetailsRoute = '/stranduri_detalii';

  // =========================
  // STATE
  // =========================
  _ScreenMode _mode = _ScreenMode.days;
  int selectedDay = 1;

  bool _gateDaysVisible = false;
  bool _isLoadingShown = false;

  // swipe hint
  bool _showSwipeHint = true;
  late final AnimationController _swipeAnim;

  // checked map (DOAR asta)
  final Map<String, bool> checked = {};

  // cache marker icons
  final Map<String, BitmapDescriptor> _markerIconCache = {};

  // =========================
  // COACH MARKS KEYS
  // =========================
  final GlobalKey _coachCheckKey = GlobalKey();
  final GlobalKey _coachDirectionsKey = GlobalKey();
  final GlobalKey _coachSeeKey = GlobalKey();
  final GlobalKey _coachStatusKey = GlobalKey();
  final GlobalKey _coachResetKey = GlobalKey();
  final GlobalKey _coachMapKey = GlobalKey();

  bool _coachIsShowing = false;

  // =========================
  // COORDS (as-is)
  // =========================
  static const Map<String, LatLng> _coordsZiua1 = {
    "ziua1_cafea_street": LatLng(47.05361815639019, 21.928383777108674),
    "ziua1_walk_vulturul": LatLng(47.05488224041504, 21.929450441462407),
    "ziua1_food_blackeagle": LatLng(47.05474086917673, 21.930466792387097),
    "ziua1_walk_unirii": LatLng(47.05460337200676, 21.928287905880204),
    "ziua1_walk_republicii": LatLng(47.05903195043382, 21.93452943727137),
    "ziua1_cafe_sip": LatLng(47.05727813680257, 21.93637328329869),
    "ziua1_walk_cetate": LatLng(47.052067739725295, 21.94383371213413),
    "ziua1_food_meridian": LatLng(47.052310089679914, 21.94288645446291),
  };

  static const Map<String, LatLng> _coordsZiua2 = {
    "ziua2_cafe_madam": LatLng(47.057021400428475, 21.93143653912061),
    "ziua2_walk_zoo": LatLng(47.050877602126434, 21.9185799967916),
    "ziua2_food_rivo": LatLng(47.05531227961331, 21.94480303912044),
    "ziua2_strand_nymphaea": LatLng(47.05307183738572, 21.952342213983567),
    "ziua2_food_piata9": LatLng(47.05885182391738, 21.91498106795634),
  };

  static const Map<String, LatLng> _coordsZiua3 = {
    "ziua3_cafe_ristretto": LatLng(47.05472432121454, 21.928224233782466),
    "ziua3_museum_tarii_crisurilor": LatLng(47.04978562455534, 21.92389536795594),
    "ziua3_food_rosecas": LatLng(47.05316005674644, 21.93083868329857),
    "ziua3_walk_biserica_cu_luna": LatLng(47.05373842639793, 21.92888408422281),
    "ziua3_walk_darvas": LatLng(47.05614748259717, 21.932532229504663),
    "ziua3_museum_francmasonerie": LatLng(47.05013212118942, 21.925668620326785),
    "ziua3_food_allegria": LatLng(47.060547205562486, 21.937443046887875),
  };

  static const Map<String, LatLng> _coordsZiua4 = {
    "ziua4_cafe_semiramis": LatLng(47.0575015037483, 21.923777703267803),
    "ziua4_walk_turn_primarie": LatLng(47.056488948077074, 21.927617581449404),
    "ziua4_food_tochefs": LatLng(47.05963316658343, 21.925424539120833),
    "ziua4_walk_ciuperca": LatLng(47.06005694308636, 21.950668698477685),
    "ziua4_food_ciuperca_restaurant": LatLng(47.058733543661965, 21.950439088429842),
    "ziua4_food_enchante": LatLng(47.062613891567054, 21.910408923778387),
  };

  static const Map<String, LatLng> _coordsZiua5 = {
    "ziua5_food_dock": LatLng(47.05649183874267, 21.929102840970007),
    "ziua5_walk_malul_crisului": LatLng(47.05549209880835, 21.933793987899456),
    "ziua5_food_via29": LatLng(47.056609307585674, 21.938887757202185),
    "ziua5_walk_lotus": LatLng(47.03618892559189, 21.94881563494937),
    "ziua5_food_rewine": LatLng(47.060312164535596, 21.93725132562769),
  };

  // hinturi scurte (optional)
  final Map<String, Map<String, String>> _extraInfoById = const {
    "ziua1_cafea_street": {
      "hint":
          "Hint: Parchează mașina la Parcarea Subterană - Independenței. Vei sta in această zonă o vreme, iar aceasta este cea mai ieftină variantă din zonă. Va trebui să mergi puțin pe jos până la cafenea. \n \nPrimul obiectiv al zilei este o experiență autentică de cafea în Oradea — Street Coffee Roasters (Piața Unirii). \n \n Această cafenea cu renume local și prăjitorie proprie aduce rafinamentul cafelei de specialitate în inima orașului și este locul perfect pentru a începe explorarea urbană. Street Coffee Roasters a fost creată din pasiune și dedicare pentru gustul adevărat al cafelei, selectând boabe atent alese din întreaga lume și prăjindu-le cu măiestrie chiar la Oradea. \n \n Atmosfera este primitoare și relaxată, ideală pentru o pauză de dimineață în Piața Unirii înainte de a porni spre obiectivele orașului, fiind aproape si de urmatorul obiectiv: Palatul Vulturul Negru"
    },
    "ziua1_walk_vulturul": {"hint": "La cativa pași distanță, traversezi strada si mergi spre partea pietonală care are un aspect de parc. Următorul obiectiv al traseului te duce în inima istoriei arhitecturale a Oradei — Palatul Vulturul Negru. \n \n Hint: Vă recomandăm să admirați clădirea din exterior, iar pe urmă să intrați prin acel 'tunel', unde puteți să priviți și mai îndeaproape frumusețea arhitecturală. \n \n Această clădire emblematică, ridicată între 1907–1908 de arhitecții maghiari Marcell Komor și Dezső Jakab, este considerată cea mai spectaculoasă capodoperă a stilului Secession / Art Nouveau din Transilvania. \n \n Situat în Piața Unirii, pe locul fostului han „Vulturul\" din secolul XVIII care găzduia evenimente publice importante, palatul impresionează prin fațada bogat ornamentată, vitraliul uriaș cu simbolul vulturului negru și pasajul său deosebit cu acoperiș de sticlă, inspirat de marile galerii europene. De-a lungul timpului, Palatul Vulturul Negru a fost un adevărat centru de viață urbană — găzduind hoteluri, cinematografe, spectacole, săli de bal, cafenele și magazine. \n \n Azi, acesta rămâne unul dintre cele mai iubite repere ale orașului, un loc perfect pentru fotografii, plimbări prin pasaj și pentru a simți pulsul cultural al centrului istoric. "},
    "ziua1_food_blackeagle" :{"hint": "Black Eagle Restaurant – Eleganță și gust în inima Oradei. \n \n Hint: Pentru a fi cât mai eficienți, am ales acest restaurant pentru micul dejun fiind situat chiar în zona emblematică a Palatului Vulturul Negru. \n \n Black Eagle Restaurant este locul ideal pentru o pauză savuroasă în timpul explorării orașului. Atmosfera elegantă, designul modern și meniul variat transformă fiecare vizită într-o experiență culinară deosebită. Black Eagle îți oferă gusturi rafinate și servicii de calitate, chiar în inima Oradei."},
    "ziua1_walk_unirii" :{"hint":"După micul dejun, continuăm plimbarea cu forțe proaspete, iar acum vom intra mai in profunzime in oraș.\n \n Piața Unirii este centrul istoric și simbolic al Oradei, un loc unde trecutul și prezentul se împletesc armonios. \n \n Zona a fost nucleul orașului încă din Evul Mediu, dezvoltându-se de-a lungul secolelor ca punct principal de întâlnire, comerț și viață publică. Astăzi, piața impresionează prin clădirile sale monumentale în stil Art Nouveau și eclectic, precum Palatul Episcopal Greco-Catolic, Primăria Oradea sau celebra Biserică cu Lună, unică în România datorită mecanismului său care indică fazele lunii.(Vom merge și la aceasta în curând) \n \n Cu atmosfera sa vibrantă, terasele elegante și evenimentele culturale frecvente, Piața Unirii rămâne un loc esențial pentru a înțelege spiritul și istoria Oradei."},
    "ziua1_walk_republicii" :{"hint":"Calea Republicii – Promenada istorică a Oradei \n \n Hint: Te afli in Piața Unirii. Ca să ajungi pe calea Republicii, traversează trecerea de pietoni de lângă stația de tramvai, traversează podul(unde din nou te vei întâlni cu un peisaj de poveste), și continuă pe trotoar până dai de Calea Republicii.(Folosește-te și de hartă) \n \nCalea Republicii este una dintre cele mai importante și pitorești artere ale Oradei, cu o istorie strâns legată de dezvoltarea orașului încă din secolele XVIII–XIX, când zona a început să se contureze ca principal drum comercial și de legătură între centrul orașului și cartierele în expansiune.\n \n La sfârșitul secolului al XIX-lea și începutul secolului XX, odată cu prosperitatea economică și dezvoltarea burgheziei locale, strada a devenit axa principală a vieții comerciale, culturale și sociale. În această perioadă au fost construite numeroase palate urbane, hoteluri și magazine elegante, multe dintre ele proiectate de arhitecți renumiți ai vremii. \n \n De-a lungul său se aliniază clădiri impresionante în stil Art Nouveau, Secession și eclectic, adevărate bijuterii arhitecturale care spun povestea Oradei de altădată. Astăzi, Calea Republicii este o zonă animată, plină de magazine, cafenele și spații culturale, ideală pentru plimbări relaxante și descoperirea farmecului urban al orașului."},
    "ziua1_walk_cetate" :{"hint": "Cetatea Oradea - Inima medievală a orașului \n \n Hint: Pentru a ajunge aici, va trebui sa reveniți la parcare pentru ca veți avea nevoie de mașină. Însă orașul este destul de mic, iar acest obiectiv nu este atât de departe. \n \n Cetatea Oradea este unul dintre cele mai valoroase monumente istorice din vestul României și un simbol al orașului încă din Evul Mediu. Primele fortificații au apărut aici în secolul al XI-lea, în jurul unei mănăstiri, iar de-a lungul secolelor cetatea a fost extinsă și transformată într-un important centru religios, cultural și militar. \n \n În secolele XVI–XVII, cetatea a fost reconstruită în stil renascentist, sub forma unei fortificații bastionare cu cinci colțuri, fiind considerată una dintre cele mai moderne fortărețe ale vremii. A rezistat numeroaselor asedii și a jucat un rol strategic major în istoria regiunii. \n \n Astăzi, Cetatea Oradea este un spațiu viu, complet restaurat, unde vizitatorii pot descoperi muzee, expoziții, ateliere, cafenele și evenimente culturale. Plimbarea prin curțile sale largi și printre zidurile vechi de sute de ani oferă o experiență autentică și o călătorie fascinantă în trecutul orașului."},
    "ziua1_food_meridian":{"hint": "Meridian Zero \n \n În incinta cetății, se află și acest restaurant Meridian Zero, unde vă sugerăm să cinați pentru o experiență inedită în interiorul cetății Oradea, încheind această zi într-o notă completă."},
    "ziua1_cafe_sip" :{"hint":"Opțional, dacă simți că mai ai nevoie de o pauză, poți savura o băutură la această cafenea, sau o mică gustare la to go. \n \nDe asemenea poți să alegi din varietatea teraselor ce se află pe Calea Republicii."},
    "ziua2_walk_zoo" :{"hint":"Grădina Zoologică Oradea – O oază verde pentru întreaga familie \n \n Grădina Zoologică din Oradea este un loc apreciat atât de turiști, cât și de localnici, fiind una dintre cele mai frumoase zone de relaxare ale orașului. Situată în apropierea centrului, în cadrul Parcului Bălcescu, aceasta oferă un spațiu verde generos, ideal pentru plimbări și momente de recreere.\n \n Înființată în anii ’60 și modernizată constant în ultimele decenii, grădina zoologică găzduiește numeroase specii de animale – de la lei, tigri și urși, până la maimuțe, păsări exotice și reptile. Spațiile sunt amenajate astfel încât să ofere condiții cât mai apropiate de mediul natural al animalelor.\n \n Astăzi, Grădina Zoologică din Oradea este mai mult decât un loc de vizitare: este un spațiu educativ și recreativ, perfect pentru familii cu copii, pentru iubitorii de natură și pentru oricine dorește o pauză liniștită în mijlocul orașului."},
    "ziua2_cafe_madam" :{"hint":" Madal Cafe \n \n Considerăm că un mod plăcut de a-ți începe ziua este la o cafenea de specialitate, pentru relaxare și conexiune mai bună cu orașul, însă decizia este de partea ta și poți trece peste dacă consideri altfel. \n \n Însă azi, venim cu o nouă recomandare de cafenea unde să îți incepi ziua, și anume Madal Cafe, situată pe Calea Republicii, obiectiv vizitat chiar ieri de către tine. \n \n Următorul obiectiv fiind Grădina Zoologică Oradea, poți să alegi și locația Street Coffee Roasters de la Parcul Științific, dacă dorești să fii mai aproape de Grădina Zoologică. Găsești toate locațiile cafenelelor, în pagina 'Cafenele'."},
    "ziua2_food_rivo":{"hint":"Rivo Restaurant – Rafinament și gust pe malul Crișului \n \n Hint: Între pauza dintre Grădina Zoologică și AquaPark, vă sugerăm să vă reîncărcați bateriile la acest restaurant elegant, mult apreciat de localnici. \n \n Rivo Restaurant este unul dintre cele mai apreciate restaurante din Oradea, cunoscut pentru combinația armonioasă dintre bucătăria rafinată, serviciile impecabile și amplasarea sa deosebită, pe malul Crișului Repede. Atmosfera elegantă și decorul modern îl transformă într-un loc ideal pentru mese speciale, întâlniri romantice sau cine relaxante. \n \n Meniul propune preparate atent gândite, inspirate din bucătăria internațională, realizate din ingrediente proaspete și prezentate cu atenție la detalii. Fie că vii pentru un prânz liniștit, o cină sofisticată sau un pahar de vin savurat la apus, Rivo oferă o experiență culinară completă, într-un cadru cu adevărat special."},
    "ziua2_strand_nymphaea": {"hint": "Aquapark Nymphaea – Relaxare și distracție la standarde europene \n \nAquapark Nymphaea este unul dintre cele mai moderne complexe de agrement din vestul României și o atracție importantă pentru turiștii care vizitează Oradea. Deschis în 2016, complexul a fost construit ca parte a strategiei de dezvoltare turistică a orașului, valorificând tradiția locală a apelor termale.\n \n Inspirat din mitologia nimfelor și din cultura balneară a zonei, aquapark-ul oferă piscine interioare și exterioare cu apă termală, tobogane spectaculoase, zone de relaxare, spa, saune și spații dedicate copiilor. Arhitectura modernă și ambientul plăcut creează un cadru ideal atât pentru distracție, cât și pentru odihnă.\n \n Astăzi, Aquapark Nymphaea este locul perfect pentru o pauză de relaxare în timpul explorării Oradei, fiind potrivit pentru familii, cupluri și grupuri de prieteni care caută o experiență completă de wellness și divertisment."},
    "ziua2_food_piata9":{"hint":"La finalul zilei, vă sugerăm restaurantul Piața 9, care vă va surprinde cu bunătățile din carne proaspătă și de calitate(lucru cu care se mândrește această locație), având la dispoziție diverse preparate, de la burgeri la o gamă variată de deserturi. \n \n Acest restaurant se află în Prima Shops, unde sunt mai multe magazine comerciale. Aveți posibilitatea să vă plimbați și să aveți un moment de Shopping."},
    "ziua3_cafe_ristretto":{"hint":"Ristretto Café este una dintre cafenelele apreciate din Oradea, cunoscută pentru atmosfera sa relaxantă și cafeaua de calitate. Situată într-o zonă accesibilă a orașului, cafeneaua este o oprire plăcută pentru localnici și turiști care își doresc un moment de respiro în timpul explorării urbane. \n \n Aici poți savura cafea de specialitate, băuturi aromate și deserturi gustoase, într-un ambient primitor și prietenos. Fie că vii pentru o întâlnire, pentru lucru sau pur și simplu pentru o pauză de relaxare, Ristretto Café oferă cadrul ideal pentru a te bucura de ritmul calm al orașului."},
    "ziua3_museum_tarii_crisurilor" :{"hint":"Hint: Aveți doua opțiuni. Fie o luați la pas de la cafenea până la muzeu, fiind la o distanță de doar 700m, sau dacă alegeți să mergeți cu mașina, există locuri de parcare pe marginea drumului vizavi de muzeu.\n \n Muzeul Țării Crișurilor este una dintre cele mai importante instituții culturale din vestul României, având un rol esențial în conservarea și promovarea patrimoniului istoric, artistic și natural al regiunii. Muzeul are o tradiție ce începe la sfârșitul secolului al XIX-lea, fiind astăzi găzduit într-o clădire modernizată, adaptată standardelor muzeale contemporane.\n \n Colecțiile sale sunt extrem de variate și includ exponate de arheologie, istorie, artă, etnografie și științele naturii, oferind vizitatorilor o perspectivă completă asupra evoluției zonei Crișanei. De la artefacte preistorice și medievale, până la artă modernă și tradiții populare, fiecare sală spune o poveste aparte.\n \n Muzeul Țării Crișurilor este un loc ideal pentru cei care doresc să înțeleagă mai profund identitatea culturală a Oradei și a regiunii, oferind o experiență educativă și captivantă pentru toate vârstele."},
    "ziua3_museum_francmasonerie":{"hint":"Fiind peste drum de Muzeul Țării Crișurilor, merită sa vizitați și acest muzeu. \n \n Templul Francmasoneriei din Oradea este una dintre clădirile cu cea mai aparte încărcătură simbolică din oraș, atrăgând atenția prin arhitectura sa neobișnuită și atmosfera misterioasă. Construit la începutul secolului XX, edificiul a fost sediul lojii masonice locale, într-o perioadă în care francmasoneria avea o influență importantă în viața culturală și intelectuală a orașului.\n \n Fațada clădirii este decorată cu elemente simbolice specifice masoneriei, precum compasul, echerul sau ochiul atotvăzător, detalii care îi sporesc farmecul și intrigă vizitatorii. Din punct de vedere arhitectural, construcția se înscrie în stilul eclectic, cu influențe Art Nouveau, integrându-se armonios în peisajul urban al Oradei.\n \n Astăzi, Templul Francmasoneriei reprezintă un punct de interes cultural și arhitectural, fiind un loc care invită la descoperirea unei pagini mai puțin cunoscute din istoria orașului."},
    "ziua3_food_rosecas": {"hint":"Hint: Tot la o distanță de 850m se afla restaurantul Rosecaș. Într-adevăr aici locurile de parcare sunt destul de limitate, pe marginea drumului principal. \n Restaurantul are meniul zilei de Luni - Vineri. \n \n Restaurant Rosecas este un loc bine cunoscut în Oradea, apreciat pentru bucătăria sa gustoasă și atmosfera primitoare. Cu o tradiție îndelungată în domeniul ospitalității, restaurantul a devenit de-a lungul timpului un reper pentru localnici și o descoperire plăcută pentru turiști.\n \n Meniul oferă preparate variate, inspirate atât din bucătăria tradițională românească, cât și din cea internațională, gătite cu atenție la calitatea ingredientelor și la gustul autentic. Decorul clasic și serviciile amabile creează un cadru potrivit pentru mese în familie, întâlniri relaxate sau evenimente speciale.\n \n Restaurant Rosecas rămâne o alegere sigură pentru cei care doresc să se bucure de mâncare bună și de o atmosferă caldă, într-un cadru cu tradiție în Oradea."},
    "ziua3_walk_biserica_cu_luna": {"hint":"Hint: Vă invităm să pășiți și în interior, respectând liniștea și atmosfera de reculegere. \n \n Biserica cu Lună este unul dintre cele mai cunoscute și fascinante monumente istorice ale Oradei, remarcată prin elementul său unic: mecanismul astronomic din turn care indică fazele reale ale lunii. Construită între anii 1784–1790, biserica poartă hramul „Adormirea Maicii Domnului\" și reprezintă un important lăcaș de cult al comunității ortodoxe din oraș.\n \n Arhitectura sa îmbină armonios stilul baroc cu elemente neoclasice, iar interiorul impresionează prin pictura murală bogată și atmosfera solemnă. Globul care reprezintă luna, vizibil pe fațada turnului, este pus în mișcare de un mecanism vechi de peste două secole, păstrat funcțional până astăzi.\n \n Biserica cu Lună nu este doar un loc de rugăciune, ci și un simbol al identității culturale a Oradei și o atracție deosebită pentru vizitatorii care doresc să descopere poveștile aparte ale orașului. "},
    "ziua3_walk_darvas": {"hint":"Casa Darvas–La Roche este unul dintre cele mai valoroase monumente de arhitectură Art Nouveau din România și un simbol al rafinamentului Oradei de la începutul secolului XX. Clădirea a fost construită între anii 1909–1912 la comanda familiei Darvas, după planurile arhitecților László și József Vágó, reprezentanți importanți ai curentului Secession.\n \n Fațada impresionează prin decorațiunile elegante, liniile fluide și motivele florale specifice stilului Art Nouveau, iar interiorul păstrează vitralii, mobilier și detalii decorative originale. Astăzi, clădirea funcționează ca centru de cultură urbană și muzeu Art Nouveau, oferind vizitatorilor ocazia de a descoperi atmosfera unei reședințe burgheze de acum mai bine de un secol.\n \n Casa Darvas–La Roche nu este doar un obiectiv arhitectural, ci o adevărată călătorie în epoca de aur a Oradei, fiind un loc de neratat pentru iubitorii de artă, istorie și frumos."},
    "ziua3_food_allegria": {"hint":"Restaurant Allegria – Gust italian cu suflet în Oradea \n \n Restaurant Allegria este un loc apreciat pentru atmosfera sa caldă și bucătăria inspirată din tradiția italiană. Cu un decor elegant și primitor, restaurantul oferă cadrul ideal pentru prânzuri relaxate, cine romantice sau întâlniri plăcute cu prietenii, chiar în inima orașului.\n \n Meniul pune accent pe preparate autentice italiene – paste proaspete, pizza gustoasă, fructe de mare și deserturi fine – realizate din ingrediente de calitate. Fie că alegi o cină specială sau o masă lejeră după o plimbare prin centru, Allegria îți oferă o experiență culinară plină de savoare și bună dispoziție."},
    "ziua4_cafe_semiramis":{"hint":"O cafenea bună, aproape de Primăria Oradea - important deoarece următoarea oprire va fi chiar la turnul Primăriei."},
    "ziua4_walk_turn_primarie":{"hint":"Hint: Intrați înăuntru și cumpărați un bilet de acces pentru a urca în turn. \n \n Turnul Primăriei face parte din impresionanta clădire a Primăriei, construită la începutul secolului XX. Edificiul a fost realizat între anii 1902–1903, în stil eclectic cu influențe neorenascentiste, reflectând prosperitatea orașului din acea perioadă.\n \n Cu o înălțime de aproximativ 50 de metri, turnul oferă una dintre cele mai frumoase priveliști asupra centrului istoric. După urcarea celor peste 250 de trepte sau cu ajutorul liftului modern, vizitatorii pot admira panorama Pieței Unirii, a Crișului Repede și a clădirilor Art Nouveau care definesc Oradea.\n \n Astăzi, Turnul Primăriei este o atracție turistică importantă și un punct ideal pentru fotografii memorabile, fiind o experiență de neratat pentru cei care doresc să vadă orașul de sus."},
    "ziua4_food_tochefs": {"hint":"Un restaurant aproape de turnul Primăriei Oradea, este To Chefs, care impresionează prin preparatele gustoase. \n \n To Chefs este alegerea perfectă pentru cei care doresc să descopere gusturi noi și să se bucure de gastronomie de calitate în Oradea."},
    "ziua4_walk_ciuperca": {"hint":"Hint: Parcurgeți tot traseul in coborâre, și urcare la pas. Veți găsi și băncuțe să vă așezați și să admirați peisajul. \n\nDealul Ciuperca este unul dintre cele mai îndrăgite locuri de belvedere din Oradea, oferind o panoramă spectaculoasă asupra orașului și împrejurimilor. Situat la marginea centrului, dealul reprezintă un spațiu perfect pentru plimbări relaxante, momente de liniște și fotografii memorabile, mai ales la apus.\n \n Zona a fost reamenajată și modernizată în ultimii ani, devenind un parc urban elegant, cu alei pietonale, puncte de belvedere, iluminat ambiental și zone de odihnă. Amenajarea sa pune în valoare atât cadrul natural, cât și legătura vizuală cu centrul istoric al orașului.\n\n Dealul Ciuperca este locul ideal pentru cei care doresc să îmbine natura cu descoperirea orașului, oferind o experiență diferită și un moment de respiro deasupra agitației urbane."},
    "ziua4_food_ciuperca_restaurant":{"hint":"După bunul plac, puteți alege să serviți un ceai la restaurantul Ciuperca, și nu oricum; cu un view aparte, desprind din povești, mai ales cand soarele apune."},
    "ziua4_food_enchante": {"hint":"Ca și cină, recomandăm Enchante Rooftop & Social Lounge. \n \n Acest restaurant impresionează prin estetică, vizualizarea orașului de la înălțime, și preparate. Este un restaurant de neratat dacă ajungi in Oradea. \n \n Hint: Această locație este la bază un Hotel. Pentru a ajunge sus la restaurant, folosiți liftul sau scările si urcați direct la Restaurant. Pentru mai multe detalii întrebați angajații hotelului cum sa ajungeți la Restaurant. "},
    "ziua5_food_dock":{"hint":"Relaxare modernă pe malul Crișului \n \n Dock Oradea este un spațiu urban modern și vibrant, situat pe malul Crișului Repede, care a devenit rapid un loc preferat de întâlnire pentru localnici și turiști. Cu un concept fresh și o atmosferă relaxată, Dock oferă cadrul perfect pentru a te bucura de oraș într-un mod diferit, mai aproape de apă și de natură.\n \n Locația îmbină zona de lounge, bar și socializare cu peisajul plăcut al râului, fiind ideală pentru o cafea liniștită, un cocktail la apus sau o seară petrecută cu prietenii. Designul contemporan și energia locului contribuie la farmecul său aparte.\n \n Dock Oradea reprezintă un exemplu reușit de revitalizare urbană și un punct de oprire perfect într-un traseu de explorare a orașului."},
    "ziua5_walk_malul_crisului" :{"hint":"Hint:Necesită doar o coborâre pe trepte de la restaurantul Dock, și puteți incepe plimbarea pe Malul Crișului. \n \n Promenada verde a orașului \n \n Malul Crișului Repede este unul dintre cele mai frumoase spații de promenadă din Oradea, un loc unde natura și orașul se împletesc armonios. Apele liniștite ale râului, aleile amenajate și peisajul urban elegant creează cadrul ideal pentru plimbări relaxante, alergare sau momente de respiro în mijlocul orașului.\n \n Zona a fost reamenajată și modernizată în ultimii ani, cu piste pentru biciclete, bănci, iluminat ambiental și spații verzi care invită la petrecerea timpului în aer liber. De-a lungul malurilor, se deschid perspective frumoase asupra clădirilor istorice, podurilor și cartierelor cochete ale Oradei.\n \nMalul Crișului Repede nu este doar un traseu de plimbare, ci o experiență care oferă o altă perspectivă asupra orașului, fiind un loc apreciat atât de turiști, cât și de localnici."},
    "ziua5_food_via29":{"hint":"Hint: În plimbare pe malul Crișului ajungeți la Restaurantul Botanic by Armonia. Folosiți harta pentru o mai bună orientare in spațiu. \n \nNatură, rafinament și gust în Oradea\n \nBotanic by Armonia este un loc aparte în peisajul culinar al Oradei, unde gastronomia modernă se îmbină armonios cu un decor inspirat din natură. Cu un ambient elegant, dominat de elemente vegetale și detalii atent alese, restaurantul oferă o experiență relaxantă și sofisticată.\n \nMeniul pune accent pe preparate creative, realizate din ingrediente proaspete și combinații echilibrate de arome, oferind opțiuni potrivite atât pentru iubitorii bucătăriei internaționale, cât și pentru cei care caută experiențe culinare speciale. Atmosfera calmă și designul verde fac din Botanic by Armonia un loc ideal pentru cine rafinate, întâlniri speciale sau momente de răsfăț.\n\nBotanic by Armonia este mai mult decât un restaurant – este o experiență senzorială care completează perfect un traseu prin Oradea."},
    "ziua5_walk_lotus":{"hint":"Shopping, distracție și relaxare în Oradea\n\nLotus Mall este cel mai mare și mai modern centru comercial din Oradea, fiind un punct important de atracție atât pentru localnici, cât și pentru turiști. Situat la intrarea în oraș, mall-ul oferă o experiență completă de petrecere a timpului liber, într-un spațiu modern și confortabil.\n\nAici găsești numeroase magazine de branduri internaționale și locale, restaurante și cafenele, cinema, zone de divertisment și spații dedicate copiilor. Este locul ideal pentru cumpărături, o pauză de relaxare după explorarea oraadei sau pentru petrecerea unei după-amiezi alături de familie și prieteni.\n\nLotus Mall completează perfect oferta urbană a Oradei, fiind un spațiu unde confortul modern se întâlnește cu dinamica orașului."},
    "ziua5_food_rewine":{"hint":"Vin, gust și atmosferă în Oradea\n\nReWine Bistro este un loc cochet și rafinat din Oradea, dedicat celor care apreciază vinul de calitate și mâncarea bine pregătită. Cu o atmosferă intimă și un decor modern, bistroul este alegerea perfectă pentru seri relaxante, întâlniri speciale sau momente petrecute în tihnă.\n\nMeniul propune preparate atent selecționate, care se potrivesc excelent cu selecția variată de vinuri românești și internaționale. Platourile, gustările fine și deserturile completează experiența, transformând fiecare vizită într-un moment de răsfăț.\n\nReWine Bistro este locul unde conversațiile curg natural, iar gustul bun se întâlnește cu eleganța, într-un cadru perfect pentru a descoperi o altă față a Oradei."},
  };

  // =========================
  // INIT
  // =========================
  @override
  void initState() {
    super.initState();
    _loadChecks();

    _swipeAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _maybeShowGlobalIntro();
    });
  }

  @override
  void dispose() {
    _swipeAnim.dispose();
    super.dispose();
  }

  // =========================
  // NAV BACK (home)
  // =========================
  PageRoute<T> _noAnimRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      opaque: true,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (_, __, ___) => page,
    );
  }

  void _goHomeRoot() {
    _hideLoading();
    Navigator.of(context).pushAndRemoveUntil(
      _noAnimRoute(HomePage()),
      (route) => false,
    );
  }

  // =========================
  // PREFS: checks
  // =========================
  Future<void> _loadChecks() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    if (!mounted) return;

    setState(() {
      for (final key in keys) {
        if (key.startsWith(_kActivityPrefix)) {
          checked[key] = prefs.getBool(key) ?? false;
        }
      }
    });
  }

  bool _isVisited(String id) => checked["$_kActivityPrefix$id"] ?? false;

  Future<void> _setVisited(String id, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("$_kActivityPrefix$id", value);

    if (!mounted) return;
    setState(() {
      checked["$_kActivityPrefix$id"] = value;
    });
  }

  // ✅ confirmare înainte de bifare
  Future<void> _confirmMarkVisited({
    required List activities,
    required int index,
    required String title,
  }) async {
    if (!mounted) return;

    await _showGlassConfirmDialog(
      title: "Marchezi ca bifat?",
      icon: Icons.check_circle_rounded,
      accent: kAccentSuccess,
      message:
          "Ești sigur că vrei să marchezi ca bifat acest obiectiv?\n\n"
          "„$title\"\n\n"
          "Bifarea rămâne valabilă până când faci Reset pentru ziua curentă.",
      confirmText: "Da, bifează",
      cancelText: "Nu",
      confirmColor: kAccentSuccess,
      onConfirm: () async {
        await _tryMarkVisitedInOrder(activities: activities, index: index);
      },
    );
  }

  // ✅ ordine: doar NEXT poate fi bifat
  Future<void> _tryMarkVisitedInOrder({
    required List activities,
    required int index,
  }) async {
    if (activities.isEmpty) return;
    final act = activities[index] as Map<String, dynamic>;
    final id = _s(act["id"]);

    if (_isVisited(id)) return;

    for (int i = 0; i < index; i++) {
      final prev = activities[i] as Map<String, dynamic>;
      final prevId = _s(prev["id"]);
      if (!_isVisited(prevId)) {
        await _showOrderWarningDialog();
        return;
      }
    }

    await _setVisited(id, true);
    _markerIconCache.clear();
  }

  Future<void> _showOrderWarningDialog() async {
    await _showGlassDialog(
      title: "Bifează pe rând",
      icon: Icons.tips_and_updates_rounded,
      accent: kAccentGuide,
      child: Text(
        "Ca să păstrăm traseul optim, obiectivele trebuie bifate în ordine.\n\n"
        "Te rugăm să bifezi mai întâi următorul obiectiv din traseu.",
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          height: 1.35,
          color: Colors.black.withOpacity(0.75),
        ),
      ),
      primaryText: "Am înțeles",
      primaryColor: kAccentGuide,
    );
  }

  // =========================
  // RESET LOGIC (max 1 / zi)
  // =========================
  Future<int> _getResetCountForDay(int day) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kResetCountKey(day)) ?? 0;
  }

  Future<void> _incrementResetCountForDay(int day) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_kResetCountKey(day)) ?? 0;
    await prefs.setInt(_kResetCountKey(day), current + 1);
  }

  Future<void> _resetDayRoute(List activities) async {
    final prefs = await SharedPreferences.getInstance();
    for (final a in activities) {
      final act = a as Map<String, dynamic>;
      final id = _s(act["id"]);
      await prefs.remove("$_kActivityPrefix$id");
    }

    if (!mounted) return;
    setState(() {
      for (final a in activities) {
        final act = a as Map<String, dynamic>;
        final id = _s(act["id"]);
        checked.remove("$_kActivityPrefix$id");
      }
    });

    _markerIconCache.clear();
  }

  Future<void> _confirmResetDay(List activities) async {
    final count = await _getResetCountForDay(selectedDay);

    if (count >= 1) {
      await _showGlassDialog(
        title: "Reset indisponibil",
        icon: Icons.lock_rounded,
        accent: kAccentGuide,
        child: Text(
          "Poți repeta traseul o singură dată.\n\n"
          "Ai folosit deja resetarea pentru Ziua $selectedDay.",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            height: 1.35,
            color: Colors.black.withOpacity(0.75),
          ),
        ),
        primaryText: "Am înțeles",
        primaryColor: kAccentGuide,
      );
      return;
    }

    await _showGlassConfirmDialog(
      title: "Resetezi traseul?",
      icon: Icons.warning_rounded,
      accent: kAccentDanger,
      message:
          "Ești sigur că vrei să resetezi Ziua $selectedDay?\n\n"
          "Vei putea reseta o singură dată (pentru a repeta traseul).",
      confirmText: "Da, resetează",
      cancelText: "Nu",
      confirmColor: kAccentDanger,
      onConfirm: () async {
        await _incrementResetCountForDay(selectedDay);
        await _resetDayRoute(activities);
      },
    );
  }

  // =========================
  // GLOBAL INTRO
  // =========================
  Future<void> _maybeShowGlobalIntro() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool(_kPrefIntro) ?? false;

    if (!mounted) return;

    if (shown) {
      setState(() => _gateDaysVisible = true);
      return;
    }

    setState(() => _gateDaysVisible = false);

    await _showGlassDialog(
      title: "Trasee pe zile",
      icon: Icons.auto_awesome_rounded,
      accent: kPrimary,
      child: Text(
        "Aici găsești trasee gata făcute, zi cu zi.\n\n"
        "• Apasă Deschide pe o zi ca să începi.\n"
        "• În ziua aleasă ai carduri mari (swipe) pentru fiecare obiectiv.\n"
        "• Bifează „Bifat\" în ordine, după ce ai vizitat.\n"
        "• Poți reseta o zi o singură dată (ca să repeți traseul).",
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          height: 1.35,
          color: Colors.black.withOpacity(0.75),
        ),
      ),
      primaryText: "Am înțeles",
      primaryColor: kPrimary,
      onPrimary: () async {
        final p = await SharedPreferences.getInstance();
        await p.setBool(_kPrefIntro, true);
      },
    );

    if (!mounted) return;
    setState(() => _gateDaysVisible = true);
  }

  // =========================
  // DAY INTRO
  // =========================
  Future<void> _maybeShowDayIntro(int dayIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool(_kPrefDayIntro(dayIndex)) ?? false;
    if (!mounted) return;
    if (shown) return;

    final day = TraseuData.getDay(dayIndex);
    final activities = (day["activities"] as List?) ?? const [];

    final controller = PageController();
    int page = 0;

    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.45),
      barrierLabel: "day_intro",
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, anim, __, ___) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return Opacity(
          opacity: anim.value,
          child: Transform.scale(
            scale: 0.97 + (0.03 * curved.value),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                    child: Material(
                      color: AppTheme.isDarkGlobal ? const Color(0xFF1C1C1E) : Colors.white.withOpacity(0.90),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 620),
                        child: StatefulBuilder(
                          builder: (context, setLocal) {
                            final total = activities.length.clamp(1, 50);
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 46,
                                        height: 46,
                                        decoration: BoxDecoration(
                                          color: kPrimary.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: kPrimary.withOpacity(0.18)),
                                        ),
                                        child: const Icon(Icons.route_rounded, color: kPrimary),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          "Ziua $dayIndex • Rezumat",
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            color: AppTheme.isDarkGlobal ? Colors.white : kText,
                                          ),
                                        ),
                                      ),
                                      _dotsIndicator(page: page, total: total),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),
                                Expanded(
                                  child: PageView.builder(
                                    controller: controller,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: total,
                                    onPageChanged: (i) => setLocal(() => page = i),
                                    itemBuilder: (context, i) {
                                      final act = activities[i] as Map<String, dynamic>;
                                      final title = _s(act["title"]);
                                      final hour = _s(act["hour"]);
                                      final type = _s(act["type"]);
                                      final imagePath = act["image"];
                                      final hint = _extraFor(act)["hint"] ?? "";

                                      return Padding(
                                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(22),
                                                child: Stack(
                                                  children: [
                                                    Positioned.fill(
                                                      child: (imagePath is String && imagePath.isNotEmpty)
                                                          ? Image.asset(
                                                              imagePath,
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (_, __, ___) => Container(
                                                                color: Colors.black.withOpacity(0.06),
                                                                child: const Center(child: Icon(Icons.image_not_supported)),
                                                              ),
                                                            )
                                                          : Container(
                                                              color: Colors.black.withOpacity(0.06),
                                                              child: const Center(child: Icon(Icons.photo_outlined)),
                                                            ),
                                                    ),
                                                    Positioned.fill(
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            begin: Alignment.bottomLeft,
                                                            end: Alignment.topRight,
                                                            colors: [
                                                              Colors.black.withOpacity(0.72),
                                                              Colors.black.withOpacity(0.10),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      left: 14,
                                                      right: 14,
                                                      bottom: 14,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Container(
                                                                width: 34,
                                                                height: 34,
                                                                decoration: BoxDecoration(
                                                                  color: Colors.white.withOpacity(0.18),
                                                                  borderRadius: BorderRadius.circular(14),
                                                                  border: Border.all(color: Colors.white.withOpacity(0.24)),
                                                                ),
                                                                child: Center(child: _iconForType(type, color: Colors.white)),
                                                              ),
                                                              const SizedBox(width: 10),
                                                              Expanded(
                                                                child: Text(
                                                                  title,
                                                                  maxLines: 2,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  style: const TextStyle(
                                                                    fontFamily: 'Poppins',
                                                                    fontSize: 18,
                                                                    fontWeight: FontWeight.w900,
                                                                    color: Colors.white,
                                                                    height: 1.1,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(height: 8),
                                                          Row(
                                                            children: [
                                                              const Icon(Icons.schedule_rounded, color: Colors.white70, size: 16),
                                                              const SizedBox(width: 6),
                                                              Text(
                                                                hour,
                                                                style: const TextStyle(
                                                                  fontFamily: 'Poppins',
                                                                  fontSize: 13,
                                                                  fontWeight: FontWeight.w700,
                                                                  color: Colors.white70,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          if (hint.isNotEmpty) ...[
                                                            const SizedBox(height: 8),
                                                            LayoutBuilder(
                                                              builder: (context, constraints) {
                                                                final style = TextStyle(
                                                                  fontFamily: 'Poppins',
                                                                  fontSize: 13,
                                                                  fontWeight: FontWeight.w600,
                                                                  color: AppTheme.isDarkGlobal ? const Color(0xFF1C1C1E) : Colors.white.withOpacity(0.90),
                                                                  height: 1.25,
                                                                );

                                                                final hasMore = _isTextOverflow(
                                                                  text: hint,
                                                                  style: style,
                                                                  maxWidth: constraints.maxWidth,
                                                                  maxLines: 3, // ✅ 3 rânduri
                                                                );

                                                                return GestureDetector(
                                                                  behavior: HitTestBehavior.opaque,
                                                                  onTap: () => _showHintSheet(
                                                                    title: title,
                                                                    hint: hint,
                                                                  ),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        hint,
                                                                        maxLines: 3, // ✅ 3 rânduri
                                                                        overflow: TextOverflow.ellipsis,
                                                                        style: style,
                                                                      ),
                                                                      if (hasMore) ...[
                                                                        const SizedBox(height: 6),
                                                                        Row(
                                                                          mainAxisSize: MainAxisSize.min,
                                                                          children: [
                                                                            Text(
                                                                              "Mai mult",
                                                                              style: TextStyle(
                                                                                fontFamily: 'Poppins',
                                                                                fontSize: 12.6,
                                                                                fontWeight: FontWeight.w900,
                                                                                color: AppTheme.isDarkGlobal ? const Color(0xFF1C1C1E) : Colors.white.withOpacity(0.92),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(width: 6),
                                                                            Icon(
                                                                              Icons.keyboard_arrow_up_rounded,
                                                                              size: 18,
                                                                              color: AppTheme.isDarkGlobal ? const Color(0xFF1C1C1E) : Colors.white.withOpacity(0.92),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton(
                                                    onPressed: () async {
                                                      final p = await SharedPreferences.getInstance();
                                                      await p.setBool(_kPrefDayIntro(dayIndex), true);
                                                      if (context.mounted) Navigator.of(context).pop();
                                                    },
                                                    style: OutlinedButton.styleFrom(
                                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                      side: BorderSide(color: Colors.black.withOpacity(0.12)),
                                                    ),
                                                    child: Text(
                                                      "Sari peste",
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontWeight: FontWeight.w800,
                                                        color: Colors.black.withOpacity(0.75),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () async {
                                                      if (page < total - 1) {
                                                        controller.nextPage(
                                                          duration: const Duration(milliseconds: 260),
                                                          curve: Curves.easeOutCubic,
                                                        );
                                                        return;
                                                      }
                                                      final p = await SharedPreferences.getInstance();
                                                      await p.setBool(_kPrefDayIntro(dayIndex), true);
                                                      if (context.mounted) Navigator.of(context).pop();
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: kPrimary,
                                                      foregroundColor: Colors.white,
                                                      elevation: 0,
                                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                    ),
                                                    child: Text(
                                                      page < total - 1 ? "Next" : "Am înțeles",
                                                      style: const TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontWeight: FontWeight.w900,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _dotsIndicator({required int page, required int total}) {
    final shown = total.clamp(1, 6);
    final start = (page - (shown ~/ 2)).clamp(0, (total - shown).clamp(0, 999));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(shown, (i) {
        final idx = start + i;
        final active = idx == page;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(left: 6),
          width: active ? 16 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active ? kPrimary : Colors.black.withOpacity(0.18),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }

  // =========================
  // COORDS for selected day
  // =========================
  Map<String, LatLng> _coordsForCurrentDay() {
    switch (selectedDay) {
      case 1:
        return _coordsZiua1;
      case 2:
        return _coordsZiua2;
      case 3:
        return _coordsZiua3;
      case 4:
        return _coordsZiua4;
      case 5:
        return _coordsZiua5;
      default:
        return _coordsZiua1;
    }
  }

  // =========================
  // EXTRA
  // =========================
  Map<String, String> _extraFor(Map<String, dynamic> act) {
    final id = _s(act["id"]);
    final type = _s(act["type"]);
    final byId = _extraInfoById[id];
    if (byId != null) return byId;

    switch (type) {
      case "cafe":
        return {"hint": "Începe ușor: cafea + plan pe zi."};
      case "museum":
        return {"hint": "Moment cultural, ritm relaxat."};
      case "food":
        return {"hint": "Pauză de reîncărcare."};
      case "walk":
        return {"hint": "Plimbare lejeră, poze bune."};
      case "strand":
        return {"hint": "Relax și apă."};
      default:
        return {"hint": ""};
    }
  }

  // =========================
  // FIRESTORE: fetch by docId
  // =========================
  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> _getDocById({
    required String collection,
    required String docId,
  }) async {
    final qs = await FirebaseFirestore.instance
        .collection(collection)
        .where(FieldPath.documentId, isEqualTo: docId)
        .limit(1)
        .get();

    if (qs.docs.isEmpty) return null;
    return qs.docs.first;
  }

  // =========================
  // OPEN DETAILS (in-app)
  // =========================
  Future<void> _openDetailsForActivity(Map<String, dynamic> act) async {
    final String type = _s(act["type"]);
    final String title = _s(act["title"]).trim();
    final String collection = _s(act["collection"]).trim();
    final String docId = _s(act["docId"]).trim();

    if (title.isEmpty) return;

    if (collection.isEmpty || docId.isEmpty) {
      _toast("Lipsește collection/docId pentru „$title\".");
      return;
    }

    _showLoading();
    try {
      final doc = await _getDocById(collection: collection, docId: docId);

      if (!mounted) return;

      if (doc == null) {
        _hideLoading();
        _toast("Nu am găsit: $collection / $docId");
        return;
      }

      final data = doc.data();
      _hideLoading();
      if (!mounted) return;

      if (type == "cafe") {
        final cafe = Cafenea.fromFirestore(doc);
        Navigator.push(context, MaterialPageRoute(builder: (_) => CafeneaDetaliiPage(cafe: cafe)));
        return;
      }

      if (type == "food") {
        final restaurant = Restaurant.fromFirestore(doc);
        Navigator.push(context, MaterialPageRoute(builder: (_) => RestaurantDetaliiPage(restaurant: restaurant)));
        return;
      }

      if (type == "museum") {
        final muzeu = Muzeu.fromFirestore(doc);
        Navigator.push(context, MaterialPageRoute(builder: (_) => MuzeuDetaliiPage(muzeu: muzeu)));
        return;
      }

      if (type == "walk") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WalksDetaliiPage(
              walkId: doc.id,
              title: _s(data["title"]),
            ),
          ),
        );
        return;
      }

      if (type == "strand") {
        final strandId = doc.id;
        final strandTitle = _s(data["title"]).isEmpty ? title : _s(data["title"]);

        try {
          await Navigator.of(context).pushNamed(
            _kStrandDetailsRoute,
            arguments: {"strandId": strandId, "title": strandTitle},
          );
          return;
        } catch (_) {
          final coords = _coordsForCurrentDay();
          final LatLng? c = coords[_s(act["id"])];
          if (c != null) {
            await _openExternalMaps(c, strandTitle);
            return;
          }
          _toast("Nu pot deschide pagina strandului. Verifică ruta $_kStrandDetailsRoute.");
          return;
        }
      }

      _toast("Tip necunoscut: $type");
    } catch (e) {
      if (!mounted) return;
      _hideLoading();
      _toast("Eroare: $e");
    }
  }

  // =========================
  // MAPS external
  // =========================
  Future<void> _openExternalMaps(LatLng target, String title) async {
    final googleUrl = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=${target.latitude},${target.longitude}",
    );

    final appleUrl = Uri.parse(
      "http://maps.apple.com/?daddr=${target.latitude},${target.longitude}&q=$title",
    );

    if (Platform.isIOS) {
      if (await canLaunchUrl(appleUrl)) {
        await launchUrl(appleUrl, mode: LaunchMode.externalApplication);
        return;
      }
    }
    await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
  }

  // =========================
  // Map helpers
  // =========================
  int _checkedCount(List activities) {
    int c = 0;
    for (final a in activities) {
      final id = _s((a as Map<String, dynamic>)["id"]);
      if (_isVisited(id)) c++;
    }
    return c;
  }

  int _nextUnvisitedIndex(List activities) {
    for (int i = 0; i < activities.length; i++) {
      final act = activities[i] as Map<String, dynamic>;
      final id = _s(act["id"]);
      if (!_isVisited(id)) return i;
    }
    return -1;
  }

  // =========================
  // COACH MARKS / POPUPS TUTORIAL (O SINGURĂ DATĂ TOTAL)
  // =========================
  Rect? _globalRectForKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final ro = ctx.findRenderObject();
    if (ro is! RenderBox) return null;
    final topLeft = ro.localToGlobal(Offset.zero);
    return topLeft & ro.size;
  }

  Future<void> _maybeShowCoachTutorialOnce() async {
    if (!mounted) return;
    if (_coachIsShowing) return;

    final prefs = await SharedPreferences.getInstance();

    // ✅ dacă user-ul a văzut tutorialul pe orice zi, nu-l mai arătăm niciodată
    final shownGlobal = prefs.getBool(_kPrefCoachOnce) ?? false;

    // ✅ fallback: dacă ai avut versiunea veche "o dată pe zi", considerăm că e deja văzut
    final legacyAny = prefs.getBool(_kPrefDayCoachLegacy(1)) == true ||
        prefs.getBool(_kPrefDayCoachLegacy(2)) == true ||
        prefs.getBool(_kPrefDayCoachLegacy(3)) == true ||
        prefs.getBool(_kPrefDayCoachLegacy(4)) == true ||
        prefs.getBool(_kPrefDayCoachLegacy(5)) == true;

    if (shownGlobal || legacyAny) {
      if (!shownGlobal) {
        // normalizează: setează cheia globală ca să nu mai facă calcule pe viitor
        await prefs.setBool(_kPrefCoachOnce, true);
      }
      return;
    }

    await Future.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;

    if (_globalRectForKey(_coachCheckKey) == null ||
        _globalRectForKey(_coachDirectionsKey) == null ||
        _globalRectForKey(_coachSeeKey) == null ||
        _globalRectForKey(_coachStatusKey) == null ||
        _globalRectForKey(_coachResetKey) == null ||
        _globalRectForKey(_coachMapKey) == null) {
      await Future.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
    }

    _coachIsShowing = true;

    final steps = <_CoachStep>[
      _CoachStep(
        key: _coachCheckKey,
        title: "Butonul „Bifat\"",
        message:
            "După ce ai vizitat obiectivul, apasă aici ca să îl marchezi ca bifat.\n\n"
            "Notă: trebuie să bifezi obiectivele în ordine.",
        accent: kAccentSuccess,
        icon: Icons.check_circle_rounded,
      ),
      _CoachStep(
        key: _coachDirectionsKey,
        title: "Butonul „Direcții\"",
        message:
            "Aici primești direcții către obiectiv. La apăsare se deschide aplicația de hărți cu ruta până la destinație.",
        accent: kAccentMaps,
        icon: Icons.navigation_rounded,
      ),
      _CoachStep(
        key: _coachSeeKey,
        title: "Butonul „Vezi\"",
        message: "Deschide detaliile obiectivului (descriere, info utile, etc.).",
        accent: kPrimary,
        icon: Icons.open_in_new_rounded,
      ),
      _CoachStep(
        key: _coachStatusKey,
        title: "Starea „Vizitat / Nevizitat\"",
        message: "Aici vezi rapid dacă obiectivul este bifat (vizitat) sau încă nevizitat.",
        accent: Colors.white,
        icon: Icons.verified_rounded,
      ),
      _CoachStep(
        key: _coachResetKey,
        title: "Butonul „Reset\"",
        message:
            "Poți reseta progresul zilei ca să repeți traseul.\n\n"
            "Important: resetarea este disponibilă doar o singură dată pe zi.",
        accent: kAccentDanger,
        icon: Icons.restart_alt_rounded,
      ),
      _CoachStep(
        key: _coachMapKey,
        title: "Butonul „Hartă\"",
        message:
            "Deschide harta zilei ca să vezi mai clar traseul tău (ordine, markere, progres pe rută).",
        accent: kAccentMaps,
        icon: Icons.map_rounded,
      ),
    ];

    for (int i = 0; i < steps.length; i++) {
      if (!mounted) break;

      final rect = _globalRectForKey(steps[i].key);
      if (rect == null) continue;

      final isLast = i == steps.length - 1;
      await _showCoachPopup(
        target: rect,
        title: steps[i].title,
        message: steps[i].message,
        icon: steps[i].icon,
        accent: steps[i].accent,
        buttonText: isLast ? "Gata" : "Următorul",
      );
    }

    if (mounted) {
      // ✅ marchează tutorialul ca văzut global (o singură dată)
      await prefs.setBool(_kPrefCoachOnce, true);
    }

    _coachIsShowing = false;
  }

  Future<void> _showCoachPopup({
    required Rect target,
    required String title,
    required String message,
    required IconData icon,
    required Color accent,
    required String buttonText,
  }) async {
    if (!mounted) return;

    final mq = MediaQuery.of(context);
    final size = mq.size;
    const double bubbleMaxW = 520;
    const double padding = 16;

    final bool placeAbove = target.center.dy > size.height * 0.55;
    final double bubbleW = (size.width - padding * 2).clamp(280.0, bubbleMaxW);

    double left = (target.center.dx - bubbleW / 2).clamp(padding, size.width - bubbleW - padding);

    const double bubbleH = 210;

    double top;
    if (placeAbove) {
      top = (target.top - bubbleH - 14).clamp(padding, size.height - bubbleH - padding);
    } else {
      top = (target.bottom + 14).clamp(padding, size.height - bubbleH - padding);
    }

    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "coach",
      barrierColor: Colors.black.withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, __, ___) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return Opacity(
          opacity: anim.value,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _CoachPainter(
                    target: target,
                    glow: Colors.white.withOpacity(0.92),
                    dim: Colors.black.withOpacity(0.55),
                  ),
                ),
              ),
              Positioned(
                left: left,
                top: top,
                width: bubbleW,
                child: Transform.scale(
                  scale: 0.98 + (0.02 * curved.value),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                      child: Material(
                        color: AppTheme.isDarkGlobal ? const Color(0xFF1C1C1E) : Colors.white.withOpacity(0.92),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: (accent == Colors.white ? kPrimary : accent).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: (accent == Colors.white ? kPrimary : accent).withOpacity(0.18),
                                      ),
                                    ),
                                    child: Icon(icon, color: (accent == Colors.white ? kPrimary : accent)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.isDarkGlobal ? Colors.white : kText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                message,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  height: 1.35,
                                  color: Colors.black.withOpacity(0.76),
                                ),
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: (accent == Colors.white ? kPrimary : accent),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: Text(
                                    buttonText,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13.6,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================
  // MARKER ICON (MIC, estetic, lângă obiectiv)
  // =========================
  Future<BitmapDescriptor> _markerIconCompact({
    required int number,
    required String title,
    required Color textColor,
  }) async {
    final key = "tiny|$number|$title|${textColor.value}";
    final cached = _markerIconCache[key];
    if (cached != null) return cached;

    const double w = 150;
    const double h = 58;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, w, h));

    final shadowPaint = Paint()..color = const Color(0x1A000000);
    final rShadow = RRect.fromRectAndRadius(
      const Rect.fromLTWH(10, 6, w - 20, 32),
      const Radius.circular(14),
    );
    canvas.drawRRect(rShadow, shadowPaint);

    final pillPaint = Paint()..color = const Color(0xF2FFFFFF);
    final rPill = RRect.fromRectAndRadius(
      const Rect.fromLTWH(8, 4, w - 16, 32),
      const Radius.circular(14),
    );
    canvas.drawRRect(rPill, pillPaint);

    final circleBg = Paint()..color = Colors.white;
    final circleStroke = Paint()
      ..color = textColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const cx = 26.0;
    const cy = 20.0;
    canvas.drawCircle(const Offset(cx, cy), 10, circleBg);
    canvas.drawCircle(const Offset(cx, cy), 10, circleStroke);

    final numPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: number.toString(),
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
          color: textColor,
        ),
      ),
    )..layout();
    numPainter.paint(canvas, Offset(cx - numPainter.width / 2, cy - numPainter.height / 2));

    final titlePainter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: "…",
      text: TextSpan(
        text: title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 9.8,
          fontWeight: FontWeight.w900,
          color: Colors.black.withOpacity(0.78),
        ),
      ),
    )..layout(maxWidth: w - 54);
    titlePainter.paint(canvas, const Offset(42, 12));

    final dotShadow = Paint()..color = const Color(0x12000000);
    final dot = Paint()..color = textColor.withOpacity(0.95);
    canvas.drawCircle(Offset(w / 2, 46), 6.3, dotShadow);
    canvas.drawCircle(Offset(w / 2, 44.8), 5.6, dot);

    final picture = recorder.endRecording();
    final img = await picture.toImage(w.toInt(), h.toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    final descriptor = BitmapDescriptor.bytes(bytes!.buffer.asUint8List());

    _markerIconCache[key] = descriptor;
    return descriptor;
  }

  // =========================
  // MAP: show route sheet (glass)
  // =========================
  Future<void> _showMapSheetForDay(List activities) async {
    final coords = _coordsForCurrentDay();
    final nextIdx = _nextUnvisitedIndex(activities);

    final List<LatLng> routePoints = [];
    final List<bool> visited = [];

    for (final a in activities) {
      final act = a as Map<String, dynamic>;
      final id = _s(act["id"]);
      final c = coords[id];
      if (c != null) {
        routePoints.add(c);
        visited.add(_isVisited(id));
      }
    }

    if (routePoints.isEmpty) {
      _toast("Nu există coordonate pentru ziua asta.");
      return;
    }

    final int lastVisitedIndex = visited.lastIndexWhere((v) => v);

    final Set<Polyline> polylines = {
      Polyline(
        polylineId: const PolylineId("full"),
        points: routePoints,
        width: 4,
        color: Colors.black.withOpacity(0.18),
      ),
    };

    if (lastVisitedIndex >= 1) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId("visited"),
          points: routePoints.sublist(0, lastVisitedIndex + 1),
          width: 6,
          color: kAccentSuccess,
        ),
      );
    }

    final markers = <Marker>{};
    for (int i = 0; i < activities.length; i++) {
      final act = activities[i] as Map<String, dynamic>;
      final id = _s(act["id"]);
      final c = coords[id];
      if (c == null) continue;

      final isNext = (i == nextIdx);
      final color = isNext ? kAccentSuccess : kAccentDanger;

      final icon = await _markerIconCompact(
        number: i + 1,
        title: _s(act["title"]),
        textColor: color,
      );

      markers.add(
        Marker(
          markerId: MarkerId(id),
          position: c,
          icon: icon,
          anchor: const Offset(0.5, 0.97),
          onTap: () async => _openExternalMaps(c, _s(act["title"])),
        ),
      );
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: false,
      showDragHandle: false,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: Material(
                color: AppTheme.isDarkGlobal ? const Color(0xFF1C1C1E) : Colors.white.withOpacity(0.82),
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                        child: Row(
                          children: [
                            _glassIconBadge(icon: Icons.map_rounded, tint: kAccentMaps),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Hartă • Ziua $selectedDay",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.isDarkGlobal ? Colors.white : kText,
                                ),
                              ),
                            ),
                            _glassCloseButton(onTap: () => Navigator.of(context).pop()),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.70),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: Colors.black.withOpacity(0.08)),
                              ),
                              child: Text(
                                nextIdx >= 0 ? "Următorul: ${nextIdx + 1}" : "Totul bifat",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12.6,
                                  color: nextIdx >= 0 ? kAccentSuccess : Colors.black.withOpacity(0.75),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "Apasă pe marker pentru direcții",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                fontSize: 12.6,
                                color: Colors.black.withOpacity(0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.62,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: routePoints.first,
                              zoom: 13.2,
                            ),
                            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                              Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
                            },
                            zoomControlsEnabled: false,
                            myLocationEnabled: false,
                            myLocationButtonEnabled: false,
                            markers: markers,
                            polylines: polylines,
                            onMapCreated: (controller) {
                              AppTheme.applyMapStyle(controller);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // =========================
  // LOADING
  // =========================
  void _showLoading() {
    if (_isLoadingShown) return;
    _isLoadingShown = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _hideLoading() {
    if (!_isLoadingShown) return;
    _isLoadingShown = false;
    final nav = Navigator.of(context, rootNavigator: true);
    if (nav.canPop()) nav.pop();
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  String _s(dynamic v) => (v ?? "").toString();
  double _clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);

  // =========================
  // ✅ HINT OVERFLOW + SHEET
  // =========================
  bool _isTextOverflow({
    required String text,
    required TextStyle style,
    required double maxWidth,
    required int maxLines,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      ellipsis: "…",
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    return tp.didExceedMaxLines;
  }

  Future<void> _showHintSheet({
    required String title,
    required String hint,
  }) async {
    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      showDragHandle: false,
      builder: (_) {
        final mq = MediaQuery.of(context);
        return Padding(
          padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + mq.viewInsets.bottom),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: Material(
                color: AppTheme.isDarkGlobal ? const Color(0xFF1C1C1E) : Colors.white.withOpacity(0.86),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                        child: Row(
                          children: [
                            _glassIconBadge(icon: Icons.notes_rounded, tint: kPrimary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.isDarkGlobal ? Colors.white : kText,
                                ),
                              ),
                            ),
                            _glassCloseButton(onTap: () => Navigator.of(context).pop()),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                          child: Text(
                            hint,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.8,
                              fontWeight: FontWeight.w600,
                              height: 1.40,
                              color: AppTheme.isDarkGlobal
                                  ? Colors.white
                                  : Colors.black.withOpacity(0.78),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // =========================
  // GLASS DIALOG (1 button)
  // =========================
  Future<void> _showGlassDialog({
    required String title,
    required IconData icon,
    required Color accent,
    required Widget child,
    required String primaryText,
    required Color primaryColor,
    Future<void> Function()? onPrimary,
  }) async {
    if (!mounted) return;

    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "dialog",
      barrierColor: Colors.black.withOpacity(0.40),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, anim, __, ___) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return Opacity(
          opacity: anim.value,
          child: Transform.scale(
            scale: 0.97 + (0.03 * curved.value),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                    child: Material(
                      color: AppTheme.isDarkGlobal ? const Color(0xFF1C1C1E) : Colors.white.withOpacity(0.90),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: accent.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: accent.withOpacity(0.18)),
                                    ),
                                    child: Icon(icon, color: accent),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.isDarkGlobal ? Colors.white : kText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              child,
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    if (onPrimary != null) await onPrimary();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: Text(
                                    primaryText,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13.8,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // =========================
  // GLASS CONFIRM (2 buttons)
  // =========================
  Future<void> _showGlassConfirmDialog({
    required String title,
    required IconData icon,
    required Color accent,
    required String message,
    required String confirmText,
    required String cancelText,
    required Color confirmColor,
    required Future<void> Function() onConfirm,
  }) async {
    if (!mounted) return;

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "confirm",
      barrierColor: Colors.black.withOpacity(0.40),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, anim, __, ___) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return Opacity(
          opacity: anim.value,
          child: Transform.scale(
            scale: 0.97 + (0.03 * curved.value),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                    child: Material(
                      color: AppTheme.isDarkGlobal ? const Color(0xFF1C1C1E) : Colors.white.withOpacity(0.90),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: accent.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: accent.withOpacity(0.18)),
                                    ),
                                    child: Icon(icon, color: accent),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.isDarkGlobal ? Colors.white : kText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                message,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  height: 1.35,
                                  color: Colors.black.withOpacity(0.75),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        side: BorderSide(color: Colors.black.withOpacity(0.12)),
                                      ),
                                      child: Text(
                                        cancelText,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w900,
                                          color: Colors.black.withOpacity(0.75),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        await onConfirm();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: confirmColor,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                      child: Text(
                                        confirmText,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // =========================
  // BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goHomeRoot();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.isDarkGlobal ? Colors.black : kBg,
        body: SafeArea(
          // ✅ FIX: scoate complet padding-ul de jos (dispare "dunga" de jos pe ecranul cu zilele)
          bottom: false,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _mode == _ScreenMode.days ? _buildDaysScreen() : _buildDayScreen(),
          ),
        ),
      ),
    );
  }

  // =========================
  // DAYS SCREEN
  // =========================
  Widget _buildDaysScreen() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: _glassTopBar(
              child: SizedBox(
                height: 46,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _pillIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: _goHomeRoot,
                      ),
                    ),
                    Center(
                      child: Text(
                        "Trasee pe zile",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 17.5,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.isDarkGlobal ? Colors.white : kText,
                        ),
                      ),
                    ),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(width: 42, height: 42),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (!_gateDaysVisible)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                "Se încarcă…",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  color: AppTheme.isDarkGlobal
                      ? Colors.white.withOpacity(0.60)
                      : Colors.black.withOpacity(0.55),
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final dayIndex = i + 1;
                final day = TraseuData.getDay(dayIndex);
                final subtitle = _s(day["subtitle"]);
                final activities = (day["activities"] as List?) ?? const [];
                final done = _checkedCount(activities);
                final total = activities.length;
                final progress = total == 0 ? 0.0 : (done / total);

                final String heroImage = _s(day["heroImage"]);

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: _appStoreDayCard(
                    dayIndex: dayIndex,
                    subtitle: subtitle.isEmpty ? "Plan complet, pas cu pas" : subtitle,
                    heroImage: heroImage,
                    progress: progress,
                    done: done,
                    total: total,
                    onOpen: () async {
                      setState(() {
                        selectedDay = dayIndex;
                        _mode = _ScreenMode.day;
                        _showSwipeHint = true;
                      });

                      await _maybeShowDayIntro(dayIndex);

                      // ✅ tutorial coach: o singură dată total
                      if (mounted) {
                        WidgetsBinding.instance.addPostFrameCallback((_) async {
                          await _maybeShowCoachTutorialOnce();
                        });
                      }
                    },
                  ),
                );
              },
              childCount: widget.totalDays,
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 30),
            child: Center(
              child: Text(
                "— Tour Oradea © 2025 —",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppTheme.isDarkGlobal
                      ? Colors.white.withOpacity(0.35)
                      : Colors.black.withOpacity(0.35),
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _appStoreDayCard({
    required int dayIndex,
    required String subtitle,
    required String heroImage,
    required double progress,
    required int done,
    required int total,
    required VoidCallback onOpen,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        children: [
          SizedBox(
            height: 240,
            width: double.infinity,
            child: heroImage.isNotEmpty
                ? Image.asset(
                    heroImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.black.withOpacity(0.06)),
                  )
                : Container(color: Colors.black.withOpacity(0.06)),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    Colors.black.withOpacity(0.78),
                    Colors.black.withOpacity(0.12),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _frostPillText("Ziua $dayIndex"),
                      const Spacer(),
                      _frostPillText("Obiective: $done/$total"),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    "Traseu",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withOpacity(0.75),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: _clamp01(progress),
                            minHeight: 8,
                            backgroundColor: Colors.white.withOpacity(0.16),
                            valueColor: const AlwaysStoppedAnimation(kAccentSuccess),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: onOpen,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.92),
                          foregroundColor: kPrimary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          textStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w900,
                            fontSize: 13.5,
                          ),
                        ),
                        child: const Text("Deschide"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // DAY SCREEN
  // =========================
  Widget _buildDayScreen() {
    final day = TraseuData.getDay(selectedDay);
    final activities = (day["activities"] as List?) ?? const [];
    final done = _checkedCount(activities);
    final total = activities.length;
    final progress = total == 0 ? 0.0 : (done / total);

    final controller = PageController();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: Column(
            children: [
              _glassTopBar(
                child: Row(
                  children: [
                    _pillIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => setState(() {
                        _mode = _ScreenMode.days;
                        _showSwipeHint = true;
                      }),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Ziua $selectedDay",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.isDarkGlobal ? Colors.white : kText,
                        ),
                      ),
                    ),
                    Container(
                      key: _coachResetKey,
                      child: _glassPillButton(
                        icon: Icons.restart_alt_rounded,
                        text: "Reset",
                        onTap: activities.isEmpty ? null : () => _confirmResetDay(activities),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      key: _coachMapKey,
                      child: ElevatedButton.icon(
                        onPressed: activities.isEmpty ? null : () => _showMapSheetForDay(activities),
                        icon: const Icon(Icons.map_rounded, size: 18),
                        label: const Text("Hartă"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAccentMaps,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          textStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Obiective bifate: $done / $total",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w800,
                        color: AppTheme.isDarkGlobal
                            ? Colors.white
                            : Colors.black.withOpacity(0.70),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppTheme.isDarkGlobal
                          ? const Color(0xFF2C2C2E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppTheme.isDarkGlobal
                            ? Colors.white.withOpacity(0.15)
                            : Colors.black.withOpacity(0.10),
                      ),
                    ),
                    child: Text(
                      "${(progress * 100).round()}%",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w900,
                        color: AppTheme.isDarkGlobal
                            ? Colors.white
                            : Colors.black.withOpacity(0.78),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: _clamp01(progress),
                  minHeight: 8,
                  backgroundColor: AppTheme.isDarkGlobal
                      ? Colors.white.withOpacity(0.15)
                      : Colors.black.withOpacity(0.08),
                  valueColor: const AlwaysStoppedAnimation(kAccentSuccess),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: activities.isEmpty
              ? Center(
                  child: Text(
                    "Nu există activități pentru ziua asta.",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      color: Colors.black.withOpacity(0.55),
                    ),
                  ),
                )
              : Stack(
                  children: [
                    PageView.builder(
                      controller: controller,
                      physics: const BouncingScrollPhysics(),
                      itemCount: activities.length,
                      onPageChanged: (_) {
                        if (!_showSwipeHint) return;
                        setState(() => _showSwipeHint = false);
                      },
                      itemBuilder: (context, index) {
                        final act = activities[index] as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                          child: _bigSwipeCard(
                            act: act,
                            index: index,
                            activities: activities,
                          ),
                        );
                      },
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        ignoring: true,
                        child: AnimatedOpacity(
                          opacity: _showSwipeHint ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 220),
                          child: Center(child: _swipeHintPill()),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _swipeHintPill() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.70),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.black.withOpacity(0.08)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.swipe_left_rounded, size: 18, color: Colors.black87),
              const SizedBox(width: 8),
              Text(
                "Swipe stânga",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w900,
                  fontSize: 12.8,
                  color: Colors.black.withOpacity(0.78),
                ),
              ),
              const SizedBox(width: 10),
              AnimatedBuilder(
                animation: _swipeAnim,
                builder: (_, __) {
                  final dx = -6 * _swipeAnim.value;
                  return Transform.translate(
                    offset: Offset(dx, 0),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: 18,
                      color: Colors.black.withOpacity(0.70),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // BIG CARD
  // =========================
  Widget _bigSwipeCard({
    required Map<String, dynamic> act,
    required int index,
    required List activities,
  }) {
    final coords = _coordsForCurrentDay();

    final id = _s(act["id"]);
    final title = _s(act["title"]);
    final hour = _s(act["hour"]);
    final type = _s(act["type"]);
    final imagePath = act["image"];
    final hint = _extraFor(act)["hint"] ?? "";

    final isVisited = _isVisited(id);
    final LatLng? c = coords[id];

    final bool attachCoachKeys = index == 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Stack(
        children: [
          Positioned.fill(
            child: (imagePath is String && imagePath.isNotEmpty)
                ? Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.black.withOpacity(0.06)),
                  )
                : Container(color: Colors.black.withOpacity(0.06)),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    Colors.black.withOpacity(0.82),
                    Colors.black.withOpacity(0.14),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              key: attachCoachKeys ? _coachStatusKey : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isVisited ? kAccentSuccess.withOpacity(0.92) : Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(0.22)),
                ),
                child: Row(
                  children: [
                    Icon(
                      isVisited ? Icons.check_circle_rounded : Icons.circle_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isVisited ? "Bifat" : "Nevizitat",
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontSize: 12.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.22)),
                      ),
                      child: Center(child: _iconForType(type, color: Colors.white)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.08,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.schedule_rounded, color: Colors.white70, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                hour,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13.2,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (hint.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final style = TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13.3,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.isDarkGlobal ? Colors.white : Colors.white.withOpacity(0.90),
                        height: 1.25,
                      );

                      final hasMore = _isTextOverflow(
                        text: hint,
                        style: style,
                        maxWidth: constraints.maxWidth,
                        maxLines: 3, // ✅ 3 rânduri inițial
                      );

                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _showHintSheet(title: title, hint: hint),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hint,
                              maxLines: 3, // ✅ 3 rânduri inițial
                              overflow: TextOverflow.ellipsis,
                              style: style,
                            ),
                            if (hasMore) ...[
                              const SizedBox(height: 6),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Mai mult",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12.6,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.isDarkGlobal ? Colors.white : Colors.white.withOpacity(0.92),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.keyboard_arrow_up_rounded,
                                    size: 18,
                                    color: AppTheme.isDarkGlobal ? Colors.white : Colors.white.withOpacity(0.92),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        key: attachCoachKeys ? _coachCheckKey : null,
                        child: _smallPillButton(
                          text: "Bifat",
                          icon: isVisited ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                          bg: isVisited ? kAccentSuccess.withOpacity(0.94) : Colors.white.withOpacity(0.22),
                          fg: Colors.white,
                          onTap: isVisited
                              ? null
                              : () => _confirmMarkVisited(
                                    activities: activities,
                                    index: index,
                                    title: title,
                                  ),
                          compact: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        key: attachCoachKeys ? _coachDirectionsKey : null,
                        child: _smallPillButton(
                          text: "Direcții",
                          icon: Icons.navigation_rounded,
                          bg: kAccentMaps.withOpacity(0.92),
                          fg: Colors.white,
                          onTap: c == null ? null : () => _openExternalMaps(c, title),
                          compact: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        key: attachCoachKeys ? _coachSeeKey : null,
                        child: _smallPillButton(
                          text: "Vezi",
                          icon: Icons.open_in_new_rounded,
                          bg: Colors.white.withOpacity(0.92),
                          fg: kPrimary,
                          onTap: () => _openDetailsForActivity(act),
                          compact: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // UI helpers (glass)
  // =========================
  Widget _glassTopBar({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.isDarkGlobal
                ? const Color(0xFF1C1C1E).withOpacity(0.90)
                : Colors.white.withOpacity(0.62),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: AppTheme.isDarkGlobal
                  ? Colors.white.withOpacity(0.10)
                  : Colors.black.withOpacity(0.06),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _glassPillButton({required IconData icon, required String text, required VoidCallback? onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.isDarkGlobal
            ? const Color(0xFF2C2C2E)
            : Colors.white.withOpacity(0.78),
        foregroundColor: AppTheme.isDarkGlobal
            ? Colors.white
            : Colors.black.withOpacity(0.75),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide(
          color: AppTheme.isDarkGlobal
              ? Colors.white.withOpacity(0.15)
              : Colors.black.withOpacity(0.10),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _glassIconBadge({required IconData icon, required Color tint}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: tint.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tint.withOpacity(0.16)),
      ),
      child: Icon(icon, color: tint),
    );
  }

  Widget _glassCloseButton({required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.72),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Icon(Icons.close_rounded, color: Colors.black.withOpacity(0.70)),
      ),
    );
  }

  Widget _frostPillText(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.20)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w900,
          color: Colors.white,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _pillIconButton({required IconData icon, required VoidCallback onTap}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: Colors.white.withOpacity(0.70),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.black.withOpacity(0.08)),
              ),
              child: Icon(icon, color: Colors.black.withOpacity(0.75), size: 22),
            ),
          ),
        ),
      ),
    );
  }

  Widget _smallPillButton({
    required String text,
    required IconData icon,
    required Color bg,
    required Color fg,
    required VoidCallback? onTap,
    bool compact = false,
  }) {
    final double fontSize = compact ? 12.3 : 13.0;
    final double iconSize = compact ? 17.0 : 18.0;

    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: iconSize),
      label: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(text, maxLines: 1),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w900,
          fontSize: fontSize,
        ),
      ),
    );
  }

  Icon _iconForType(String type, {Color color = Colors.white}) {
    switch (type) {
      case "cafe":
        return Icon(Icons.coffee_rounded, size: 22, color: color);
      case "museum":
        return Icon(Icons.account_balance_rounded, size: 22, color: color);
      case "food":
        return Icon(Icons.restaurant_rounded, size: 22, color: color);
      case "walk":
        return Icon(Icons.directions_walk_rounded, size: 22, color: color);
      case "strand":
        return Icon(Icons.pool_rounded, size: 22, color: color);
      default:
        return Icon(Icons.place_rounded, size: 22, color: color);
    }
  }
}

// =========================
// Helper classes pentru coach marks
// =========================
class _CoachStep {
  final GlobalKey key;
  final String title;
  final String message;
  final Color accent;
  final IconData icon;

  _CoachStep({
    required this.key,
    required this.title,
    required this.message,
    required this.accent,
    required this.icon,
  });
}

/// ✅ FIX IMPORTANT:
/// Înainte, "gaura" era desenată cu BlendMode.clear fără saveLayer,
/// iar pe unele device-uri apărea negru și acoperea butonul.
/// Acum folosim canvas.saveLayer() -> clear funcționează corect și highlight-ul devine transparent.
class _CoachPainter extends CustomPainter {
  final Rect target;
  final Color glow;
  final Color dim;

  _CoachPainter({
    required this.target,
    required this.glow,
    required this.dim,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final full = Offset.zero & size;

    // IMPORTANT: saveLayer pentru ca BlendMode.clear să chiar "decupa" transparent
    canvas.saveLayer(full, Paint());

    // dim background
    final bg = Paint()..color = dim;
    canvas.drawRect(full, bg);

    // "hole" highlight (transparent)
    final clearPaint = Paint()..blendMode = BlendMode.clear;
    final hole = RRect.fromRectAndRadius(target.inflate(8), const Radius.circular(18));
    canvas.drawRRect(hole, clearPaint);

    // aplică layer
    canvas.restore();

    // glow stroke (deasupra, fără să umple)
    final stroke = Paint()
      ..color = glow.withOpacity(0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawRRect(hole, stroke);
  }

  @override
  bool shouldRepaint(covariant _CoachPainter oldDelegate) {
    return oldDelegate.target != target || oldDelegate.glow != glow || oldDelegate.dim != dim;
  }
}
