class FavoriteItem {
  final String id;
  final String type; // ex: "restaurant"
  final Map<String, dynamic> data;

  FavoriteItem({
    required this.id,
    required this.type,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "type": type,
      "data": data,
    };
  }

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: json["id"],
      type: json["type"],
      data: Map<String, dynamic>.from(json["data"]),
    );
  }
}
