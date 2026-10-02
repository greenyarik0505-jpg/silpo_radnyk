import 'package:flutter_test/flutter_test.dart';
import 'package:sulipo_pomoshuk/data/repositories/silpo_repository.dart';
import 'package:sulipo_pomoshuk/presentation/viewmodels/boost_viewmodel.dart';
import 'package:sulipo_pomoshuk/domain/entities/product.dart';

void main() {
  group('Silpo Boost & Balochka Loyalty Tests', () {
    late SilpoRepository repository;
    late BoostViewModel boostViewModel;

    setUp(() {
      repository = SilpoRepository();
      boostViewModel = BoostViewModel(repository: repository);
    });

    test('Boost coupons load successfully with active multipliers', () async {
      await boostViewModel.loadCoupons();
      expect(boostViewModel.coupons.isNotEmpty, isTrue);
      expect(boostViewModel.activeCouponsCount, greaterThan(0));

      final coffeeCoupon = boostViewModel.coupons.firstWhere((c) => c.id == 'boost_coffee_x3');
      expect(coffeeCoupon.multiplier, 3.0);
    });

    test('Toggling coupon flips activation state', () async {
      await boostViewModel.loadCoupons();
      final coupon = boostViewModel.coupons.firstWhere((c) => c.id == 'boost_bakery_x5');
      final initialActivated = coupon.isActivated;

      await boostViewModel.toggleCoupon('boost_bakery_x5');
      final updated = boostViewModel.coupons.firstWhere((c) => c.id == 'boost_bakery_x5');
      expect(updated.isActivated, !initialActivated);
    });

    test('Calculating boosted points applies multipliers for matching categories', () async {
      await boostViewModel.loadCoupons();

      // Product in 'Кава та чай' category where boost_coffee_x3 is active
      const coffee = Product(
        id: 'test_coffee',
        title: 'Кава Lavazza',
        category: 'Кава та чай',
        regularPrice: 200,
        unit: 'шт',
        bonusPoints: 20,
      );

      final boostedPoints = boostViewModel.calculateBoostedPoints(coffee);
      expect(boostedPoints, greaterThanOrEqualTo(60)); // 20 * 3 = 60
    });

    test('Screen brightness and Turbo mode toggle properly', () {
      expect(boostViewModel.isBrightnessMaximized, isFalse);
      boostViewModel.toggleBrightness();
      expect(boostViewModel.isBrightnessMaximized, isTrue);
      boostViewModel.toggleBrightness();
      expect(boostViewModel.isBrightnessMaximized, isFalse);

      final initialTurbo = boostViewModel.isTurboModeEnabled;
      boostViewModel.toggleTurboMode();
      expect(boostViewModel.isTurboModeEnabled, !initialTurbo);
    });
  });
}
