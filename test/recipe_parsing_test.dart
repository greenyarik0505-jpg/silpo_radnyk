import 'package:flutter_test/flutter_test.dart';
import 'package:sulipo_pomoshuk/data/repositories/silpo_repository.dart';
import 'package:sulipo_pomoshuk/presentation/viewmodels/cart_viewmodel.dart';

void main() {
  group('AI Recipe Parsing & Cart Transfer Tests', () {
    late SilpoRepository repository;
    late CartViewModel cart;

    setUp(() {
      repository = SilpoRepository();
      cart = CartViewModel(repository: repository);
    });

    test('Parsing "борщ" returns valid Ukrainian Borsch with matched products', () async {
      final recipe = await repository.parseRecipe('Приготуй мені справжній український борщ');
      expect(recipe.title.contains('борщ'), isTrue);
      expect(recipe.ingredients.isNotEmpty, isTrue);
      expect(recipe.ingredients.any((i) => i.name.contains('Буряк')), isTrue);
      expect(recipe.ingredients.any((i) => i.name.contains('Яловичина')), isTrue);
      expect(recipe.ingredients.any((i) => i.name.contains('Пампушки')), isTrue);
      expect(recipe.totalEstimatedCost, greaterThan(0.0));
    });

    test('Adding recipe ingredients directly populates cart', () async {
      final recipe = await repository.parseRecipe('борщ');
      expect(cart.isEmpty, isTrue);

      cart.addRecipeIngredients(recipe);
      expect(cart.isEmpty, isFalse);
      expect(cart.items.length, recipe.ingredients.length);
      expect(cart.totalPrice, greaterThan(200.0));
    });

    test('Parsing dessert returns Tiramisu', () async {
      final recipe = await repository.parseRecipe('Хочу десерт тірамісу на свято');
      expect(recipe.title.contains('Тірамісу'), isTrue);
      expect(recipe.ingredients.any((i) => i.name.contains('Маскарпоне')), isTrue);
      expect(recipe.ingredients.any((i) => i.name.contains('Савоярді')), isTrue);
    });

    test('Parsing keto returns salmon dinner', () async {
      final recipe = await repository.parseRecipe('Зроби кето вечерю з рибою');
      expect(recipe.title.contains('Кето') || recipe.title.contains('лосося'), isTrue);
      expect(recipe.ingredients.any((i) => i.name.contains('сьомги') || i.name.contains('лосос')), isTrue);
    });
  });
}
