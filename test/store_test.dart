import 'package:flutter_test/flutter_test.dart';
import 'package:sulipo_pomoshuk/presentation/viewmodels/store_viewmodel.dart';
import 'package:sulipo_pomoshuk/data/repositories/silpo_repository.dart';

void main() {
  group('Silpo Stores & Themes Tests', () {
    late StoreViewModel storeViewModel;

    setUp(() {
      storeViewModel = StoreViewModel(repository: SilpoRepository());
    });

    test('Stores load with concepts and themes', () async {
      await storeViewModel.loadStores();
      expect(storeViewModel.stores.isNotEmpty, isTrue);
      expect(storeViewModel.selectedStore, isNotNull);
      expect(storeViewModel.stores.any((s) => s.conceptTheme != null), isTrue);
    });

    test('City filtering works', () async {
      await storeViewModel.loadStores();
      storeViewModel.filterCity('Львів');
      expect(storeViewModel.selectedCity, 'Львів');
      for (final s in storeViewModel.stores) {
        expect(s.city, 'Львів');
      }

      storeViewModel.filterCity('Всі міста');
      expect(storeViewModel.stores.length, greaterThan(1));
    });

    test('Search by query matches store name or concept', () async {
      await storeViewModel.loadStores();
      storeViewModel.search('Мавка');
      expect(storeViewModel.stores.length, 1);
      expect(storeViewModel.stores.first.conceptTheme, contains('Мавка'));

      storeViewModel.search('');
      expect(storeViewModel.stores.length, greaterThan(1));
    });

    test('Toggling favorite updates store', () async {
      await storeViewModel.loadStores();
      final store = storeViewModel.stores.first;
      final initialFavorite = store.isFavorite;

      storeViewModel.toggleFavorite(store.filialId);
      final updated = storeViewModel.stores.firstWhere((s) => s.filialId == store.filialId);
      expect(updated.isFavorite, !initialFavorite);
    });

    test('Loaded stores do not contain obsolete service chips in amenities', () async {
      await storeViewModel.loadStores();
      for (final s in storeViewModel.stores) {
        for (final a in s.amenities) {
          final lower = a.toLowerCase();
          expect(lower.contains('генератор'), isFalse, reason: 'Found generator in ${s.name}: $a');
          expect(lower.contains('пекарн'), isFalse, reason: 'Found bakery in ${s.name}: $a');
          expect(lower.contains('feeltrd'), isFalse, reason: 'Found Feeltrd in ${s.name}: $a');
          expect(lower.contains('зарядка') || lower.contains('ev'), isFalse, reason: 'Found EV in ${s.name}: $a');
          expect(lower.contains('аптека'), isFalse, reason: 'Found pharmacy in ${s.name}: $a');
        }
      }
    });
  });
}
