import 'package:cloud_firestore/cloud_firestore.dart';

class Restaurant {
  final String id;
  final String title;
  final String description;
  final String address;
  final String phone;
  final String schedule;
  final String imagePath;
  final int order;
  final List<GeoPoint>? locations;
  final String? linkMenu;

  // ✅ NOU
  final bool recomandat;

  Restaurant({
    required this.id,
    required this.title,
    required this.description,
    required this.address,
    required this.phone,
    required this.schedule,
    required this.imagePath,
    required this.order,
    this.locations,
    this.linkMenu,
    required this.recomandat,
  });

  factory Restaurant.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>? ?? {});

    bool parseBool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) {
        final s = v.trim().toLowerCase();
        return s == 'true' || s == '1' || s == 'da' || s == 'yes';
      }
      return false;
    }

    final bool recomandat = parseBool(data['Recomandat']);

    return Restaurant(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      schedule: data['schedule'] ?? '',
      imagePath: data['imagePath'] ?? '',
      locations: data['locations'] != null
          ? List<GeoPoint>.from(data['locations'])
          : [],
      order: data['order'] ?? 0,
      linkMenu: data['linkMenu'] ?? '',
      recomandat: recomandat,
    );
  }
}
