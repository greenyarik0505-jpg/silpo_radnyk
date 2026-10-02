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

  double get cost {
    final p = matchedProduct;
    if (p == null) return 0.0;
    if (unit == 'г' && p.unit == 'кг') {
      return p.currentPrice * (amount / 1000.0);
    }
    return p.currentPrice * (amount > 0 ? amount : 1.0);
  }

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

/// Full culinary recipe with AI-parsed ingredients, portion scaling and direct cart-transfer support.
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
      return sum + item.cost;
    });
  }

  double get totalSavings {
    return ingredients.fold(0.0, (sum, item) {
      return sum + (item.matchedProduct?.savings ?? 0.0);
    });
  }

  /// Scales recipe servings dynamically and recalculates all ingredient amounts.
  Recipe scaleServings(int targetServings) {
    if (targetServings <= 0 || targetServings == servings) return this;
    final ratio = targetServings / servings;
    final scaledIngredients = ingredients.map((ing) {
      return ing.copyWith(
        amount: double.parse((ing.amount * ratio).toStringAsFixed(2)),
      );
    }).toList();

    return Recipe(
      id: id,
      title: title,
      description: description,
      cookTimeMinutes: cookTimeMinutes,
      difficulty: difficulty,
      servings: targetServings,
      imageUrl: imageUrl,
      dietaryTags: dietaryTags,
      ingredients: scaledIngredients,
      steps: steps,
    );
  }

  /// Swaps an ingredient with its cheaper private label / alternative substitute.
  Recipe withToggledSubstitute(int index) {
    if (index < 0 || index >= ingredients.length) return this;
    final current = ingredients[index];
    if (current.substituteProduct == null) return this;

    final updated = current.copyWith(
      matchedProduct: current.substituteProduct,
      substituteProduct: current.matchedProduct,
    );

    final newIngredients = List<RecipeIngredient>.from(ingredients);
    newIngredients[index] = updated;

    return Recipe(
      id: id,
      title: title,
      description: description,
      cookTimeMinutes: cookTimeMinutes,
      difficulty: difficulty,
      servings: servings,
      imageUrl: imageUrl,
      dietaryTags: dietaryTags,
      ingredients: newIngredients,
      steps: steps,
    );
  }
}
