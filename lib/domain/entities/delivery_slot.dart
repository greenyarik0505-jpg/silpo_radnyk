enum DeliveryType {
  express,
  scheduled,
  selfPickup,
}

class DeliverySlot {
  final String id;
  final DeliveryType type;
  final String timeRange; // '18:00 - 20:00'
  final DateTime date;
  final double deliveryFee;
  final bool isAvailable;
  final String description;

  const DeliverySlot({
    required this.id,
    required this.type,
    required this.timeRange,
    required this.date,
    required this.deliveryFee,
    this.isAvailable = true,
    required this.description,
  });

  bool get isFree => deliveryFee == 0.0;
}
