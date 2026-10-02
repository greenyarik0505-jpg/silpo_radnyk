import 'package:flutter/foundation.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/delivery_slot.dart';
import '../../data/repositories/silpo_repository.dart';

/// ViewModel managing shopping cart state, delivery options and checkout calculations.
class CartViewModel extends ChangeNotifier {
  final SilpoRepository _repository;

  final Map<String, CartItem> _items = {};
  DeliverySlot? _selectedSlot;
  List<DeliverySlot> _availableSlots = [];
  bool _isLoadingSlots = false;

  CartViewModel({SilpoRepository? repository})
      : _repository = repository ?? SilpoRepository() {
    loadDeliverySlots();
  }

  List<CartItem> get items => _items.values.toList();
  int get itemCount => _items.values.fold(0, (sum, i) => sum + (i.quantity.round()));
  int get uniqueItemCount => _items.length;
  bool get isEmpty => _items.isEmpty;

  DeliverySlot? get selectedSlot => _selectedSlot;
  List<DeliverySlot> get availableSlots => _availableSlots;
  bool get isLoadingSlots => _isLoadingSlots;

  double get totalPrice {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get totalRegularPrice {
    return _items.values.fold(0.0, (sum, item) => sum + item.regularTotalPrice);
  }

  double get totalSavings {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalSavings);
  }

  int get totalBonusPoints {
    return _items.values.fold(0, (sum, item) => sum + item.earnedBonusPoints);
  }

  double get deliveryFee => _selectedSlot?.deliveryFee ?? 0.0;

  double get finalTotal => totalPrice + deliveryFee;

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

  void removeItem(String productId) {
    if (_items.containsKey(productId)) {
      _items.remove(productId);
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void toggleAutoReplenish(String productId, {int days = 7}) {
    if (!_items.containsKey(productId)) return;
    final item = _items[productId]!;
    _items[productId] = item.copyWith(
      isAutoReplenish: !item.isAutoReplenish,
      replenishIntervalDays: !item.isAutoReplenish ? days : null,
    );
    notifyListeners();
  }

  void swapWithSubstitute(String productId, Product substitute) {
    if (!_items.containsKey(productId)) return;
    final item = _items[productId]!;
    _items[productId] = item.copyWith(substitute: substitute);
    notifyListeners();
  }

  void selectDeliverySlot(DeliverySlot slot) {
    _selectedSlot = slot;
    notifyListeners();
  }

  Future<void> loadDeliverySlots() async {
    _isLoadingSlots = true;
    notifyListeners();
    try {
      _availableSlots = await _repository.getDeliverySlots();
      if (_availableSlots.isNotEmpty && _selectedSlot == null) {
        _selectedSlot = _availableSlots.first;
      }
    } finally {
      _isLoadingSlots = false;
      notifyListeners();
    }
  }
}
