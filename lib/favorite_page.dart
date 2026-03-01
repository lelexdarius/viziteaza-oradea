import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

// MODELE + SERVICE
import 'models/favorite_item.dart';
import 'services/favorite_service.dart';

// PAGINI DETALII
import 'cafenea_detalii_page.dart';
import 'cafenele_page.dart';
import 'fast_food_page.dart';
import 'models/restaurant_model.dart';
import 'restaurant_detalii_page.dart';
import 'fast_food_detalii_page.dart';
import 'teatru_detalii_page.dart';
import 'filarmonica_detalii_page.dart';
import 'stranduri_detalii_page.dart';
import 'evenimente_detalii_page.dart';
import 'distractii_detalii_page.dart';
import 'muzeu_detalii_page.dart';
import 'muzee_page.dart';

// FOOTER
import 'widgets/custom_footer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:viziteaza_oradea/utils/app_theme.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late Future<List<FavoriteItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = FavoriteService.getFavorites();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = FavoriteService.getFavorites();
    });
  }

  // ------------------------------------------------------------
  // 🔵 Helper pentru GEOPOINT
  // ------------------------------------------------------------
  List<GeoPoint> decodeLocations(dynamic raw) {
    if (raw == null || raw is! List) return [];
    return raw
        .map<GeoPoint>(
          (e) => GeoPoint(
            (e["lat"] as num).toDouble(),
            (e["lng"] as num).toDouble(),
          ),
        )
        .toList();
  }

  // ------------------------------------------------------------
  // 🔵 MODELE
  // ------------------------------------------------------------
  Cafenea _buildCafe(Map<String, dynamic> data) => Cafenea(
        id: data["id"],
        title: data["title"],
        description: data["description"],
        imagePath: data["imagePath"],
        phone: data["phone"],
        schedule: data["schedule"],
        locatii: data["locatii"],
        locations: decodeLocations(data["locations"]),
        recomandat: (data['Recomandat'] ?? false) == true,

      );

  Restaurant _buildRestaurant(Map<String, dynamic> data) => Restaurant(
        id: data["id"],
        title: data["title"],
        description: data["description"],
        address: data["address"],
        phone: data["phone"],
        schedule: data["schedule"],
        imagePath: data["imagePath"],
        order: data["order"] ?? 0,
        locations: decodeLocations(data["locations"]),
        linkMenu: data["linkMenu"],
        recomandat: (data['Recomandat'] ?? false) == true,

      );

  FastFood _buildFastFood(Map<String, dynamic> data) => FastFood(
        id: data["id"],
        title: data["title"],
        description: data["description"],
        address: data["address"],
        phone: data["phone"],
        schedule: data["schedule"],
        imagePath: data["imagePath"],
        order: data["order"] ?? 0,
        locatii: data["locatii"],
        locations: decodeLocations(data["locations"]),
      );

  Map<String, dynamic> _buildTeatru(Map<String, dynamic> data) => data;
  Map<String, dynamic> _buildFilarmonica(Map<String, dynamic> data) => data;
  Map<String, dynamic> _buildStrand(Map<String, dynamic> data) => data;
  Map<String, dynamic> _buildEveniment(Map<String, dynamic> data) => data;
  Map<String, dynamic> _buildDistractie(Map<String, dynamic> data) => data;
  Map<String, dynamic> _buildMuzeu(Map<String, dynamic> data) => data;

  // ------------------------------------------------------------
  // 🧊 Dialog ștergere
  // ------------------------------------------------------------
  Future<bool> _showDeleteDialog(String title) async {
    return await showCupertinoModalPopup<bool>(
          context: context,
          builder: (_) => CupertinoActionSheet(
            title: const Text("Ștergi din favorite?"),
            message: Text(title),
            actions: [
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Șterge"),
              )
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Anulează"),
            ),
          ),
        ) ??
        false;
  }

  // ------------------------------------------------------------
  // 🟦 UI
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 10;

    // ✅ spațiu real pentru footer floating (ca să nu intre lista sub el)
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final footerSpace = 90 + bottomInset + 12;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ✅ blur real în spatele footerului + fără "banda albă"
      extendBodyBehindAppBar: true,
      extendBody: true,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: AppBar(
              backgroundColor: AppTheme.isDarkGlobal ? Colors.black : Colors.white.withOpacity(0.18),
              elevation: 0,
              centerTitle: true,
              title: Text(
                "Favorite",
                style: TextStyle(
                  color: AppTheme.isDarkGlobal ? Colors.white : AppTheme.accent(context),
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Poppins',
                ),
              ),
              leading: BackButton(color: AppTheme.isDarkGlobal ? Colors.white : AppTheme.accent(context)),
            ),
          ),
        ),
      ),

      body: Stack(
        children: [
          // ✅ Conținut scroll, cu padding jos pentru footer
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                
                left: 16,
                right: 16,
                bottom: footerSpace,
              ),
              child: FutureBuilder<List<FavoriteItem>>(
                future: _future,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final items = snapshot.data!;
                  if (items.isEmpty) {
                    return _emptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF004E64).withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(Icons.swipe_left_rounded,
                                    color: AppTheme.accent(context)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Glisează spre stânga pentru a șterge",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textSecondary(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...items.map(_buildDismissibleCard).toList(),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            "— Tour Oradea © 2025 —",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: AppTheme.textSecondary(context),
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // ✅ Footer fix jos (la lățime completă)
          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomFooter(isHome: false),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.90),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF004E64).withOpacity(0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF004E64).withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.favorite_border_rounded,
                  color: AppTheme.accent(context)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Nu ai nimic în favorite încă.",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.2,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary(context),
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // 🟥 Dismissible CARD
  // ------------------------------------------------------------
  Widget _buildDismissibleCard(FavoriteItem fav) {
    final data = fav.data;
    final title = (data["title"] ?? "").toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Dismissible(
          key: ValueKey(fav.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async => await _showDeleteDialog(title),
          onDismissed: (_) async {
            await FavoriteService.toggleFavorite(fav);
            _refresh();
          },
          background: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: _buildFavoriteCard(fav),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // 🟩 CARD
  // ------------------------------------------------------------
  Widget _buildFavoriteCard(FavoriteItem fav) {
    final data = fav.data;

    final img = (data["image"] ??
            data["imagePath"] ??
            data["imageUrl"] ??
            (data["images"] is List && (data["images"] as List).isNotEmpty
                ? (data["images"] as List).first
                : ""))
        .toString();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0xFF004E64).withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),

        // ------------------------------------------------------------
        // 🔵 NAVIGARE ÎN FUNCȚIE DE TIP
        // ------------------------------------------------------------
        onTap: () {
          switch (fav.type) {
            case "cafenea":
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CafeneaDetaliiPage(cafe: _buildCafe(data)),
                ),
              );
              break;

            case "restaurant":
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      RestaurantDetaliiPage(restaurant: _buildRestaurant(data)),
                ),
              );
              break;

            case "fastfood":
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      FastFoodDetaliiPage(fastfood: _buildFastFood(data)),
                ),
              );
              break;

            case "teatru":
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TeatruDetaliiPage(
                    title: data["title"],
                    imageUrl: data["imagePath"],
                    dataSpectacolului: data["data"],
                    ora: data["ora"],
                    locatie: data["locatie"],
                    organizator: data["organizator"],
                    pret: data["pret"],
                    linkBilete: data["linkBilete"],
                    descriere: data["descriere"],
                    dataTimp: null,
                  ),
                ),
              );
              break;

            case "filarmonica":
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FilarmonicaDetaliiPage(
                    title: data["title"],
                    imageUrl: data["imageUrl"],
                    descriere: data["descriere"] ?? "",
                    solist: data["solist"],
                    dataConcertului: data["data"],
                    ora: data["ora"],
                    linkBilete: data["linkBilete"],
                    locatie: data["locatie"],
                    organizator: data["organizator"],
                    pret: data["pret"],
                    dataTimp: null,
                  ),
                ),
              );
              break;

            case "strand":
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StrandDetaliiPage(
                    title: data["title"],
                    description: data["description"],
                    address: data["address"],
                    schedule: data["schedule"],
                    price: data["price"],
                    phone: data["phone"],
                    latitude: data["latitude"],
                    longitude: data["longitude"],
                    images: List<String>.from(data["images"] ?? []),
                  ),
                ),
              );
              break;

            case "eveniment":
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventDetailsPage(
                    title: data["title"],
                    description: data["description"],
                    imagePath: data["imagePath"],
                    data: data["data"],
                    ora: data["ora"],
                    locatie: data["locatie"],
                    pret: data["pret"],
                    organizator: data["organizator"],
                    linkBilete: data["linkBilete"],
                  ),
                ),
              );
              break;

            case "distractie":
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DistractiiDetaliiPage(
                    title: data["title"],
                    description: data["description"],
                    image: data["image"],
                    price: data["price"],
                    schedule: data["schedule"],
                    address: data["address"],
                    mapLink: data["mapLink"],
                  ),
                ),
              );
              break;

            case "muzeu":
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MuzeuDetaliiPage(
                    muzeu: Muzeu(
                      title: data["title"],
                      type: data["type"],
                      description: data["description"],
                      address: data["address"],
                      phone: data["phone"],
                      schedule: data["schedule"],
                      imagePath: data["imagePath"],
                      order: data["order"] ?? 0,
                      latitude: (data["latitude"] as num?)?.toDouble(),
                      longitude: (data["longitude"] as num?)?.toDouble(),
                    ),
                  ),
                ),
              );
              break;
          }
        },

        child: Row(
          children: [
            // IMAGINE
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(16)),
              child: img.isNotEmpty
                  ? CachedNetworkImage(imageUrl: 
                      img,
                      width: 110,
                      height: 95,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: 110,
                        height: 95,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      ),
                    )
                  : Container(
                      width: 110,
                      height: 95,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    ),
            ),

            const SizedBox(width: 14),

            // TEXT + CATEGORIE
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (data["title"] ?? "").toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.accent(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _getTypeLabel(fav.type),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(Icons.chevron_right_rounded,
                  color: Colors.black.withOpacity(0.30)),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // 🔤 ETICHETE TIP
  // ------------------------------------------------------------
  String _getTypeLabel(String type) {
    switch (type) {
      case "cafenea":
        return "Cafenea";
      case "restaurant":
        return "Restaurant";
      case "fastfood":
        return "Fast Food";
      case "teatru":
        return "Teatru";
      case "filarmonica":
        return "Filarmonica";
      case "strand":
        return "Ștrand";
      case "eveniment":
        return "Eveniment";
      case "distractie":
        return "Distracție";
      case "muzeu":
        return "Muzeu";
      default:
        return type.isNotEmpty
            ? type[0].toUpperCase() + type.substring(1)
            : "Favorite";
    }
  }
}
