/// Domain entity representing an ingredient item that is used to make a dish/product.
class ProductIngredientItem {
  final String name;
  final String? brand;
  final String amount;
  final double estimatedPrice;
  final String silpoUrl;

  const ProductIngredientItem({
    required this.name,
    this.brand,
    required this.amount,
    required this.estimatedPrice,
    required this.silpoUrl,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'brand': brand,
    'amount': amount,
    'estimatedPrice': estimatedPrice,
    'silpoUrl': silpoUrl,
  };

  factory ProductIngredientItem.fromJson(Map<String, dynamic> json) => ProductIngredientItem(
    name: json['name'] as String,
    brand: json['brand'] as String?,
    amount: json['amount'] as String? ?? '1 шт',
    estimatedPrice: (json['estimatedPrice'] as num?)?.toDouble() ?? 0.0,
    silpoUrl: json['silpoUrl'] as String? ?? 'https://shop.silpo.ua',
  );
}

/// Domain entity representing a product in Silpo catalog.
class Product {
  final String id;
  final String title;
  final String category;
  final double regularPrice;
  final double? promoPrice;
  final String unit; // 'шт', 'кг', 'уп'
  final String? imageUrl;
  final String? brand;
  final bool isCinotyzhik;
  final bool isPrivateLabel; // 'Премія', 'Повна Чаша'
  final double? rating;
  final int? bonusPoints;
  final double weightGrams;
  final String? composition; // Склад продукту з етикетки
  final String? silpoUrl; // Пряме посилання на silpo.ua
  final List<ProductIngredientItem> recipeIngredients; // Якщо страва — список продуктів, з яких її готувати

  const Product({
    required this.id,
    required this.title,
    required this.category,
    required this.regularPrice,
    this.promoPrice,
    this.unit = 'шт',
    this.imageUrl,
    this.brand,
    this.isCinotyzhik = false,
    this.isPrivateLabel = false,
    this.rating,
    this.bonusPoints,
    this.weightGrams = 1000,
    this.composition,
    this.silpoUrl,
    this.recipeIngredients = const [],
  });

  bool get hasDiscount => promoPrice != null && promoPrice! < regularPrice;

  double get currentPrice => promoPrice ?? regularPrice;

  int get discountPercentage {
    if (!hasDiscount) return 0;
    return (((regularPrice - promoPrice!) / regularPrice) * 100).round();
  }

  double get savings => hasDiscount ? (regularPrice - promoPrice!) : 0.0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'regularPrice': regularPrice,
    'promoPrice': promoPrice,
    'unit': unit,
    'imageUrl': imageUrl,
    'brand': brand,
    'isCinotyzhik': isCinotyzhik,
    'isPrivateLabel': isPrivateLabel,
    'rating': rating,
    'bonusPoints': bonusPoints,
    'weightGrams': weightGrams,
    'composition': composition,
    'silpoUrl': silpoUrl,
    'recipeIngredients': recipeIngredients.map((r) => r.toJson()).toList(),
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    title: json['title'] as String,
    category: json['category'] as String? ?? 'Загальне',
    regularPrice: (json['regularPrice'] as num).toDouble(),
    promoPrice: (json['promoPrice'] as num?)?.toDouble(),
    unit: json['unit'] as String? ?? 'шт',
    imageUrl: json['imageUrl'] as String?,
    brand: json['brand'] as String?,
    isCinotyzhik: json['isCinotyzhik'] as bool? ?? false,
    isPrivateLabel: json['isPrivateLabel'] as bool? ?? false,
    rating: (json['rating'] as num?)?.toDouble(),
    bonusPoints: json['bonusPoints'] as int?,
    weightGrams: (json['weightGrams'] as num?)?.toDouble() ?? 1000,
    composition: json['composition'] as String?,
    silpoUrl: json['silpoUrl'] as String?,
    recipeIngredients: (json['recipeIngredients'] as List<dynamic>?)
            ?.map((e) => ProductIngredientItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
  );
}
