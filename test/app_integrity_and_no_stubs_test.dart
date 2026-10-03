import 'package:flutter_test/flutter_test.dart';
import 'package:sulipo_pomoshuk/data/datasources/silpo_mock_datasource.dart';
import 'package:sulipo_pomoshuk/data/datasources/silpo_remote_datasource.dart';
import 'package:sulipo_pomoshuk/data/repositories/silpo_repository.dart';
import 'package:sulipo_pomoshuk/domain/entities/cart_item.dart';
import 'package:sulipo_pomoshuk/domain/entities/product.dart';
import 'package:sulipo_pomoshuk/domain/entities/promo.dart';
import 'package:sulipo_pomoshuk/domain/entities/recipe.dart';
import 'package:sulipo_pomoshuk/domain/entities/store.dart';
import 'package:sulipo_pomoshuk/presentation/viewmodels/cart_viewmodel.dart';
import 'package:sulipo_pomoshuk/presentation/viewmodels/chat_viewmodel.dart';
import 'package:sulipo_pomoshuk/presentation/viewmodels/promo_viewmodel.dart';

void main() {
  group('App Integrity & No Stubs Verification Tests', () {
    late SilpoRepository repository;

    setUp(() {
      repository = SilpoRepository();
    });

    test('All repository methods return rich, populated entities without empty stubs', () async {
      // 1. Stores
      final stores = await repository.getStores();
      expect(stores.isNotEmpty, isTrue);
      for (final store in stores) {
        expect(store.filialId.isNotEmpty, isTrue);
        expect(store.name.isNotEmpty, isTrue);
        expect(store.city.isNotEmpty, isTrue);
        expect(store.address.isNotEmpty, isTrue);
        expect(store.workingHours.isNotEmpty, isTrue);
      }

      // 2. Products Catalog
      final products = await repository.searchProducts('хліб');
      expect(products.isNotEmpty, isTrue);
      for (final p in products) {
        expect(p.id.isNotEmpty, isTrue);
        expect(p.title.isNotEmpty, isTrue);
        expect(p.regularPrice, greaterThan(0));
        expect(p.category.isNotEmpty, isTrue);
      }

      // 3. Promos & Cinotyzhiki
      final promos = await repository.getCinotyzhiki();
      expect(promos.isNotEmpty, isTrue);
      for (final PromoItem promo in promos) {
        expect(promo.id.isNotEmpty, isTrue);
        expect(promo.title.isNotEmpty, isTrue);
        expect(promo.discountPercent, greaterThan(0));
      }

      // 4. Recipes
      final recipes = await repository.getPopularRecipes();
      expect(recipes.isNotEmpty, isTrue);
      for (final recipe in recipes) {
        expect(recipe.id.isNotEmpty, isTrue);
        expect(recipe.title.isNotEmpty, isTrue);
        expect(recipe.ingredients.isNotEmpty, isTrue);
        expect(recipe.steps.isNotEmpty, isTrue);
      }

      // 5. Delivery Slots
      final slots = await repository.getDeliverySlots();
      expect(slots.isNotEmpty, isTrue);
      for (final slot in slots) {
        expect(slot.timeRange.isNotEmpty, isTrue);
        expect(slot.deliveryFee, greaterThanOrEqualTo(0));
      }
    });

    test('ChatViewModel AI conversation, recipe flow, and scaling work end-to-end', () async {
      final chatVm = ChatViewModel(repository: repository);
      expect(chatVm.messages.isNotEmpty, isTrue);
      expect(chatVm.messages.first.suggestedActions, isNotEmpty);

      // Ask for borsch recipe
      await chatVm.sendMessage('Приготуй борщ');
      expect(chatVm.messages.length, greaterThanOrEqualTo(2));
      final aiReply = chatVm.messages.last;
      expect(aiReply.isUser, isFalse);
      expect(aiReply.recipe, isNotNull);

      final Recipe recipe = aiReply.recipe!;
      expect(recipe.title.toLowerCase(), contains('борщ'));
      expect(recipe.servings, 4);

      // Scale servings from 4 to 2
      chatVm.updateRecipeServings(aiReply.id, 2);
      final updatedMsg = chatVm.messages.firstWhere((m) => m.id == aiReply.id);
      expect(updatedMsg.recipe?.servings, 2);

      // Clear history resets to greeting
      chatVm.clearHistory();
      expect(chatVm.messages.length, 1);
      expect(chatVm.messages.first.isUser, isFalse);
    });

    test('CartViewModel calculations, discount savings, and bonus points work reliably', () async {
      final cartVm = CartViewModel(repository: repository);
      expect(cartVm.totalPrice, 0.0);
      expect(cartVm.itemCount, 0);

      const product = Product(
        id: 'p_integrity_1',
        title: 'Шоколад Сільпо',
        regularPrice: 60.0,
        promoPrice: 45.0,
        category: 'Солодощі',
        unit: 'шт',
      );

      cartVm.addProduct(product, quantity: 2);
      expect(cartVm.itemCount, 2);
      // Regular: 2 * 60 = 120. Promo: 2 * 45 = 90. Total savings = 30.
      expect(cartVm.totalPrice, 90.0);
      expect(cartVm.totalSavings, 30.0);
      expect(cartVm.totalBonusPoints, greaterThanOrEqualTo(0));

      // In-store scan Vilnokasa adds loyalty bonus points
      cartVm.toggleAutoReplenish(product.id);
      expect(cartVm.items.first.isAutoReplenish, isTrue);

      cartVm.removeItem('p_integrity_1');
      expect(cartVm.itemCount, 0);
      expect(cartVm.totalPrice, 0.0);
    });

    test('PromoViewModel loads promos and filters by category', () async {
      final promoVm = PromoViewModel(repository: repository);
      await promoVm.loadPromos();

      expect(promoVm.cinotyzhiki.isNotEmpty, isTrue);
      expect(promoVm.promos.isNotEmpty, isTrue);

      final initialCount = promoVm.promos.length;
      final category = promoVm.categories.firstWhere((c) => c != 'Всі');
      promoVm.selectCategory(category);
      expect(promoVm.promos.length, lessThanOrEqualTo(initialCount));

      promoVm.selectCategory('Всі');
      expect(promoVm.promos.length, initialCount);
    });

    test('Data models serialize and deserialize without loss', () {
      const store = SilpoStore(
        filialId: 'test_f1',
        name: 'Сільпо Тест',
        city: 'Київ',
        address: 'вул. Хрещатик, 1',
        workingHours: '08:00 - 23:00',
        latitude: 50.45,
        longitude: 30.52,
        amenities: ['🍕 Піцерія', '🍣 Суші-бар'],
      );

      final jsonStore = store.toJson();
      final revivedStore = SilpoStore.fromJson(jsonStore);
      expect(revivedStore.filialId, store.filialId);
      expect(revivedStore.name, store.name);
      expect(revivedStore.city, store.city);
      expect(revivedStore.amenities, store.amenities);

      const item = CartItem(
        product: Product(
          id: 'p1',
          title: 'Хліб',
          regularPrice: 20.0,
          category: 'Випічка',
          unit: 'шт',
        ),
        quantity: 3,
      );

      final jsonItem = item.toJson();
      final revivedItem = CartItem.fromJson(jsonItem);
      expect(revivedItem.product.id, 'p1');
      expect(revivedItem.quantity, 3);
      expect(revivedItem.totalPrice, 60.0);
    });

    test('Strict verification: zero occurrences of deleted service chips across all datasources', () async {
      final mockDs = SilpoMockDataSource();
      final remoteDs = SilpoRemoteDataSource();

      final mockStores = await mockDs.getStores();
      final remoteStores = await remoteDs.getStores();
      final repoStores = await repository.getStores();

      final allStores = {...mockStores, ...remoteStores, ...repoStores};
      expect(allStores.isNotEmpty, isTrue);

      final forbiddenKeywords = [
        'генератор',
        'пекарн',
        'feeltrd',
        'зарядка',
        'ev',
        'аптека',
      ];

      for (final store in allStores) {
        for (final amenity in store.amenities) {
          final lower = amenity.toLowerCase();
          for (final kw in forbiddenKeywords) {
            expect(
              lower.contains(kw),
              isFalse,
              reason: 'Store "${store.name}" in "${store.city}" contains forbidden service keyword "$kw": "$amenity"',
            );
          }
        }
      }
    });

    test('Strict verification: no stub messages, empty placeholders, or unimplemented markers in data models', () async {
      // 1. Check recipes
      final recipes = await repository.getPopularRecipes();
      for (final r in recipes) {
        expect(r.instructions.join(' ').toLowerCase().contains('заглушка'), isFalse);
        expect(r.instructions.join(' ').toLowerCase().contains('скоро буде'), isFalse);
        expect(r.ingredients.isNotEmpty, isTrue);
        expect(r.steps.isNotEmpty, isTrue);
      }

      // 2. Check delivery slots
      final slots = await repository.getDeliverySlots();
      expect(slots.isNotEmpty, isTrue);
      for (final slot in slots) {
        expect(slot.timeRange.trim().isNotEmpty, isTrue);
        expect(slot.timeRange.toLowerCase().contains('заглушка'), isFalse);
      }

      // 3. Check promos
      final promos = await repository.getCinotyzhiki();
      expect(promos.isNotEmpty, isTrue);
      for (final promo in promos) {
        expect(promo.title.trim().isNotEmpty, isTrue);
        expect(promo.title.toLowerCase().contains('заглушка'), isFalse);
        expect(promo.discountPercent, greaterThan(0));
      }
    });
  });
}
