import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../../core/constants/app_colors.dart';
import 'silpo_badge.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onAddToCart;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onAddToCart,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header badges & favorite
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.hasDiscount)
                    SilpoBadge(
                      text: '-${product.discountPercentage}%',
                      type: SilpoBadgeType.discount,
                    ),
                  if (product.isCinotyzhik) ...[
                    const SizedBox(width: 4),
                    const SilpoBadge(
                      text: 'Цінотижик',
                      type: SilpoBadgeType.cinotyzhik,
                    ),
                  ],
                  const Spacer(),
                  if (product.isPrivateLabel)
                    SilpoBadge(
                      text: product.brand ?? 'Власна марка',
                      type: SilpoBadgeType.privateLabel,
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Product Image Placeholder with stylish icon
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(product.category),
                    size: 44,
                    color: AppColors.silpoOrange.withValues(alpha: 0.8),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Title
              Text(
                product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),

              // Weight / Unit / Brand
              Text(
                '${product.weightGrams >= 1000 ? "${(product.weightGrams / 1000).toStringAsFixed(1)} кг" : "${product.weightGrams.toInt()} г"} • ${product.brand ?? product.category}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const Spacer(),

              // Price and Add Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.hasDiscount)
                        Text(
                          '${product.regularPrice.toStringAsFixed(2)} ₴',
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      Text(
                        '${product.currentPrice.toStringAsFixed(2)} ₴',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: product.hasDiscount ? AppColors.discountRed : AppColors.silpoOrange,
                        ),
                      ),
                    ],
                  ),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.silpoOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.add_shopping_cart, size: 20),
                    onPressed: onAddToCart,
                    tooltip: 'Додати в кошик',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('м’яс') || cat.contains('мяс')) return Icons.kebab_dining;
    if (cat.contains('риба')) return Icons.set_meal;
    if (cat.contains('овоч') || cat.contains('фрукт')) return Icons.eco;
    if (cat.contains('молоч') || cat.contains('сир')) return Icons.egg_alt;
    if (cat.contains('пекарн') || cat.contains('хліб')) return Icons.bakery_dining;
    if (cat.contains('кава') || cat.contains('чай')) return Icons.coffee;
    return Icons.shopping_basket;
  }
}
