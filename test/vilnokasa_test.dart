import 'package:flutter_test/flutter_test.dart';
import 'package:sulipo_pomoshuk/data/repositories/silpo_repository.dart';
import 'package:sulipo_pomoshuk/presentation/viewmodels/cart_viewmodel.dart';

void main() {
  group('Вільнокаса (In-Store Barcode Scanner) Tests', () {
    late SilpoRepository repository;
    late CartViewModel cartViewModel;

    setUp(() {
      repository = SilpoRepository();
      cartViewModel = CartViewModel(repository: repository);
    });

    test('Valid Ukrainian barcode resolves to corresponding product', () async {
      // 482000000001 -> sour cream «Премія»
      final product = await repository.getProductByBarcode('482000000001');
      expect(product, isNotNull);
      expect(product!.title.contains('Сметана'), isTrue);
      expect(product.currentPrice, greaterThan(0.0));
      expect(product.bonusPoints, isNotNull);
    });

    test('Coffee barcode resolves to Lavazza Qualita Oro', () async {
      final product = await repository.getProductByBarcode('482000000002');
      expect(product, isNotNull);
      expect(product!.title.contains('Lavazza'), isTrue);
    });

    test('Unknown barcode returns null gracefully without exception', () async {
      final product = await repository.getProductByBarcode('000000000000');
      expect(product, isNull);
    });

    test('Scanned product added to cart updates totals and bonus points', () async {
      final product = await repository.getProductByBarcode('482000000001');
      expect(product, isNotNull);

      expect(cartViewModel.isEmpty, isTrue);
      cartViewModel.addProduct(product!);

      expect(cartViewModel.itemCount, 1);
      expect(cartViewModel.totalPrice, product.currentPrice);
      expect(cartViewModel.totalBonusPoints, greaterThan(0));
    });
  });
}
