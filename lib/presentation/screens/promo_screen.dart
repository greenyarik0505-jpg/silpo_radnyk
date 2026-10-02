import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../viewmodels/promo_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../widgets/promo_card.dart';
import '../widgets/product_details_sheet.dart';

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
                const SizedBox(height: 8),

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
                            'Цінотижики тижня',
                            style: TextStyle(fontSize: 12, color: AppColors.silpoOrange, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Promos List
                if (promoViewModel.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.silpoOrange),
                    ),
                  )
                else if (promoViewModel.promos.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.sentiment_dissatisfied,
                            size: 48,
                            color: isDark ? Colors.white38 : Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'У цій категорії зараз немає акційних товарів',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                    itemCount: promoViewModel.promos.length,
                    itemBuilder: (context, index) {
                      final promo = promoViewModel.promos[index];
                      final product = promo.effectiveProduct;
                      return PromoCard(
                        promo: promo,
                        onTap: () {
                          ProductDetailsSheet.show(context, product, cartViewModel);
                        },
                        onAddToCart: () {
                          cartViewModel.addProduct(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('«${product.title}» додано до списку покупок!'),
                              backgroundColor: AppColors.silpoOrange,
                              duration: const Duration(seconds: 2),
                              action: SnackBarAction(
                                label: 'Скасувати',
                                textColor: Colors.white,
                                onPressed: () {
                                  cartViewModel.removeItem(product.id);
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
