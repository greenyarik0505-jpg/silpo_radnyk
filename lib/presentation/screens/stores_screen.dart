import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../viewmodels/store_viewmodel.dart';
import 'mcp_console_screen.dart';
import '../viewmodels/mcp_viewmodel.dart';

class StoresScreen extends StatelessWidget {
  final StoreViewModel storeViewModel;
  final McpViewModel mcpViewModel;

  const StoresScreen({
    super.key,
    required this.storeViewModel,
    required this.mcpViewModel,
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
              IconButton(
                icon: const Icon(Icons.terminal, color: AppColors.silpoOrange),
                tooltip: 'Silpo MCP Console',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => McpConsoleScreen(mcpViewModel: mcpViewModel),
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
                    hintText: 'Пошук магазину, адреси або теми...',
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
                height: 42,
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
                        if (selected) storeViewModel.filterCity(city);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Stores list
              Expanded(
                child: storeViewModel.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.silpoOrange))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: storeViewModel.stores.length,
                        itemBuilder: (context, index) {
                          final store = storeViewModel.stores[index];
                          final isSelected = storeViewModel.selectedStore?.filialId == store.filialId;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isSelected ? AppColors.silpoOrange : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppColors.silpoOrange.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
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
                                          store.isFavorite ? Icons.favorite : Icons.favorite_border,
                                          color: store.isFavorite ? Colors.red : Colors.grey,
                                        ),
                                        onPressed: () => storeViewModel.toggleFavorite(store.filialId),
                                      ),
                                    ],
                                  ),

                                  if (store.conceptTheme != null) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.silpoYellowLight,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.palette_outlined, size: 14, color: Color(0xFFB45309)),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Концепт: ${store.conceptTheme}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFB45309),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        store.workingHours,
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                      const SizedBox(width: 14),
                                      if (store.hasGenerator) ...[
                                        const Icon(Icons.bolt, size: 14, color: AppColors.successGreen),
                                        const SizedBox(width: 4),
                                        const Text(
                                          'Працює з генератором',
                                          style: TextStyle(fontSize: 12, color: AppColors.successGreen, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ],
                                  ),

                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: store.amenities.map((amenity) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isDark ? AppColors.darkSurface : AppColors.lightBackground,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          amenity,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      );
                                    }).toList(),
                                  ),

                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: isSelected ? AppColors.silpoOrange : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                        ),
                                        foregroundColor: isSelected ? AppColors.silpoOrange : null,
                                      ),
                                      onPressed: () {
                                        storeViewModel.selectStore(store);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Магазин "${store.name}" обрано для замовлень'),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      child: Text(isSelected ? '✓ Обраний супермаркет' : 'Обрати цей магазин'),
                                    ),
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
