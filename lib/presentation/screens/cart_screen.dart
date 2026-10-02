import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../domain/entities/receipt.dart';
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
                icon: const Icon(Icons.receipt_long_outlined),
                tooltip: 'Історія фіскальних чеків',
                onPressed: () => _showOrderHistory(context, isDark),
              ),
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
                  onPressed: () => _showCheckoutBottomSheet(context, isDark),
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('Оформити замовлення'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.silpoOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  void _showCheckoutBottomSheet(BuildContext context, bool isDark) {
    String selectedDelivery = 'Самовивіз з супермаркету';
    String selectedPayment = 'SilpoPay • Власний Рахунок';
    double deliveryFee = 0.0;
    final store = cartViewModel.repository.activeStore;
    final storeAddress = store != null ? '${store.name}, ${store.address}' : 'Супермаркет Сільпо, Київ';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final totalWithDelivery = cartViewModel.totalPrice + deliveryFee;
          final bonusPointsEarned = (cartViewModel.totalPrice).round() * 3;

          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              top: 12,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.silpoOrange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.shopping_bag, color: AppColors.silpoOrange, size: 22),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Оформлення замовлення «Сільпо»',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Store selection info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.storefront, color: AppColors.silpoOrange, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Супермаркет виконання:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              Text(storeAddress, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Delivery method
                  const Text('Спосіб отримання:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('🛍️ Самовивіз (0 ₴)'),
                        selected: selectedDelivery == 'Самовивіз з супермаркету',
                        selectedColor: AppColors.silpoOrange,
                        labelStyle: TextStyle(
                          color: selectedDelivery == 'Самовивіз з супермаркету' ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setModalState(() {
                              selectedDelivery = 'Самовивіз з супермаркету';
                              deliveryFee = 0.0;
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('⚡ Експрес 45 хв (49 ₴)'),
                        selected: selectedDelivery == 'Експрес-доставка',
                        selectedColor: AppColors.silpoOrange,
                        labelStyle: TextStyle(
                          color: selectedDelivery == 'Експрес-доставка' ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setModalState(() {
                              selectedDelivery = 'Експрес-доставка';
                              deliveryFee = 49.0;
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('🕒 Доставка за розкладом'),
                        selected: selectedDelivery == 'Планова доставка',
                        selectedColor: AppColors.silpoOrange,
                        labelStyle: TextStyle(
                          color: selectedDelivery == 'Планова доставка' ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setModalState(() {
                              selectedDelivery = 'Планова доставка';
                              deliveryFee = cartViewModel.totalPrice >= 500 ? 0.0 : 39.0;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Payment method
                  const Text('Спосіб оплати:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('💳 SilpoPay (бонуси 3x)'),
                        selected: selectedPayment == 'SilpoPay • Власний Рахунок',
                        selectedColor: AppColors.silpoOrange,
                        labelStyle: TextStyle(
                          color: selectedPayment == 'SilpoPay • Власний Рахунок' ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (val) {
                          if (val) setModalState(() => selectedPayment = 'SilpoPay • Власний Рахунок');
                        },
                      ),
                      ChoiceChip(
                        label: const Text('📱 Apple / Google Pay'),
                        selected: selectedPayment == 'Apple Pay / Google Pay',
                        selectedColor: AppColors.silpoOrange,
                        labelStyle: TextStyle(
                          color: selectedPayment == 'Apple Pay / Google Pay' ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (val) {
                          if (val) setModalState(() => selectedPayment = 'Apple Pay / Google Pay');
                        },
                      ),
                      ChoiceChip(
                        label: const Text('💵 При отриманні'),
                        selected: selectedPayment == 'Оплата при отриманні',
                        selectedColor: AppColors.silpoOrange,
                        labelStyle: TextStyle(
                          color: selectedPayment == 'Оплата при отриманні' ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (val) {
                          if (val) setModalState(() => selectedPayment = 'Оплата при отриманні');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Order summary
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBackground : const Color(0xFFFFF9F5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.silpoOrange.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Товари (${cartViewModel.itemCount} шт):', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                            Text('${cartViewModel.totalPrice.toStringAsFixed(2)} ₴', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        if (cartViewModel.totalSavings > 0) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Економія за акціями «Сільпо»:', style: TextStyle(fontSize: 13, color: AppColors.discountRed, fontWeight: FontWeight.w600)),
                              Text('-${cartViewModel.totalSavings.toStringAsFixed(2)} ₴', style: const TextStyle(fontSize: 13, color: AppColors.discountRed, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                        if (deliveryFee > 0) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Вартість доставки:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                              Text('${deliveryFee.toStringAsFixed(2)} ₴', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('До сплати:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('${totalWithDelivery.toStringAsFixed(2)} ₴', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.silpoOrange)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.stars, size: 14, color: AppColors.silpoYellow),
                            const SizedBox(width: 4),
                            Text('+$bonusPointsEarned бонусів на «Власний Рахунок»', style: const TextStyle(fontSize: 12, color: AppColors.silpoOrange, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.silpoOrange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.check_circle, size: 20),
                      label: Text(
                        'Підтвердити замовлення • ${totalWithDelivery.toStringAsFixed(2)} ₴',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        final receipt = cartViewModel.placeOrder(
                          storeAddress: storeAddress,
                          deliveryType: selectedDelivery,
                          paymentMethod: selectedPayment,
                          deliveryFee: deliveryFee,
                        );
                        Navigator.pop(ctx);
                        _showReceiptDialog(context, receipt, isDark);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showReceiptDialog(BuildContext context, FiscalReceipt receipt, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check_circle, color: AppColors.successGreen, size: 24),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Замовлення оформлено!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 380,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 6),
                Text(
                  'Дякуємо за покупку в «Сільпо»! Фіскальний чек збережено у додатку.',
                  style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
                const SizedBox(height: 14),

                // Simulated Fiscal Receipt Paper Container
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? Colors.white12 : Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          '«СІЛЬПО-ФУД» • ФІСКАЛЬНИЙ ЧЕК',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('Номер чека: ${receipt.id}', style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
                      Text(receipt.fiscalNumber, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.grey)),
                      Text('Супермаркет: ${receipt.storeAddress}', style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
                      Text('Час: ${receipt.dateTime.day}.${receipt.dateTime.month}.${receipt.dateTime.year} ${receipt.dateTime.hour.toString().padLeft(2, '0')}:${receipt.dateTime.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
                      const Divider(height: 14),

                      // Items list preview
                      ...receipt.items.take(4).map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.name} (${item.quantity.toInt()} ${item.unit})',
                                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${item.total.toStringAsFixed(2)} ₴',
                                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )),
                      if (receipt.items.length > 4)
                        Text(
                          '...та ще ${receipt.items.length - 4} товарів',
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.grey),
                        ),
                      const Divider(height: 14),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('РАЗОМ:', style: TextStyle(fontFamily: 'monospace', fontSize: 14, fontWeight: FontWeight.bold)),
                          Text('${receipt.totalAmount.toStringAsFixed(2)} ₴', style: const TextStyle(fontFamily: 'monospace', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.silpoOrange)),
                        ],
                      ),
                      if (receipt.discountAmount > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Знижка «Сільпо»:', style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.discountRed)),
                            Text('-${receipt.discountAmount.toStringAsFixed(2)} ₴', style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.discountRed, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Нараховано балів:', style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.silpoOrange)),
                          Text('+${receipt.bonusPointsEarned}', style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.silpoOrange, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Barcode simulation box
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.qr_code_2, size: 54, color: Colors.black),
                              const SizedBox(height: 2),
                              Text(receipt.id, style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.black)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.silpoOrange),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Зрозуміло'),
          ),
        ],
      ),
    );
  }

  void _showOrderHistory(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          top: 12,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.receipt_long, color: AppColors.silpoOrange, size: 24),
                SizedBox(width: 10),
                Text(
                  'Історія фіскальних чеків «Сільпо»',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (cartViewModel.orderHistory.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 36),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_outlined, size: 56, color: isDark ? Colors.white24 : Colors.grey[400]),
                      const SizedBox(height: 12),
                      const Text(
                        'У вас поки що немає оформлених замовлень',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Оформіть замовлення або зробіть скан у Вільнокасі, щоб побачити фіскальні чеки тут.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                    ],
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: cartViewModel.orderHistory.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, index) {
                    final order = cartViewModel.orderHistory[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showReceiptDialog(context, order, isDark),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? Colors.white12 : Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.silpoOrange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.check, color: AppColors.silpoOrange, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.id,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Text(
                                    '${order.dateTime.day}.${order.dateTime.month}.${order.dateTime.year} • ${order.paymentMethod}',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${order.totalAmount.toStringAsFixed(2)} ₴',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.silpoOrange),
                                ),
                                Text(
                                  '+${order.bonusPointsEarned} балів',
                                  style: const TextStyle(fontSize: 11, color: AppColors.successGreen, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
