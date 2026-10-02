import 'package:flutter/foundation.dart';
import '../../domain/entities/receipt.dart';
import '../../data/repositories/silpo_repository.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final SilpoRepository _repository;

  List<FiscalReceipt> _receipts = [];
  List<CategorySpending> _categorySpending = [];
  List<InflationPoint> _inflationPoints = [];
  int _loyaltyBalance = 0;
  bool _isLoading = false;

  AnalyticsViewModel({SilpoRepository? repository})
      : _repository = repository ?? SilpoRepository() {
    loadAnalytics();
  }

  List<FiscalReceipt> get receipts => _receipts;
  List<CategorySpending> get categorySpending => _categorySpending;
  List<InflationPoint> get inflationPoints => _inflationPoints;
  int get loyaltyBalance => _loyaltyBalance;
  bool get isLoading => _isLoading;

  double get totalSpentMonth => _receipts.fold(0.0, (sum, r) => sum + r.totalAmount);
  double get totalSavedMonth => _receipts.fold(0.0, (sum, r) => sum + r.discountAmount);
  int get totalPointsEarned => _receipts.fold(0, (sum, r) => sum + r.bonusPointsEarned);

  Future<void> loadAnalytics() async {
    _isLoading = true;
    notifyListeners();
    try {
      _receipts = await _repository.getFiscalReceipts();
      _categorySpending = await _repository.getCategorySpending();
      _inflationPoints = _repository.getInflationMetrics();
      _loyaltyBalance = await _repository.getLoyaltyBalance();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
