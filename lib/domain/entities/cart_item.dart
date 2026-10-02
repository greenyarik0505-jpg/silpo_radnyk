import 'product.dart';

/// Item stored in customer cart with quantity, unit calculations and auto-replenish settings.
class CartItem {
  final Product product;
  final double quantity;
  final Product? substitute;
  final bool isAutoReplenish;
  final int? replenishIntervalDays; // e.g. 7 for weekly delivery

  const CartItem({
    required this.product,
    this.quantity = 1,
    this.substitute,
    this.isAutoReplenish = false,
    this.replenishIntervalDays,
  });

  Product get activeProduct => substitute ?? product;

  double get totalPrice => activeProduct.currentPrice * quantity;

  double get regularTotalPrice => activeProduct.regularPrice * quantity;

  double get totalSavings => activeProduct.savings * quantity;

  int get earnedBonusPoints => ((activeProduct.bonusPoints ?? 1) * quantity).round();

  CartItem copyWith({
    Product? product,
    double? quantity,
    Product? substitute,
    bool? isAutoReplenish,
    int? replenishIntervalDays,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      substitute: substitute ?? this.substitute,
      isAutoReplenish: isAutoReplenish ?? this.isAutoReplenish,
      replenishIntervalDays: replenishIntervalDays ?? this.replenishIntervalDays,
    );
  }

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
    'substitute': substitute?.toJson(),
    'isAutoReplenish': isAutoReplenish,
    'replenishIntervalDays': replenishIntervalDays,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    product: Product.fromJson(Map<String, dynamic>.from(json['product'] as Map)),
    quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
    substitute: json['substitute'] != null
        ? Product.fromJson(Map<String, dynamic>.from(json['substitute'] as Map))
        : null,
    isAutoReplenish: json['isAutoReplenish'] as bool? ?? false,
    replenishIntervalDays: json['replenishIntervalDays'] as int?,
  );
}
