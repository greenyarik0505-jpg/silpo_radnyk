import 'package:flutter_test/flutter_test.dart';
import 'package:sulipo_pomoshuk/presentation/viewmodels/promo_viewmodel.dart';
import 'package:sulipo_pomoshuk/data/repositories/silpo_repository.dart';

void main() {
  group('Promos & Catalog Tests', () {
    late PromoViewModel promoViewModel;

    setUp(() {
      promoViewModel = PromoViewModel(repository: SilpoRepository());
    });

    test('Promos load with Cinotyzhiki and Personal Deals', () async {
      await promoViewModel.loadPromos();
      expect(promoViewModel.promos.isNotEmpty, isTrue);
      expect(promoViewModel.cinotyzhiki.isNotEmpty, isTrue);
      expect(promoViewModel.categories.contains('Всі'), isTrue);
    });

    test('Filtering by category limits results', () async {
      await promoViewModel.loadPromos();
      promoViewModel.selectCategory('Риба');
      expect(promoViewModel.selectedCategory, 'Риба');
      for (final p in promoViewModel.promos) {
        expect(p.category, 'Риба');
      }

      promoViewModel.selectCategory('Всі');
      expect(promoViewModel.promos.length, greaterThan(1));
    });
  });
}
