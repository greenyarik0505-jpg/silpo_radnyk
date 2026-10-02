import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../../core/constants/app_colors.dart';
import 'silpo_badge.dart';
import 'silpo_network_image.dart';

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
      elevation: isDark ? 0 : 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.grey[200]!,
          width: 1,
        ),
      ),
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
                  if (product.rating != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          product.rating!.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  if (product.isPrivateLabel) ...[
                    const SizedBox(width: 4),
                    SilpoBadge(
                      text: product.brand ?? 'Власна марка',
                      type: SilpoBadgeType.privateLabel,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),

              // Product Image with Real Photo from Silpo CDN
              SilpoNetworkImage(
                imageUrl: product.imageUrl,
                height: 110,
                width: double.infinity,
                fit: BoxFit.contain,
                fallbackIcon: _getCategoryIcon(product.category),
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

              // Price and Prominent Add to Cart Button
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
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      Text(
                        '${product.currentPrice.toStringAsFixed(2)} ₴',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: product.hasDiscount ? AppColors.discountRed : AppColors.silpoOrange,
                        ),
                      ),
                    ],
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.silpoOrange,
                      foregroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.add_shopping_cart, size: 15),
                    label: const Text(
                      '+ Кошик',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    onPressed: onAddToCart,
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
    if (cat.contains('сир') || cat.contains('молок')) return Icons.local_drink;
    if (cat.contains('пекар') || cat.contains('хліб')) return Icons.bakery_dining;
    if (cat.contains('кава') || cat.contains('чай')) return Icons.coffee;
    return Icons.shopping_basket;
  }
}
