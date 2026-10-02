import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sulipo_pomoshuk/data/datasources/silpo_remote_datasource.dart';
import 'package:sulipo_pomoshuk/data/repositories/silpo_repository.dart';
import 'package:sulipo_pomoshuk/presentation/viewmodels/store_viewmodel.dart';
import 'package:sulipo_pomoshuk/presentation/widgets/silpo_feature_chip.dart';
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
      expect(gulliver.hasGenerator, isTrue);
      expect(gulliver.hasBakery, isTrue);
      expect(gulliver.hasFeeltrd, isTrue);
      expect(gulliver.imageUrl, isNotNull);
      expect(gulliver.amenities.any((a) => a.contains('генератором')), isTrue);
      expect(gulliver.amenities.any((a) => a.contains('пекарня')), isTrue);
      expect(gulliver.amenities.any((a) => a.contains('Feeltrd')), isTrue);
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

  group('StoreViewModel Expanded Amenities Filtering Tests', () {
    late StoreViewModel vm;

    setUp(() async {
      vm = StoreViewModel();
      await vm.loadStores();
    });

    test('EV Charging and Pharmacy filter toggles work properly', () {
      expect(vm.onlyWithEvCharging, isFalse);
      vm.toggleEvFilter();
      expect(vm.onlyWithEvCharging, isTrue);
      for (final s in vm.stores) {
        expect(
          s.hasEvCharging || s.amenities.any((a) => a.contains('EV') || a.contains('зарядка')),
          isTrue,
        );
      }

      vm.toggleEvFilter();
      expect(vm.onlyWithEvCharging, isFalse);

      vm.togglePharmacyFilter();
      expect(vm.onlyWithPharmacy, isTrue);
      for (final s in vm.stores) {
        expect(
          s.hasPharmacy || s.amenities.any((a) => a.contains('Аптека')),
          isTrue,
        );
      }
    });

    test('selectStore in ViewModel propagates to selectedStore', () {
      final target = vm.stores.last;
      vm.selectStore(target);
      expect(vm.selectedStore?.filialId, target.filialId);
    });
  });

  group('SilpoFeatureChip & SilpoNetworkImage Widget Tests', () {
    testWidgets('SilpoFeatureChip renders emoji and label matching screenshot design', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SilpoFeatureChip(
              emoji: '⚡',
              label: 'З генератором',
              isSelected: false,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('⚡'), findsOneWidget);
      expect(find.text('З генератором'), findsOneWidget);

      await tester.tap(find.byType(SilpoFeatureChip));
      await tester.pump();
      expect(tapped, isTrue);
    });

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
