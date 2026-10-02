import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/product.dart';
import '../../core/constants/app_colors.dart';
import '../viewmodels/cart_viewmodel.dart';
import 'silpo_badge.dart';

class ProductDetailsSheet extends StatelessWidget {
  final Product product;
  final CartViewModel cartViewModel;

  const ProductDetailsSheet({
    super.key,
    required this.product,
    required this.cartViewModel,
  });

  static void show(BuildContext context, Product product, CartViewModel cartViewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductDetailsSheet(
        product: product,
        cartViewModel: cartViewModel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final silpoUrl = product.silpoUrl ?? 'https://shop.silpo.ua/product/${product.id}';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category & Badges
            Row(
              children: [
                if (product.hasDiscount)
                  SilpoBadge(
                    text: '-${product.discountPercentage}%',
                    type: SilpoBadgeType.discount,
                  ),
                if (product.isCinotyzhik) ...[
                  const SizedBox(width: 6),
                  const SilpoBadge(
                    text: 'Цінотижик',
                    type: SilpoBadgeType.cinotyzhik,
                  ),
                ],
                if (product.isPrivateLabel) ...[
                  const SizedBox(width: 6),
                  SilpoBadge(
                    text: product.brand ?? 'Власна марка Сільпо',
                    type: SilpoBadgeType.privateLabel,
                  ),
                ],
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Title
            Text(
              product.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),

            // Brand & Category
            Text(
              '${product.category} • ${product.brand ?? "Сільпо"} • ${product.weightGrams >= 1000 ? "${(product.weightGrams / 1000).toStringAsFixed(1)} кг" : "${product.weightGrams.toInt()} г"}',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Price Row
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : const Color(0xFFFFF9F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.silpoOrange.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ціна в Сільпо:',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Row(
                        children: [
                          Text(
                            '${product.currentPrice.toStringAsFixed(2)} ₴',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.silpoOrange,
                            ),
                          ),
                          if (product.hasDiscount) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${product.regularPrice.toStringAsFixed(2)} ₴',
                              style: const TextStyle(
                                fontSize: 14,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () {
                      cartViewModel.addProduct(product);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('«${product.title}» додано до списку покупок!'),
                          backgroundColor: AppColors.silpoOrange,
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart, size: 18),
                    label: const Text('У список'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.silpoOrange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 1: Склад продукту (Інгредієнти)
            const Text(
              '📋 Склад та інгредієнти:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                product.composition ??
                    'Склад: добірні свіжі інгредієнти з контролем якості «Сільпо». Без штучних барвників та ГМО.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Section 2: Продукти, з яких готується страва (з посиланнями на Сільпо)
            if (product.recipeIngredients.isNotEmpty) ...[
              const Text(
                '🥗 З чого приготувати (товари в Сільпо):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...product.recipeIngredients.map((item) => _buildIngredientRow(context, item, isDark)),
              const SizedBox(height: 16),
            ],

            // Section 3: Пряме посилання на товар у Сільпо
            const Text(
              '🔗 Пряме посилання на товар у Сільпо:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link, size: 20, color: AppColors.silpoOrange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      silpoUrl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blueAccent,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: 'Скопіювати посилання',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: silpoUrl));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Посилання на товар скопійовано!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientRow(BuildContext context, ProductIngredientItem item, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 18, color: AppColors.silpoOrange),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text(
                  '${item.amount} • ${item.brand ?? "Сільпо"} • ~${item.estimatedPrice.toStringAsFixed(1)} ₴',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new, size: 18, color: AppColors.silpoOrange),
            tooltip: 'Відкрити посилання на silpo.ua',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: item.silpoUrl));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Посилання на «${item.name}» у Сільпо скопійовано: ${item.silpoUrl}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_shopping_cart, size: 18),
            tooltip: 'Додати цей інгредієнт',
            onPressed: () {
              final ingredientProduct = Product(
                id: 'ing_${item.name.hashCode}',
                title: '${item.name} (${item.brand ?? "Сільпо"})',
                category: 'Інгредієнти',
                regularPrice: item.estimatedPrice,
                silpoUrl: item.silpoUrl,
              );
              cartViewModel.addProduct(ingredientProduct);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('«${item.name}» додано до списку покупок!'),
                  backgroundColor: AppColors.silpoOrange,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
