import 'package:flutter/foundation.dart';
import '../../domain/entities/promo.dart';
import '../../data/repositories/silpo_repository.dart';

class PromoViewModel extends ChangeNotifier {
  final SilpoRepository _repository;

  List<PromoItem> _allPromos = [];
  String? _selectedCategory;
  bool _isLoading = false;
  bool _isSpinning = false;
  String? _wheelPrize;
  bool _hasSpunWheel = false;

  PromoViewModel({SilpoRepository? repository})
      : _repository = repository ?? SilpoRepository() {
    loadPromos();
  }

  List<PromoItem> get promos {
    if (_selectedCategory == null || _selectedCategory == 'Всі') {
      return _allPromos;
    }
    return _allPromos.where((p) => p.category == _selectedCategory).toList();
  }

  List<PromoItem> get cinotyzhiki =>
      _allPromos.where((p) => p.type == PromoType.cinotyzhik).toList();

  List<PromoItem> get personalDeals =>
      _allPromos.where((p) => p.type == PromoType.personalDeal).toList();

  String? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get isSpinning => _isSpinning;
  String? get wheelPrize => _wheelPrize;
  bool get hasSpunWheel => _hasSpunWheel;

  List<String> get categories {
    final set = {'Всі', ..._allPromos.map((p) => p.category)};
    return set.toList();
  }

  Future<void> loadPromos() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allPromos = await _repository.getPromos();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> spinWheel() async {
    if (_isSpinning || _hasSpunWheel) return;
    _isSpinning = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1500));

    final prizes = [
      'Знижка 25% на свіжу випічку',
      'х5 балів «Власний Рахунок» на сири',
      'Безкоштовна експрес-доставка',
      'Кава Feeltrd за 1 грн',
      'Знижка 15% на крафтовий шоколад',
    ];
    _wheelPrize = prizes[DateTime.now().microsecond % prizes.length];
    _isSpinning = false;
    _hasSpunWheel = true;
    notifyListeners();
  }
}
