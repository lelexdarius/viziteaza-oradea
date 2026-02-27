import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:viziteaza_oradea/cazari_page.dart'; // modelul Cazare
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';

class CazareDetaliiPage extends StatelessWidget {
  final Cazare cazare;

  const CazareDetaliiPage({Key? key, required this.cazare}) : super(key: key);

  // 🔹 Deschide link extern (site / Booking)
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('❌ Nu pot deschide linkul: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),

      // 🔹 AppBar transparent cu efect de blur
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.3),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF004E64)),
        title: Text(
          cazare.title,
          style: const TextStyle(
            color: Color(0xFF004E64),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),

      // 🔹 Conținutul începe sub AppBar
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
        children: [
          // === Carusel imagini din rețea ===
          if (cazare.imagePaths.isNotEmpty)
            _buildImageCarousel(cazare.imagePaths)
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset('assets/images/imagine_gri.jpg',
                  height: 220, fit: BoxFit.cover),
            ),

          const SizedBox(height: 20),

          // === Titlu hotel ===
          Text(
            cazare.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF004E64),
            ),
          ),

          const SizedBox(height: 10),

          // === Stele rating ===
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < cazare.rating ? Icons.star : Icons.star_border_outlined,
                color: const Color(0xFFFFC107),
                size: 22,
              );
            }),
          ),

          const SizedBox(height: 20),

          // === Info general ===
          _infoRow(Icons.location_on_outlined, cazare.address),
          _infoRow(Icons.phone_outlined, cazare.phone),
          _infoRow(Icons.access_time_outlined, "Program: ${cazare.schedule}"),

          const SizedBox(height: 20),

          // === Prețuri / Interval ===
          if (cazare.priceRange != null && cazare.priceRange!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF5F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.attach_money, color: Color(0xFF004E64)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cazare.priceRange!,
                      style: const TextStyle(
                        color: Color(0xFF004E64),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 25),

          // === Buton site extern ===
          if (cazare.websiteUrl != null && cazare.websiteUrl!.isNotEmpty)
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _launchURL(cazare.websiteUrl!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004E64),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.open_in_new, color: Colors.white),
                label: const Text(
                  "Vizitează site-ul / Booking",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

          const SizedBox(height: 35),

          // === Descriere ===
          const Text(
            "Descriere:",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF004E64),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            cazare.description,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),

          const SizedBox(height: 40),

          // === Recomandare ===
          if (cazare.isRecommended)
            Center(
              child: Text(
                cazare.recommendedText,
                style: const TextStyle(
                  color: Color(0xFF1B8A5A),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // === Carusel cu imagini din rețea ===
  Widget _buildImageCarousel(List<String> imagePaths) {
    return SizedBox(
      height: 250,
      child: PageView.builder(
        itemCount: imagePaths.length,
        controller: PageController(viewportFraction: 0.92),
        itemBuilder: (context, index) {
          final imageUrl = imagePaths[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(imageUrl: 
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (_, __) => Container(color: const Color(0xFFE8F1F4)),
                errorWidget: (context, error, stackTrace) {
                  debugPrint("❌ Eroare imagine în carusel: $error");
                  return Image.asset(
                    'assets/images/imagine_gri.webp',
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // === Linie informativă ===
  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF004E64), size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
