import 'package:flutter/material.dart';
import '../../domain/entities/cart_item.dart';
import '../../core/constants/app_colors.dart';
import 'silpo_badge.dart';

class CartItemTile extends StatelessWidget {
  final CartItem cartItem;
  final ValueChanged<double> onQuantityChanged;
  final VoidCallback onRemove;
  final VoidCallback onToggleAutoReplenish;

  const CartItemTile({
    super.key,
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
    required this.onToggleAutoReplenish,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final product = cartItem.activeProduct;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.fastfood, color: AppColors.silpoOrange, size: 28),
                  ),
                ),
                const SizedBox(width: 12),

                // Title and Unit Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${product.currentPrice.toStringAsFixed(2)} ₴ / ${product.unit}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      if (cartItem.totalSavings > 0) ...[
                        const SizedBox(height: 4),
                        SilpoBadge(
                          text: 'Економія: ${cartItem.totalSavings.toStringAsFixed(2)} ₴',
                          type: SilpoBadgeType.discount,
                        ),
                      ],
                    ],
                  ),
                ),

                // Delete Button
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                  onPressed: onRemove,
                  tooltip: 'Видалити',
                ),
              ],
            ),
            const Divider(height: 20),

            // Stepper and Auto-Replenish Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Auto replenish pill
                InkWell(
                  onTap: onToggleAutoReplenish,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: cartItem.isAutoReplenish
                          ? AppColors.vlasnyiRakhunokLight
                          : (isDark ? AppColors.darkBackground : AppColors.lightBackground),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: cartItem.isAutoReplenish
                            ? AppColors.vlasnyiRakhunok
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.repeat,
                          size: 14,
                          color: cartItem.isAutoReplenish
                              ? AppColors.vlasnyiRakhunok
                              : (isDark ? Colors.white70 : Colors.black54),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          cartItem.isAutoReplenish ? 'Щотижня' : 'Автодоставка',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: cartItem.isAutoReplenish
                                ? AppColors.vlasnyiRakhunok
                                : (isDark ? Colors.white70 : Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Stepper + Total Price
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              if (cartItem.quantity > 1) {
                                onQuantityChanged(cartItem.quantity - 1);
                              } else {
                                onRemove();
                              }
                            },
                          ),
                          Text(
                            cartItem.quantity.toInt().toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            visualDensity: VisualDensity.compact,
                            onPressed: () => onQuantityChanged(cartItem.quantity + 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${cartItem.totalPrice.toStringAsFixed(2)} ₴',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.silpoOrange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
