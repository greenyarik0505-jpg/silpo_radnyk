import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../viewmodels/analytics_viewmodel.dart';
import '../widgets/category_spending_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  final AnalyticsViewModel analyticsViewModel;

  const AnalyticsScreen({
    super.key,
    required this.analyticsViewModel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: analyticsViewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.analyticsTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Оновити дані',
                onPressed: analyticsViewModel.loadAnalytics,
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: analyticsViewModel.loadAnalytics,
            color: AppColors.silpoOrange,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Digital Loyalty Card «Власний Рахунок»
                _buildLoyaltyCard(context),

                const SizedBox(height: 16),

                // KPI Metrics row
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard(
                        title: AppStrings.monthlySpending,
                        value: '${analyticsViewModel.totalSpentMonth.toStringAsFixed(0)} ₴',
                        subtitle: '2 замовлення',
                        icon: Icons.account_balance_wallet_outlined,
                        color: AppColors.silpoOrange,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildKpiCard(
                        title: 'Економія',
                        value: '${analyticsViewModel.totalSavedMonth.toStringAsFixed(0)} ₴',
                        subtitle: 'за «Цінотижиками»',
                        icon: Icons.savings_outlined,
                        color: AppColors.discountRed,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Category Spending Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.topCategories,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Icon(Icons.pie_chart_outline, size: 20, color: AppColors.silpoOrange),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CategorySpendingChart(
                          spendingList: analyticsViewModel.categorySpending,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Inflation Tracker Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.inflationTracker,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Icon(Icons.trending_up, size: 20, color: AppColors.successGreen),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ваш персональний продуктовий кошик здорожчав на 1.2% менше, ніж середньоринковий індекс завдяки акціям Сільпо.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: analyticsViewModel.inflationPoints.map((point) {
                            return Column(
                              children: [
                                Text(
                                  '+${point.personalInflationRate}%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppColors.silpoOrange,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 24,
                                  height: point.personalInflationRate * 18,
                                  decoration: BoxDecoration(
                                    color: AppColors.silpoOrange.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  point.month,
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Fiscal Receipts History Section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Text(
                    AppStrings.fiscalReceipts,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 8),

                ...analyticsViewModel.receipts.map((receipt) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ExpansionTile(
                      leading: const Icon(Icons.receipt_long, color: AppColors.silpoOrange),
                      title: Text(
                        '${receipt.totalAmount.toStringAsFixed(2)} ₴',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: Text(
                        '${receipt.storeAddress.split('(').first.trim()} • ${_formatDate(receipt.dateTime)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Фіскальний код: ${receipt.fiscalNumber}',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                              Text(
                                'Оплата: ${receipt.paymentMethod} • Балів: +${receipt.bonusPointsEarned}',
                                style: const TextStyle(fontSize: 11, color: AppColors.vlasnyiRakhunok, fontWeight: FontWeight.bold),
                              ),
                              const Divider(height: 16),
                              ...receipt.items.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${item.name} (${item.quantity} ${item.unit})',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      Text(
                                        '${item.total.toStringAsFixed(2)} ₴',
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoyaltyCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.workspace_premium, color: AppColors.silpoYellow, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Власний Рахунок',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.silpoOrange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Сільпо VIP',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Баланс балобонусів:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                    '${analyticsViewModel.loyaltyBalance} БАЛІВ',
                    style: const TextStyle(
                      color: AppColors.silpoYellow,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    '= ${(analyticsViewModel.loyaltyBalance / 100).toStringAsFixed(2)} ₴ знижки на касі',
                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                ],
              ),
              // Simulated QR code
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.qr_code, size: 48, color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
