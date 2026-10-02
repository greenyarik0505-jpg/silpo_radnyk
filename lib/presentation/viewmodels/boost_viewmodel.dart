import 'package:flutter/foundation.dart';
import '../../domain/entities/silpo_boost.dart';
import '../../domain/entities/product.dart';
import '../../data/repositories/silpo_repository.dart';

/// ViewModel managing Silpo Boost loyalty multipliers, screen brightness boost, and coupons.
class BoostViewModel extends ChangeNotifier {
  final SilpoRepository _repository;

  List<SilpoBoostCoupon> _coupons = [];
  bool _isLoading = false;
  bool _isBrightnessMaximized = false;
  bool _isTurboModeEnabled = true;

  BoostViewModel({SilpoRepository? repository})
      : _repository = repository ?? SilpoRepository() {
    loadCoupons();
  }

  List<SilpoBoostCoupon> get coupons => List.unmodifiable(_coupons);
  bool get isLoading => _isLoading;
  bool get isBrightnessMaximized => _isBrightnessMaximized;
  bool get isTurboModeEnabled => _isTurboModeEnabled;

  int get activeCouponsCount => _coupons.where((c) => c.isActivated).length;

  Future<void> loadCoupons() async {
    _isLoading = true;
    notifyListeners();

    try {
      _coupons = List<SilpoBoostCoupon>.from(await _repository.getBoostCoupons());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleCoupon(String id) async {
    final success = await _repository.activateBoostCoupon(id);
    if (success) {
      final index = _coupons.indexWhere((c) => c.id == id);
      if (index != -1) {
        final current = _coupons[index];
        _coupons[index] = current.copyWith(isActivated: !current.isActivated);
        notifyListeners();
      }
    }
  }

  void toggleBrightness() {
    _isBrightnessMaximized = !_isBrightnessMaximized;
    notifyListeners();
  }

  void toggleTurboMode() {
    _isTurboModeEnabled = !_isTurboModeEnabled;
    notifyListeners();
  }

  /// Calculates boosted bonus points for a given product taking active boost coupons into account.
  int calculateBoostedPoints(Product product) {
    double multiplier = 1.0;
    int extra = 0;

    for (final c in _coupons) {
      if (c.isActivated) {
        if (c.category == product.category || c.category == 'Усі товари') {
          if (c.multiplier > multiplier) {
            multiplier = c.multiplier;
          }
          extra += c.extraBonusPoints;
        }
      }
    }

    final base = ((product.bonusPoints ?? 0) * multiplier).round();
    return base + extra;
  }
}
