import 'package:flutter/foundation.dart';
import '../../domain/entities/store.dart';
import '../../data/repositories/silpo_repository.dart';

class StoreViewModel extends ChangeNotifier {
  final SilpoRepository _repository;

  List<SilpoStore> _allStores = [];
  SilpoStore? _selectedStore;
  String _searchQuery = '';
  String? _selectedCity;
  bool _isLoading = false;

  StoreViewModel({SilpoRepository? repository})
      : _repository = repository ?? SilpoRepository() {
    loadStores();
  }

  List<SilpoStore> get stores {
    return _allStores.where((s) {
      final matchesQuery = _searchQuery.isEmpty ||
          s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (s.conceptTheme != null && s.conceptTheme!.toLowerCase().contains(_searchQuery.toLowerCase()));
      final matchesCity = _selectedCity == null || _selectedCity == 'Всі міста' || s.city == _selectedCity;
      return matchesQuery && matchesCity;
    }).toList();
  }

  SilpoStore? get selectedStore => _selectedStore;
  String? get selectedCity => _selectedCity;
  bool get isLoading => _isLoading;

  List<String> get cities => ['Всі міста', 'Київ', 'Львів', 'Одеса', 'Дніпро'];

  Future<void> loadStores() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allStores = await _repository.getStores();
      if (_allStores.isNotEmpty && _selectedStore == null) {
        _selectedStore = _allStores.firstWhere((s) => s.isFavorite, orElse: () => _allStores.first);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void filterCity(String? city) {
    _selectedCity = city;
    notifyListeners();
  }

  void selectStore(SilpoStore store) {
    _selectedStore = store;
    notifyListeners();
  }

  void toggleFavorite(String filialId) {
    final index = _allStores.indexWhere((s) => s.filialId == filialId);
    if (index != -1) {
      final current = _allStores[index];
      _allStores[index] = current.copyWith(isFavorite: !current.isFavorite);
      if (_selectedStore?.filialId == filialId) {
        _selectedStore = _allStores[index];
      }
      notifyListeners();
    }
  }
}
