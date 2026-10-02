import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../viewmodels/store_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import 'vilnokasa_screen.dart';
import '../viewmodels/mcp_viewmodel.dart';

class StoresScreen extends StatelessWidget {
  final StoreViewModel storeViewModel;
  final McpViewModel mcpViewModel;
  final CartViewModel? cartViewModel;

  const StoresScreen({
    super.key,
    required this.storeViewModel,
    required this.mcpViewModel,
    this.cartViewModel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: storeViewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.storesTitle),
            actions: [
              if (cartViewModel != null)
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner, color: AppColors.silpoOrange),
                  tooltip: 'Вільнокаса (скан у магазині)',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VilnokasaScreen(cartViewModel: cartViewModel!),
                      ),
                    );
                  },
                ),
            ],
          ),
          body: Column(
            children: [
              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Пошук супермаркету Сільпо, адреси...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => storeViewModel.search(''),
                    ),
                  ),
                  onChanged: storeViewModel.search,
                ),
              ),

              // City filter chips
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: storeViewModel.cities.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final city = storeViewModel.cities[index];
                    final isSelected = storeViewModel.selectedCity == city ||
                        (storeViewModel.selectedCity == null && city == 'Всі міста');
                    return ChoiceChip(
                      label: Text(city),
                      selected: isSelected,
                      selectedColor: AppColors.silpoOrange,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          storeViewModel.filterCity(city == 'Всі міста' ? null : city);
                        }
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Service & Generator Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        avatar: const Text('⚡', style: TextStyle(fontSize: 13)),
                        label: const Text('З генератором'),
                        selected: storeViewModel.onlyWithGenerator,
                        selectedColor: AppColors.silpoOrange.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.silpoOrange,
                        onSelected: (_) => storeViewModel.toggleGeneratorFilter(),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        avatar: const Text('🥐', style: TextStyle(fontSize: 13)),
                        label: const Text('Власна пекарня'),
                        selected: storeViewModel.onlyWithBakery,
                        selectedColor: AppColors.silpoOrange.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.silpoOrange,
                        onSelected: (_) => storeViewModel.toggleBakeryFilter(),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        avatar: const Text('☕', style: TextStyle(fontSize: 13)),
                        label: const Text('Кав’ярня Feeltrd'),
                        selected: storeViewModel.onlyWithFeeltrd,
                        selectedColor: AppColors.silpoOrange.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.silpoOrange,
                        onSelected: (_) => storeViewModel.toggleFeeltrdFilter(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Store count indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Знайдено: ${storeViewModel.stores.length} супермаркетів Сільпо',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (storeViewModel.selectedStore != null)
                      Text(
                        'Обрано: ${storeViewModel.selectedStore!.name}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.silpoOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),

              // Store List
              Expanded(
                child: storeViewModel.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.silpoOrange))
                    : storeViewModel.stores.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.storefront_outlined, size: 54, color: isDark ? Colors.white24 : Colors.grey[400]),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Супермаркетів Сільпо за цими фільтрами не знайдено',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: storeViewModel.stores.length,
                            itemBuilder: (context, index) {
                              final store = storeViewModel.stores[index];
                              final isCurrent = storeViewModel.selectedStore?.filialId == store.filialId;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: isCurrent ? 2 : 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: isCurrent ? AppColors.silpoOrange : (isDark ? Colors.white12 : Colors.grey[200]!),
                                    width: isCurrent ? 2 : 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppColors.silpoOrange.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Icon(Icons.storefront, color: AppColors.silpoOrange, size: 24),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  store.name,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${store.city}, ${store.address}',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              store.isFavorite ? Icons.star : Icons.star_border,
                                              color: store.isFavorite ? Colors.amber : Colors.grey,
                                            ),
                                            onPressed: () => storeViewModel.toggleFavorite(store.filialId),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),

                                      // Amenities Chips
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          if (store.hasGenerator)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text('⚡', style: TextStyle(fontSize: 11)),
                                                  SizedBox(width: 3),
                                                  Text(
                                                    'Працює з генератором',
                                                    style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          if (store.conceptTheme != null)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: Colors.purple.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'Тема: ${store.conceptTheme}',
                                                style: const TextStyle(fontSize: 11, color: Colors.purple, fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                          ...store.amenities.map(
                                            (a) => Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: isDark ? Colors.white10 : Colors.grey[100],
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                a,
                                                style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.schedule, size: 14, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Text(
                                                store.workingHours,
                                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                          FilledButton.tonal(
                                            onPressed: isCurrent
                                                ? null
                                                : () {
                                                    storeViewModel.selectStore(store);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('Магазин «${store.name}» обрано для замовлень!'),
                                                        backgroundColor: AppColors.silpoOrange,
                                                        duration: const Duration(seconds: 1),
                                                      ),
                                                    );
                                                  },
                                            style: FilledButton.styleFrom(
                                              visualDensity: VisualDensity.compact,
                                              backgroundColor: isCurrent ? Colors.transparent : AppColors.silpoOrange.withValues(alpha: 0.15),
                                              foregroundColor: AppColors.silpoOrange,
                                            ),
                                            child: Text(isCurrent ? '✓ Мій супермаркет' : 'Обрати магазин'),
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
        );
      },
    );
  }
}
