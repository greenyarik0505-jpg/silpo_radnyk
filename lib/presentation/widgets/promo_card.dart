import 'package:flutter/material.dart';
import '../../domain/entities/promo.dart';
import '../../core/constants/app_colors.dart';
import 'silpo_badge.dart';
import 'silpo_network_image.dart';

class PromoCard extends StatelessWidget {
  final PromoItem promo;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const PromoCard({
    super.key,
    required this.promo,
    this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: promo.type == PromoType.cinotyzhik
                    ? AppColors.silpoOrange
                    : AppColors.vlasnyiRakhunok,
                width: 6,
              ),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SilpoBadge(
                              text: '-${promo.discountPercent}%',
                              type: SilpoBadgeType.discount,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.timer_outlined, size: 13, color: AppColors.silpoOrange),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${promo.daysRemaining} дн.',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          promo.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          promo.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (promo.imageUrl != null && promo.imageUrl!.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    SilpoNetworkImage(
                      imageUrl: promo.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (promo.originalPrice != null)
                    Text(
                      '${promo.originalPrice!.toStringAsFixed(2)} ₴',
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  if (promo.originalPrice != null) const SizedBox(width: 8),
                  if (promo.promoPrice != null)
                    Text(
                      '${promo.promoPrice!.toStringAsFixed(2)} ₴',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.discountRed,
                      ),
                    ),
                  const Spacer(),
                  if (onAddToCart != null)
                    FilledButton.icon(
                      onPressed: onAddToCart,
                      icon: const Icon(Icons.add_shopping_cart, size: 16),
                      label: Text(
                        'Додати в кошик • ${promo.promoPrice?.toStringAsFixed(2) ?? ""} ₴',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        backgroundColor: AppColors.silpoOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              const Row(
                children: [
                  Icon(Icons.info_outline, size: 13, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    'Натисніть для перегляду складу та посилання на silpo.ua',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
