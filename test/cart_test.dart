import 'package:flutter_test/flutter_test.dart';
import 'package:sulipo_pomoshuk/domain/entities/product.dart';
import 'package:sulipo_pomoshuk/domain/entities/delivery_slot.dart';
import 'package:sulipo_pomoshuk/presentation/viewmodels/cart_viewmodel.dart';
import 'package:sulipo_pomoshuk/data/repositories/silpo_repository.dart';

void main() {
  group('CartViewModel State and Calculations Tests', () {
    late CartViewModel cart;
    const testProduct1 = Product(
      id: 'test_1',
      title: 'Сир Гауда 48%',
      category: 'Сири',
      regularPrice: 100.0,
      promoPrice: 75.0, // savings = 25.0
      bonusPoints: 10,
    );

    const testProduct2 = Product(
      id: 'test_2',
      title: 'Кава зернова 250г',
      category: 'Кава',
      regularPrice: 200.0,
      promoPrice: null, // no discount
      bonusPoints: 20,
    );

    setUp(() {
      cart = CartViewModel(repository: SilpoRepository());
    });

    test('Cart starts empty', () {
      expect(cart.isEmpty, isTrue);
      expect(cart.itemCount, 0);
      expect(cart.totalPrice, 0.0);
    });

    test('Adding products computes price and savings properly', () {
      cart.addProduct(testProduct1, quantity: 2);
      expect(cart.isEmpty, isFalse);
      expect(cart.itemCount, 2);
      expect(cart.totalPrice, 150.0); // 75 * 2
      expect(cart.totalRegularPrice, 200.0); // 100 * 2
      expect(cart.totalSavings, 50.0); // 25 * 2
      expect(cart.totalBonusPoints, 20); // 10 * 2

      cart.addProduct(testProduct2, quantity: 1);
      expect(cart.itemCount, 3);
      expect(cart.totalPrice, 350.0); // 150 + 200
      expect(cart.totalSavings, 50.0);
      expect(cart.totalBonusPoints, 40); // 20 + 20
    });

    test('Updating quantity and removing item works', () {
      cart.addProduct(testProduct1, quantity: 2);
      cart.updateQuantity(testProduct1.id, 4);
      expect(cart.itemCount, 4);
      expect(cart.totalPrice, 300.0);

      cart.updateQuantity(testProduct1.id, 0);
      expect(cart.isEmpty, isTrue);
    });

    test('Toggling auto replenishment updates flag', () {
      cart.addProduct(testProduct1);
      expect(cart.items.first.isAutoReplenish, isFalse);

      cart.toggleAutoReplenish(testProduct1.id, days: 7);
      expect(cart.items.first.isAutoReplenish, isTrue);
      expect(cart.items.first.replenishIntervalDays, 7);

      cart.toggleAutoReplenish(testProduct1.id);
      expect(cart.items.first.isAutoReplenish, isFalse);
    });

    test('Selecting delivery slot reflects in final total', () {
      cart.addProduct(testProduct1, quantity: 1);
      expect(cart.totalPrice, 75.0);

      final slot = DeliverySlot(
        id: 'express_slot',
        type: DeliveryType.express,
        timeRange: '40 хв',
        date: DateTime.now(),
        deliveryFee: 49.0,
        description: 'Експрес',
      );

      cart.selectDeliverySlot(slot);
      expect(cart.deliveryFee, 49.0);
      expect(cart.finalTotal, 124.0); // 75 + 49
    });

    test('Clear cart empties everything', () {
      cart.addProduct(testProduct1);
      cart.addProduct(testProduct2);
      expect(cart.items.length, 2);

      cart.clearCart();
      expect(cart.isEmpty, isTrue);
      expect(cart.totalPrice, 0.0);
    });
  });
}
