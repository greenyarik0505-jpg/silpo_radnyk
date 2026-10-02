import 'package:flutter/foundation.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/entities/cart_item.dart';
import '../../data/repositories/silpo_repository.dart';

import '../../domain/entities/receipt.dart';

/// ViewModel managing shopping cart state and product quantities.
class CartViewModel extends ChangeNotifier {
  final SilpoRepository _repository;
  final Map<String, CartItem> _items = {};
  final List<FiscalReceipt> _orderHistory = [];

  CartViewModel({SilpoRepository? repository})
      : _repository = repository ?? SilpoRepository();

  SilpoRepository get repository => _repository;
  List<FiscalReceipt> get orderHistory => List.unmodifiable(_orderHistory);

  List<CartItem> get items => _items.values.toList();
  int get itemCount => _items.values.fold(0, (sum, i) => sum + (i.quantity.round()));
  int get uniqueItemCount => _items.length;
  bool get isEmpty => _items.isEmpty;

  double get totalPrice {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get finalTotal => totalPrice;

  double get totalRegularPrice {
    return _items.values.fold(0.0, (sum, item) => sum + item.regularTotalPrice);
  }

  double get totalSavings {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalSavings);
  }

  int get totalBonusPoints {
    return _items.values.fold(0, (sum, item) => sum + item.earnedBonusPoints);
  }

  void addProduct(Product product, {double quantity = 1.0}) {
    if (_items.containsKey(product.id)) {
      final current = _items[product.id]!;
      _items[product.id] = current.copyWith(quantity: current.quantity + quantity);
    } else {
      _items[product.id] = CartItem(product: product, quantity: quantity);
    }
    notifyListeners();
  }

  void addRecipeIngredients(Recipe recipe) {
    for (final ing in recipe.ingredients) {
      final p = ing.substituteProduct ?? ing.matchedProduct;
      if (p != null) {
        addProduct(p, quantity: 1.0);
      }
    }
    notifyListeners();
  }

  void updateQuantity(String productId, double quantity) {
    if (!_items.containsKey(productId)) return;
    if (quantity <= 0) {
      _items.remove(productId);
    } else {
      _items[productId] = _items[productId]!.copyWith(quantity: quantity);
    }
    notifyListeners();
  }

  double get totalWeightGrams {
    return _items.values.fold(0.0, (sum, item) {
      final grams = item.product.weightGrams > 0 ? item.product.weightGrams : 500.0;
      return sum + (grams * item.quantity);
    });
  }

  bool get autoReplenishment => _items.values.any((item) => item.isAutoReplenish);

  void removeItem(String productId) {
    if (_items.containsKey(productId)) {
      _items.remove(productId);
      notifyListeners();
    }
  }

  void removeProduct(String productId) => removeItem(productId);

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void toggleAutoReplenish(String? productId, {int days = 7}) {
    final effectiveDays = days;
    if (productId == null) {
      final newState = !autoReplenishment;
      for (final key in _items.keys.toList()) {
        final item = _items[key]!;
        _items[key] = item.copyWith(
          isAutoReplenish: newState,
          replenishIntervalDays: newState ? effectiveDays : null,
        );
      }
      notifyListeners();
      return;
    }

    if (!_items.containsKey(productId)) return;
    final item = _items[productId]!;
    _items[productId] = item.copyWith(
      isAutoReplenish: !item.isAutoReplenish,
      replenishIntervalDays: !item.isAutoReplenish ? effectiveDays : null,
    );
    notifyListeners();
  }

  FiscalReceipt placeOrder({
    required String storeAddress,
    required String deliveryType,
    required String paymentMethod,
    double deliveryFee = 0.0,
  }) {
    final receiptItems = _items.values.map((item) {
      return ReceiptItem(
        name: item.product.title,
        quantity: item.quantity,
        unit: item.product.unit,
        price: item.product.currentPrice,
        total: item.totalPrice,
        discountAmount: item.totalSavings,
        category: item.product.category,
      );
    }).toList();

    final orderId = 'SLP-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
    final fiscalNumber = 'ФН ${DateTime.now().millisecondsSinceEpoch}';

    final receipt = FiscalReceipt(
      id: orderId,
      fiscalNumber: fiscalNumber,
      dateTime: DateTime.now(),
      storeAddress: storeAddress,
      totalAmount: totalPrice + deliveryFee,
      discountAmount: totalSavings,
      bonusPointsEarned: (totalPrice).round() * 3, // loyalty boost 3x
      items: receiptItems,
      paymentMethod: paymentMethod,
    );

    _orderHistory.insert(0, receipt);
    clearCart();
    return receipt;
  }
}
