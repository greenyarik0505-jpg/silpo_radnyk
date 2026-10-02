import 'package:flutter_test/flutter_test.dart';
import 'package:sulipo_pomoshuk/data/repositories/silpo_repository.dart';
import 'package:sulipo_pomoshuk/presentation/viewmodels/analytics_viewmodel.dart';

void main() {
  group('Receipts & Analytics Calculation Tests', () {
    late SilpoRepository repository;
    late AnalyticsViewModel analytics;

    setUp(() {
      repository = SilpoRepository();
      analytics = AnalyticsViewModel(repository: repository);
    });

    test('Category spending aggregates correctly from fiscal checks', () async {
      final categories = await repository.getCategorySpending();
      expect(categories.isNotEmpty, isTrue);

      final sumPercentage = categories.fold(0.0, (sum, c) => sum + c.percentage);
      expect(sumPercentage, closeTo(100.0, 0.5));

      final totalSpent = categories.fold(0.0, (sum, c) => sum + c.amount);
      expect(totalSpent, greaterThan(500.0));
    });

    test('Inflation metrics are provided', () {
      final metrics = repository.getInflationMetrics();
      expect(metrics.length, greaterThanOrEqualTo(5));
      expect(metrics.first.personalInflationRate, greaterThan(0.0));
    });

    test('Analytics ViewModel loads fiscal receipts and loyalty balance', () async {
      await analytics.loadAnalytics();
      expect(analytics.receipts.isNotEmpty, isTrue);
      expect(analytics.loyaltyBalance, greaterThan(0));
      expect(analytics.totalSpentMonth, greaterThan(0.0));
      expect(analytics.totalSavedMonth, greaterThan(0.0));
    });
  });
}
