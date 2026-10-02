import 'product.dart';

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
  final int? bonusMultiplier;
  final String? barcode;
  final Product? product;

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
    this.product,
  });

  Product get effectiveProduct =>
      product ??
      Product(
        id: id,
        title: title,
        category: category,
        regularPrice: originalPrice ?? (promoPrice != null ? promoPrice! * 1.25 : 100.0),
        promoPrice: promoPrice,
        isCinotyzhik: type == PromoType.cinotyzhik,
        bonusPoints: (bonusMultiplier ?? 1) * 10,
        imageUrl: imageUrl,
        silpoUrl: 'https://shop.silpo.ua/product/$id',
        composition: 'Склад: натуральні інгредієнти вищого ґатунку.',
      );

  int get daysRemaining {
    final diff = validUntil.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  bool get isExpired => DateTime.now().isAfter(validUntil);
}
