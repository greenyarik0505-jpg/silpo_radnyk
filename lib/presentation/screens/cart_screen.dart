import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../domain/entities/delivery_slot.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../widgets/cart_item_tile.dart';

class CartScreen extends StatelessWidget {
  final CartViewModel cartViewModel;
  final VoidCallback onNavigateToAi;

  const CartScreen({
    super.key,
    required this.cartViewModel,
    required this.onNavigateToAi,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: cartViewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text('${AppStrings.cartTitle} (${cartViewModel.itemCount})'),
            actions: [
              if (!cartViewModel.isEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined),
                  tooltip: 'Очистити весь кошик',
                  onPressed: () {
                    _showClearConfirmation(context);
                  },
                ),
            ],
          ),
          body: cartViewModel.isEmpty
              ? _buildEmptyState(context, isDark)
              : Column(
                  children: [
                    // Delivery slot selector pill list
                    _buildDeliverySlotsSelector(context, isDark),

                    const Divider(height: 1),

                    // Items list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: cartViewModel.items.length,
                        itemBuilder: (context, index) {
                          final item = cartViewModel.items[index];
                          return CartItemTile(
                            cartItem: item,
                            onQuantityChanged: (qty) => cartViewModel.updateQuantity(item.product.id, qty),
                            onRemove: () => cartViewModel.removeItem(item.product.id),
                            onToggleAutoReplenish: () => cartViewModel.toggleAutoReplenish(item.product.id),
                          );
                        },
                      ),
                    ),

                    // Checkout Bottom Summary Panel
                    _buildSummaryPanel(context, isDark),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildDeliverySlotsSelector(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: isDark ? AppColors.darkSurface : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Icon(Icons.delivery_dining, size: 18, color: AppColors.silpoOrange),
                SizedBox(width: 6),
                Text(
                  AppStrings.deliverySlotsTitle,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: cartViewModel.availableSlots.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final slot = cartViewModel.availableSlots[index];
                final isSelected = cartViewModel.selectedSlot?.id == slot.id;
                return ChoiceChip(
                  label: Text('${_slotTitle(slot)} (${slot.timeRange})'),
                  selected: isSelected,
                  selectedColor: AppColors.silpoOrange,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) cartViewModel.selectDeliverySlot(slot);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _slotTitle(DeliverySlot slot) {
    return switch (slot.type) {
      DeliveryType.express => '⚡ Експрес',
      DeliveryType.scheduled => '🕒 Планова',
      DeliveryType.selfPickup => '🏪 Самовивіз',
    };
  }

  Widget _buildSummaryPanel(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (cartViewModel.totalSavings > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      AppStrings.discountSavings,
                      style: TextStyle(color: AppColors.discountRed, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '-${cartViewModel.totalSavings.toStringAsFixed(2)} ₴',
                      style: const TextStyle(color: AppColors.discountRed, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppStrings.loyaltyPointsEarned,
                  style: TextStyle(color: AppColors.vlasnyiRakhunok, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text(
                  '+${cartViewModel.totalBonusPoints} балів',
                  style: const TextStyle(color: AppColors.vlasnyiRakhunok, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppStrings.totalSum,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${cartViewModel.finalTotal.toStringAsFixed(2)} ₴',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.silpoOrange),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.silpoOrange,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  _showOrderSuccessDialog(context);
                },
                child: const Text(
                  AppStrings.checkoutButton,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.silpoOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.silpoOrange),
            ),
            const SizedBox(height: 20),
            const Text(
              AppStrings.cartEmpty,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.cartEmptyPrompt,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Спитати поради в AI Шефа'),
              onPressed: onNavigateToAi,
            ),
          ],
        ),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Очистити кошик?'),
        content: const Text('Всі додані товари та налаштування регулярної доставки буде видалено.'),
        actions: [
          TextButton(
            child: const Text('Скасувати'),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: const Text('Очистити', style: TextStyle(color: Colors.red)),
            onPressed: () {
              cartViewModel.clearCart();
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _showOrderSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: AppColors.successGreen, size: 54),
        title: const Text('Замовлення прийнято!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Сума: ${cartViewModel.finalTotal.toStringAsFixed(2)} ₴'),
            Text('Слот доставки: ${cartViewModel.selectedSlot?.timeRange ?? "Експрес"}'),
            Text('Нараховано: +${cartViewModel.totalBonusPoints} балів «Власний Рахунок»'),
            const SizedBox(height: 12),
            const Text('Сільпо AI Assistant передав замовлення на збірку у найближчий супермаркет.'),
          ],
        ),
        actions: [
          ElevatedButton(
            child: const Text('Чудово'),
            onPressed: () {
              cartViewModel.clearCart();
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}
