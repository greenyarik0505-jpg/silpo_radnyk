import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/product.dart';
import '../../core/constants/app_colors.dart';
import '../viewmodels/cart_viewmodel.dart';
import 'silpo_badge.dart';
import 'silpo_network_image.dart';

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
            const SizedBox(height: 8),

            // Hero Product Image
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.grey[200]!,
                  ),
                ),
                child: Center(
                  child: SilpoNetworkImage(
                    imageUrl: product.imageUrl,
                    height: 160,
                    width: 260,
                    fit: BoxFit.contain,
                    fallbackIcon: Icons.shopping_basket_outlined,
                  ),
                ),
              ),
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

            // Price Row with prominent "Додати в кошик" button
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : const Color(0xFFFFF9F5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.silpoOrange.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ціна товару:',
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
                          content: Text('«${product.title}» (${product.currentPrice.toStringAsFixed(2)} ₴) додано до кошика!'),
                          backgroundColor: AppColors.silpoOrange,
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart, size: 18),
                    label: Text(
                      'Додати в кошик • ${product.currentPrice.toStringAsFixed(2)} ₴',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.silpoOrange,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

            // Section 2: Продукти, з яких готується страва (з ціною, кнопкою додавання в кошик та посиланням на Сільпо)
            if (product.recipeIngredients.isNotEmpty) ...[
              const Row(
                children: [
                  Icon(Icons.restaurant_menu, size: 18, color: AppColors.silpoOrange),
                  SizedBox(width: 6),
                  Text(
                    'Інгредієнти страви (ціна та додавання в кошик):',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
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
            const SizedBox(height: 16),

            // Big Full-Width "Додати до кошика" Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: () {
                  cartViewModel.addProduct(product);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('«${product.title}» (${product.currentPrice.toStringAsFixed(2)} ₴) додано до кошика!'),
                      backgroundColor: AppColors.silpoOrange,
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart),
                label: Text(
                  'Додати в кошик • ${product.currentPrice.toStringAsFixed(2)} ₴',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.silpoOrange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientRow(BuildContext context, ProductIngredientItem item, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline, size: 18, color: AppColors.silpoOrange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.silpoOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${item.estimatedPrice.toStringAsFixed(2)} ₴',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.silpoOrange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(
              'Кількість: ${item.amount} • Бренд: ${item.brand ?? "Сільпо"}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.open_in_new, size: 14),
                label: const Text('На silpo.ua', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: item.silpoUrl));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Посилання на «${item.name}» у Сільпо скопійовано!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const Spacer(),
              FilledButton.icon(
                icon: const Icon(Icons.add_shopping_cart, size: 15),
                label: Text(
                  'Додати в кошик • ${item.estimatedPrice.toStringAsFixed(2)} ₴',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.silpoOrange,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
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
                      content: Text('«${item.name}» (${item.estimatedPrice.toStringAsFixed(2)} ₴) додано до кошика!'),
                      backgroundColor: AppColors.silpoOrange,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
