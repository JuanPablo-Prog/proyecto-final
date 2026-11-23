/// Destino / paquete turístico almacenado en Realtime Database (`destinations/{id}`).
class DestinationDAO {
  final String id;
  final String name;
  final String state;
  final String description;
  final String imageUrl; // URL de Firebase Storage (o cualquier https)
  final String category;
  final double price; // MXN por persona
  final double rating;
  final double lat;
  final double lng;
  final int days;

  const DestinationDAO({
    required this.id,
    required this.name,
    required this.state,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.price,
    required this.rating,
    required this.lat,
    required this.lng,
    required this.days,
  });

  //factory= constructor nombrado
  factory DestinationDAO.fromMap(String id, Map<dynamic, dynamic> m) {
    double d(dynamic v) => (v as num?)?.toDouble() ?? 0;
    return DestinationDAO(
      id: id,
      name: (m['name'] ?? '') as String,
      state: (m['state'] ?? '') as String,
      description: (m['description'] ?? '') as String,
      imageUrl: (m['imageUrl'] ?? '') as String,
      category: (m['category'] ?? 'Cultura') as String,
      price: d(m['price']),
      rating: d(m['rating']),
      lat: d(m['lat']),
      lng: d(m['lng']),
      days: (m['days'] as num?)?.toInt() ?? 1,
    );
  }
}
