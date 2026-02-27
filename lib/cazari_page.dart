import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'cazare_detalii_page.dart';
import 'widgets/custom_footer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Cazare {
  final String title;
  final String description;
  final String address;
  final String phone;
  final String schedule;
  final List<String> imagePaths;
  final int rating;
  final String? priceRange;
  final String? websiteUrl;
  final bool isRecommended;
  final String detailsButton;
  final String recommendedText;

  Cazare({
    required this.title,
    required this.description,
    required this.address,
    required this.phone,
    required this.schedule,
    required this.imagePaths,
    required this.rating,
    this.priceRange,
    this.websiteUrl,
    this.isRecommended = false,
    this.detailsButton = "Vezi detalii",
    this.recommendedText = "✔️ Recomandat de Vizitează Oradea",
  });

  factory Cazare.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final List<String> images = (data['imagePaths'] is Iterable)
        ? List<String>.from(
            (data['imagePaths'] as Iterable).whereType<String>())
        : <String>[];

    return Cazare(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      schedule: data['schedule'] ?? '',
      imagePaths: images,
      rating: (data['rating'] ?? 0).toInt(),
      priceRange: data['priceRange'] ?? '',
      websiteUrl: data['websiteUrl'] ?? '',
      isRecommended: (data['isRecommended'] ?? false) as bool,
      detailsButton: data['detailsButton'] ?? 'Vezi detalii',
      recommendedText:
          data['recommendedText'] ?? '✔️ Recomandat de Vizitează Oradea',
    );
  }
}

class CazariPage extends StatelessWidget {
  const CazariPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double topPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight + 10;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F1F4),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: Colors.white.withOpacity(0.2),
              elevation: 0,
              centerTitle: true,
              title: const Text(
                "Cazări",
                style: TextStyle(
                  color: Color(0xFF004E64),
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF004E64)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('cazari')
                  .orderBy('order', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Nu există cazări disponibile momentan.",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  );
                }

                final cazari = snapshot.data!.docs
                    .map((doc) => Cazare.fromFirestore(doc))
                    .toList();

                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                      top: topPadding, left: 16, right: 16, bottom: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Momentan, nu se pot face rezervări din aplicație. Noi doar prezentăm cazări disponibile în Oradea. Pentru rezervări, folosiți linkurile fiecărui hotel. ✨",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ...cazari.map((c) => _buildCard(context, c)).toList(),
                      const SizedBox(height: 40),
                      const Text(
                        "Daca doresti ca si cazarea ta sa apara in lista de mai sus, contacteaza-ne la adresa de email \n touroradea@gmail.com",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      const Center(
                        child: Text(
                          "— Tour Oradea © 2025 —",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.grey,
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
          const CustomFooter(isHome: true),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, Cazare c) {
    print(
        "🖼️ Imagine încercată: ${c.imagePaths.isNotEmpty ? c.imagePaths.first : 'none'}");

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CazareDetaliiPage(cazare: c),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: c.imagePaths.isNotEmpty
                  ? CachedNetworkImage(imageUrl: 
                      c.imagePaths.first,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 180,
                      placeholder: (_, __) => Container(color: const Color(0xFFE8F1F4)),
                      errorWidget: (context, error, stackTrace) {
                        print("❌ Eroare imagine: $error");
                        return Image.asset(
                          'assets/images/imagine_gri.jpg.webp',
                          fit: BoxFit.cover,
                          height: 180,
                        );
                      },
                    )
                  : Image.asset('assets/images/imagine_gri.jpg.webp',
                      fit: BoxFit.cover, height: 180),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < c.rating
                            ? Icons.star
                            : Icons.star_border_outlined,
                        color: const Color(0xFFFFC107),
                        size: 18,
                      );
                    }),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    c.description,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CazareDetaliiPage(cazare: c),
                            ),
                          );
                        },
                        child: Text(
                          c.detailsButton,
                          style: const TextStyle(
                            color: Color(0xFF004E64),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (c.isRecommended)
                        Flexible(
                          child: Text(
                            c.recommendedText,
                            style: const TextStyle(
                              color: Color(0xFF1B8A5A),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  }