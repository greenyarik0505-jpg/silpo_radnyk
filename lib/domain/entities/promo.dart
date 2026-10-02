enum PromoType {
  cinotyzhik,
  wheelOfFortune,
  personalDeal,
  priceDrop,
  multiplier,
}

/// Promo entity for «Цінотижики», personal deals and loyalty bonuses.
class PromoItem {
  final String id;
  final String title;
  final String description;
  final PromoType type;
  final int discountPercent;
  final double? originalPrice;
  final double? promoPrice;
  final DateTime validUntil;
  final String category;
  final String? imageUrl;
  final int? bonusMultiplier; // e.g. x3 for fresh bakery
  final String? barcode;

  const PromoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.discountPercent,
    this.originalPrice,
    this.promoPrice,
    required this.validUntil,
    required this.category,
    this.imageUrl,
    this.bonusMultiplier,
    this.barcode,
  });

  int get daysRemaining {
    final diff = validUntil.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  bool get isExpired => DateTime.now().isAfter(validUntil);
}
