import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../viewmodels/promo_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/store_viewmodel.dart';
import '../widgets/promo_card.dart';
import '../widgets/product_details_sheet.dart';

class PromoScreen extends StatelessWidget {
  final PromoViewModel promoViewModel;
  final CartViewModel cartViewModel;
  final StoreViewModel? storeViewModel;
  final VoidCallback? onSelectStore;

  const PromoScreen({
    super.key,
    required this.promoViewModel,
    required this.cartViewModel,
    this.storeViewModel,
    this.onSelectStore,
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
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),

                      // Active store banner
                      if (storeViewModel != null && storeViewModel!.selectedStore != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: onSelectStore,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurface : AppColors.silpoNavy,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark ? Colors.black26 : AppColors.silpoNavy.withValues(alpha: 0.16),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.silpoOrange,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.location_on, size: 16, color: Colors.white),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'АКЦІЇ ТА ЦІНИ ДЛЯ:',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.silpoYellow,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        Text(
                                          storeViewModel!.selectedStore!.name,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Змінити',
                                          style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 2),
                                        Icon(Icons.keyboard_arrow_right, size: 14, color: Colors.white),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 6),

                      // Category filter chips
                      SizedBox(
                        height: 42,
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

                      const SizedBox(height: 10),

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
                                  'Цінотижики Сільпо',
                                  style: TextStyle(fontSize: 12, color: AppColors.silpoOrange, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (promoViewModel.isLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.silpoOrange),
                    ),
                  )
                else if (promoViewModel.promos.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 6, bottom: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
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
                        childCount: promoViewModel.promos.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
