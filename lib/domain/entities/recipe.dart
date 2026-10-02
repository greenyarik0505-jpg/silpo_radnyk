import 'product.dart';

/// Recipe ingredient with matching Silpo product and smart substitution options.
class RecipeIngredient {
  final String name;
  final double amount;
  final String unit;
  final Product? matchedProduct;
  final Product? substituteProduct;
  final bool isOptional;

  const RecipeIngredient({
    required this.name,
    required this.amount,
    required this.unit,
    this.matchedProduct,
    this.substituteProduct,
    this.isOptional = false,
  });

  double get cost => (matchedProduct?.currentPrice ?? 0.0) * (amount > 0 ? 1 : 1);

  RecipeIngredient copyWith({
    String? name,
    double? amount,
    String? unit,
    Product? matchedProduct,
    Product? substituteProduct,
    bool? isOptional,
  }) {
    return RecipeIngredient(
      name: name ?? this.name,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      matchedProduct: matchedProduct ?? this.matchedProduct,
      substituteProduct: substituteProduct ?? this.substituteProduct,
      isOptional: isOptional ?? this.isOptional,
    );
  }
}

/// Full culinary recipe with AI-parsed ingredients and direct cart-transfer support.
class Recipe {
  final String id;
  final String title;
  final String description;
  final int cookTimeMinutes;
  final String difficulty; // Легко, Середнє, Шеф
  final int servings;
  final String? imageUrl;
  final List<String> dietaryTags;
  final List<RecipeIngredient> ingredients;
  final List<String> steps;

  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.cookTimeMinutes,
    required this.difficulty,
    required this.servings,
    this.imageUrl,
    this.dietaryTags = const [],
    required this.ingredients,
    required this.steps,
  });

  double get totalEstimatedCost {
    return ingredients.fold(0.0, (sum, item) {
      final p = item.substituteProduct ?? item.matchedProduct;
      return sum + (p?.currentPrice ?? 0.0);
    });
  }

  double get totalSavings {
    return ingredients.fold(0.0, (sum, item) {
      final p = item.substituteProduct ?? item.matchedProduct;
      return sum + (p?.savings ?? 0.0);
    });
  }
}
