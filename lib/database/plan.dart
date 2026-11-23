/// Plan de suscripción de la agencia (modelo de prestación de servicios).
class Plan {
  final String id;
  final String name;
  final double price; // MXN / mes
  final int discountPercent; // descuento aplicado a las reservas
  final List<String> perks;
  final bool highlighted;

  const Plan({
    required this.id,
    required this.name,
    required this.price,
    required this.discountPercent,
    required this.perks,
    this.highlighted = false,
  });

  static const all = <Plan>[
    Plan(
      id: 'explorador',
      name: 'Explorador',
      price: 149,
      discountPercent: 5,
      perks: ['5% de descuento en reservas', 'Ofertas anticipadas por notificación', 'Soporte por chat'],
    ),
    Plan(
      id: 'aventurero',
      name: 'Aventurero',
      price: 299,
      discountPercent: 12,
      highlighted: true,
      perks: ['12% de descuento en reservas', 'Cancelación gratuita 48 h', 'Itinerarios personalizados', 'Soporte prioritario'],
    ),
    Plan(
      id: 'elite',
      name: 'Élite',
      price: 599,
      discountPercent: 20,
      perks: ['20% de descuento en reservas', 'Guía privado en destinos selectos', 'Upgrades de hotel', 'Concierge 24/7'],
    ),
  ];

  static Plan? byId(String? id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }
}
