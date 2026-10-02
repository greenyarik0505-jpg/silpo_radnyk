import 'package:flutter/foundation.dart';
import '../../domain/entities/promo.dart';
import '../../data/repositories/silpo_repository.dart';

class PromoViewModel extends ChangeNotifier {
  final SilpoRepository _repository;

  List<PromoItem> _allPromos = [];
  String? _selectedCategory;
  bool _isLoading = false;

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
}
