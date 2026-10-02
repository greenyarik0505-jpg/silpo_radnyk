import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../viewmodels/promo_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../widgets/promo_card.dart';

class PromoScreen extends StatelessWidget {
  final PromoViewModel promoViewModel;
  final CartViewModel cartViewModel;

  const PromoScreen({
    super.key,
    required this.promoViewModel,
    required this.cartViewModel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: promoViewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.promoHubTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Оновити акції',
                onPressed: promoViewModel.loadPromos,
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: promoViewModel.loadPromos,
            color: AppColors.silpoOrange,
            child: ListView(
              children: [
                // Top Wheel of Fortune Interactive Banner
                _buildWheelOfFortuneCard(context, isDark),

                const SizedBox(height: 12),

                // Category filter chips
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: promoViewModel.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = promoViewModel.categories[index];
                      final isSelected = promoViewModel.selectedCategory == cat ||
                          (promoViewModel.selectedCategory == null && cat == 'Всі');
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: AppColors.silpoOrange,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            promoViewModel.selectCategory(cat);
                          }
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Header for Promos
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Знайдено: ${promoViewModel.promos.length} пропозицій',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const Row(
                        children: [
                          Icon(Icons.bolt, size: 14, color: AppColors.silpoOrange),
                          SizedBox(width: 4),
                          Text(
                            'Ціни оновлено сьогодні',
                            style: TextStyle(fontSize: 12, color: AppColors.silpoOrange, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // List of Promos
                if (promoViewModel.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator(color: AppColors.silpoOrange)),
                  )
                else
                  ...promoViewModel.promos.map((promo) {
                    return PromoCard(
                      promo: promo,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Обрано: ${promo.title}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
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

  Widget _buildWheelOfFortuneCard(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C5CE7), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.casino, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.wheelOfFortune,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Крутіть щодня та вигравайте бонуси й персональні знижки!',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (promoViewModel.hasSpunWheel) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: AppColors.silpoYellow, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ваш щоденний виграш:',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        Text(
                          promoViewModel.wheelPrize ?? 'Приз активовано',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.silpoYellow,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: promoViewModel.isSpinning
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87),
                      )
                    : const Icon(Icons.rotate_right),
                label: Text(
                  promoViewModel.isSpinning ? 'Колесо обертається...' : 'Крутити Колесо Фортуни',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: promoViewModel.isSpinning ? null : promoViewModel.spinWheel,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
