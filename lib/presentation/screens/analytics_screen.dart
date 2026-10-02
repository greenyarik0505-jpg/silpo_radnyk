import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../viewmodels/analytics_viewmodel.dart';
import '../viewmodels/boost_viewmodel.dart';
import '../widgets/category_spending_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  final AnalyticsViewModel analyticsViewModel;
  final BoostViewModel? boostViewModel;

  const AnalyticsScreen({
    super.key,
    required this.analyticsViewModel,
    this.boostViewModel,
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

                // Silpo Boost Accelerators Section
                if (boostViewModel != null) ...[
                  _buildBoostSection(context, isDark),
                  const SizedBox(height: 16),
                ],

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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        AppStrings.fiscalReceipts,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.qr_code_scanner, size: 16, color: AppColors.silpoOrange),
                        label: const Text('Скан чека', style: TextStyle(fontSize: 12, color: AppColors.silpoOrange)),
                        onPressed: () {
                          analyticsViewModel.importReceiptFromQr('silpo_qr_check_${DateTime.now().millisecondsSinceEpoch}');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Фіскальний чек успішно відскановано та додано до історії!'),
                              backgroundColor: AppColors.successGreen,
                            ),
                          );
                        },
                      ),
                    ],
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
    final isBright = boostViewModel?.isBrightnessMaximized ?? false;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isBright
              ? const [Color(0xFF1E3A8A), Color(0xFF2563EB)]
              : const [Color(0xFF2C3E50), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isBright ? Colors.blue.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.2),
            blurRadius: isBright ? 16 : 10,
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
              Row(
                children: [
                  if (boostViewModel != null)
                    IconButton(
                      icon: Icon(
                        isBright ? Icons.brightness_high : Icons.brightness_medium,
                        color: isBright ? AppColors.silpoYellow : Colors.white70,
                        size: 20,
                      ),
                      tooltip: 'Максимальна яскравість для каси',
                      onPressed: () {
                        boostViewModel!.toggleBrightness();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isBright
                                ? 'Яскравість повернено до звичайної'
                                : 'Яскравість екрана збільшено для швидкого сканування на касі!'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
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
            ],
          ),
          const SizedBox(height: 16),
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
                  if (boostViewModel != null && boostViewModel!.activeCouponsCount > 0) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.silpoYellow.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '⚡ ${boostViewModel!.activeCouponsCount} активних бустів',
                        style: const TextStyle(color: AppColors.silpoYellow, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
              // Simulated QR code
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.qr_code, size: 48, color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  const Text('4820-9912-38', style: TextStyle(color: Colors.white54, fontSize: 9, fontFamily: 'monospace')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBoostSection(BuildContext context, bool isDark) {
    return ListenableBuilder(
      listenable: boostViewModel!,
      builder: (context, _) {
        final coupons = boostViewModel!.coupons;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bolt, color: AppColors.silpoYellow, size: 20),
                    SizedBox(width: 6),
                    Text(
                      '«Сільпо Boost» (Балочковий акселератор)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                Text(
                  '${boostViewModel!.activeCouponsCount}/${coupons.length} активні',
                  style: const TextStyle(fontSize: 12, color: AppColors.silpoOrange, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: coupons.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final c = coupons[index];
                  return Container(
                    width: 210,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: c.isActivated ? AppColors.silpoOrange : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        width: c.isActivated ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: c.isActivated ? AppColors.silpoOrange : Colors.grey.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                c.badgeText,
                                style: TextStyle(
                                  color: c.isActivated ? Colors.white : Colors.grey,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(c.icon, size: 18, color: c.isActivated ? AppColors.silpoOrange : Colors.grey),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Text(
                            c.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 28,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: c.isActivated ? AppColors.successGreen : AppColors.silpoOrange,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => boostViewModel!.toggleCoupon(c.id),
                            child: Text(
                              c.isActivated ? '✓ Активовано' : 'Активувати буст',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
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
