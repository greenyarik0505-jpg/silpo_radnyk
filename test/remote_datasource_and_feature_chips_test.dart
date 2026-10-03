import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sulipo_pomoshuk/data/datasources/silpo_remote_datasource.dart';
import 'package:sulipo_pomoshuk/data/repositories/silpo_repository.dart';
import 'package:sulipo_pomoshuk/presentation/viewmodels/store_viewmodel.dart';
import 'package:sulipo_pomoshuk/presentation/widgets/silpo_network_image.dart';

void main() {
  group('Silpo Remote DataSource & Stores Tests', () {
    late SilpoRemoteDataSource remoteDataSource;

    setUp(() {
      remoteDataSource = SilpoRemoteDataSource();
    });

    test('getStores returns rich stores with themes and photos', () async {
      final stores = await remoteDataSource.getStores();
      expect(stores.isNotEmpty, isTrue);

      final gulliver = stores.firstWhere((s) => s.name.contains('Gulliver'));
      expect(gulliver.imageUrl, isNotNull);
      expect(gulliver.conceptTheme, isNotNull);
      expect(gulliver.amenities.isNotEmpty, isTrue);
      expect(gulliver.amenities.any((a) => a.toLowerCase().contains('піцерія') || a.toLowerCase().contains('суші')), isTrue);
      for (final s in stores) {
        for (final a in s.amenities) {
          final lower = a.toLowerCase();
          expect(lower.contains('генератор'), isFalse);
          expect(lower.contains('пекарн'), isFalse);
          expect(lower.contains('feeltrd'), isFalse);
          expect(lower.contains('зарядка') || lower.contains('ev'), isFalse);
          expect(lower.contains('аптека'), isFalse);
        }
      }
    });

    test('setActiveBranch updates active branch id in remote datasource', () {
      expect(remoteDataSource.activeBranchId, isNull);
      remoteDataSource.setActiveBranch('silpo_branch_123');
      expect(remoteDataSource.activeBranchId, 'silpo_branch_123');
    });

    test('searchProducts resolves products with CDN image URLs', () async {
      final products = await remoteDataSource.searchProducts('молоко');
      expect(products.isNotEmpty, isTrue);
      final p = products.first;
      expect(p.title.isNotEmpty, isTrue);
      expect(p.regularPrice, greaterThan(0));
    });

    test('searchProducts with empty query fetches promotional products', () async {
      final products = await remoteDataSource.searchProducts('');
      expect(products.isNotEmpty, isTrue);
      expect(products.any((p) => p.title.isNotEmpty), isTrue);
    });

    test('getCinotyzhiki returns promotional items with discounts', () async {
      final promos = await remoteDataSource.getCinotyzhiki();
      expect(promos.isNotEmpty, isTrue);
      expect(promos.first.discountPercent, greaterThan(0));
    });
  });

  group('SilpoRepository Active Store & Branch Propagation Tests', () {
    test('Selecting store in repository updates activeBranchId', () async {
      final repo = SilpoRepository();
      final stores = await repo.getStores();
      expect(stores.isNotEmpty, isTrue);

      final initialStore = repo.activeStore;
      expect(initialStore, isNotNull);

      final otherStore = stores.firstWhere((s) => s.filialId != initialStore!.filialId);
      repo.setActiveStore(otherStore);

      expect(repo.activeStore?.filialId, otherStore.filialId);
      expect(repo.activeBranchId, otherStore.filialId);
    });
  });

  group('StoreViewModel Store Selection and Navigation Tests', () {
    late StoreViewModel vm;

    setUp(() async {
      vm = StoreViewModel();
      await vm.loadStores();
    });

    test('Store list loads cleanly without obsolete service filters', () {
      expect(vm.stores.isNotEmpty, isTrue);
      expect(vm.selectedStore, isNotNull);
      expect(vm.cities.contains('Всі міста'), isTrue);
    });

    test('City filtering and search work in harmony', () {
      vm.filterCity('Київ');
      expect(vm.selectedCity, 'Київ');
      for (final s in vm.stores) {
        expect(s.city, 'Київ');
      }

      vm.search('Gulliver');
      expect(vm.stores.any((s) => s.name.contains('Gulliver')), isTrue);
    });

    test('selectStore in ViewModel propagates to selectedStore', () {
      final target = vm.stores.last;
      vm.selectStore(target);
      expect(vm.selectedStore?.filialId, target.filialId);
    });
  });

  group('SilpoNetworkImage Widget Tests', () {
    testWidgets('SilpoNetworkImage displays fallback icon gracefully when url is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SilpoNetworkImage(
              imageUrl: null,
              fallbackIcon: Icons.storefront,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.storefront), findsOneWidget);
    });
  });
}
