import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../widgets/cart_item_tile.dart';
import 'vilnokasa_screen.dart';

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
              IconButton(
                icon: const Icon(Icons.qr_code_scanner, color: AppColors.silpoOrange),
                tooltip: 'Вільнокаса (скан у магазині)',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VilnokasaScreen(cartViewModel: cartViewModel),
                    ),
                  );
                },
              ),
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

                    // Bottom Summary Panel
                    _buildSummaryPanel(context, isDark),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildSummaryPanel(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, -3),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (cartViewModel.totalSavings > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Економія за акціями:',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.discountRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '-${cartViewModel.totalSavings.toStringAsFixed(2)} ₴',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.discountRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.totalSum,
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    Text(
                      '${cartViewModel.totalPrice.toStringAsFixed(2)} ₴',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.silpoOrange,
                      ),
                    ),
                  ],
                ),
                FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Список покупок готовий!'),
                        backgroundColor: AppColors.silpoOrange,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Готово до покупок'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.silpoOrange,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
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
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: isDark ? Colors.white24 : Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'Список покупок порожній',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Запитайте в AI-Шефа ідею для страви або виберіть товари у розділі Акцій',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onNavigateToAi,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Скласти меню з AI-Шефом'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.silpoOrange,
                foregroundColor: Colors.white,
              ),
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
        content: const Text('Всі товари будуть видалені зі списку покупок.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Скасувати'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              cartViewModel.clearCart();
              Navigator.pop(ctx);
            },
            child: const Text('Очистити'),
          ),
        ],
      ),
    );
  }
}
