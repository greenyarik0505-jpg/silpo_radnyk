import 'package:flutter_test/flutter_test.dart';
import 'package:sulipo_pomoshuk/data/repositories/silpo_repository.dart';
import 'package:sulipo_pomoshuk/presentation/viewmodels/chat_viewmodel.dart';

void main() {
  group('Recipe Dynamic Portion Scaling & Substitutions Tests', () {
    late SilpoRepository repository;
    late ChatViewModel chatViewModel;

    setUp(() {
      repository = SilpoRepository();
      chatViewModel = ChatViewModel(repository: repository);
    });

    test('Recipe scales servings proportionally from 4 to 2 and 4 to 8', () async {
      final recipe4 = await repository.parseRecipe('борщ', servings: 4);
      expect(recipe4.servings, 4);

      final recipe2 = recipe4.scaleServings(2);
      expect(recipe2.servings, 2);
      expect(recipe2.ingredients.first.amount, closeTo(recipe4.ingredients.first.amount / 2, 0.01));

      final recipe8 = recipe4.scaleServings(8);
      expect(recipe8.servings, 8);
      expect(recipe8.ingredients.first.amount, closeTo(recipe4.ingredients.first.amount * 2, 0.01));
    });

    test('Ingredient cost calculates with unit awareness', () async {
      final recipe = await repository.parseRecipe('паста');
      expect(recipe.ingredients.isNotEmpty, isTrue);

      final pastaIng = recipe.ingredients.first;
      expect(pastaIng.cost, greaterThan(0.0));
    });

    test('Toggling substitute swaps matchedProduct with substituteProduct', () async {
      final recipe = await repository.parseRecipe('паста');
      final originalIng = recipe.ingredients.first;
      expect(originalIng.substituteProduct, isNotNull);

      final originalCost = recipe.totalEstimatedCost;
      final swappedRecipe = recipe.withToggledSubstitute(0);
      final swappedIng = swappedRecipe.ingredients.first;

      expect(swappedIng.matchedProduct?.id, originalIng.substituteProduct?.id);
      expect(swappedIng.substituteProduct?.id, originalIng.matchedProduct?.id);
      expect(swappedRecipe.totalEstimatedCost, lessThan(originalCost));
    });

    test('ChatViewModel dynamically updates servings and substitutes', () async {
      await chatViewModel.sendMessage('Приготуй борщ на вечерю');
      expect(chatViewModel.messages.length, greaterThanOrEqualTo(2));

      final aiMsg = chatViewModel.messages.last;
      expect(aiMsg.recipe, isNotNull);
      final originalServings = aiMsg.recipe!.servings;

      // Scale servings via ViewModel
      final targetServings = originalServings == 4 ? 6 : 4;
      chatViewModel.updateRecipeServings(aiMsg.id, targetServings);
      final updatedMsg = chatViewModel.messages.firstWhere((m) => m.id == aiMsg.id);
      expect(updatedMsg.recipe!.servings, targetServings);
      expect(updatedMsg.recipe!.servings, isNot(originalServings));
    });
  });
}
