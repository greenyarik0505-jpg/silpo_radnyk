import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../domain/entities/store.dart';
import '../viewmodels/store_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import 'vilnokasa_screen.dart';
import '../viewmodels/mcp_viewmodel.dart';
import '../widgets/silpo_feature_chip.dart';
import '../widgets/silpo_network_image.dart';

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

  void _showStoreDetailsSheet(BuildContext context, SilpoStore store) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCurrent = storeViewModel.selectedStore?.filialId == store.filialId;

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
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Store Banner
              Stack(
                children: [
                  SilpoNetworkImage(
                    imageUrl: store.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.zero,
                    fallbackIcon: Icons.storefront,
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.1),
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (store.conceptTheme != null)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.silpoYellow.withValues(alpha: 0.6)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.palette, color: AppColors.silpoYellow, size: 14),
                            const SizedBox(width: 5),
                            Text(
                              store.conceptTheme!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 12,
                    left: 16,
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: store.isOpen ? AppColors.successGreen : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          store.isOpen ? 'Відчинено зараз' : 'Зачинено',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: AppColors.silpoOrange),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${store.city}, ${store.address}',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          'Графік роботи: ${store.workingHours}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        Text(
                          '${store.distanceKm.toStringAsFixed(1)} км від вас',
                          style: const TextStyle(fontSize: 12, color: AppColors.silpoOrange, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const Divider(height: 28),

                    const Text(
                      'Послуги та сервіси супермаркету:',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    // Feature badges matching screenshot
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: store.amenities.map((amenity) {
                        String emoji = '✓';
                        String label = amenity;
                        if (amenity.contains('⚡')) {
                          emoji = '⚡';
                          label = amenity.replaceAll('⚡', '').trim();
                        } else if (amenity.contains('🥐')) {
                          emoji = '🥐';
                          label = amenity.replaceAll('🥐', '').trim();
                        } else if (amenity.contains('☕')) {
                          emoji = '☕';
                          label = amenity.replaceAll('☕', '').trim();
                        } else if (amenity.contains('🔌')) {
                          emoji = '🔌';
                          label = amenity.replaceAll('🔌', '').trim();
                        } else if (amenity.contains('💊')) {
                          emoji = '💊';
                          label = amenity.replaceAll('💊', '').trim();
                        } else if (amenity.contains('🍣')) {
                          emoji = '🍣';
                          label = amenity.replaceAll('🍣', '').trim();
                        } else if (amenity.contains('🍕')) {
                          emoji = '🍕';
                          label = amenity.replaceAll('🍕', '').trim();
                        } else if (amenity.contains('🧀')) {
                          emoji = '🧀';
                          label = amenity.replaceAll('🧀', '').trim();
                        }
                        return SilpoFeatureChip(
                          emoji: emoji,
                          label: label,
                          isCompact: true,
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Information rows
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.grey[200]!,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined, size: 16, color: AppColors.silpoOrange),
                              const SizedBox(width: 8),
                              const Text('Гаряча лінія Сільпо:', style: TextStyle(fontSize: 13)),
                              const Spacer(),
                              Text(
                                store.phone ?? '0 800 301 707',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.silpoOrange),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.bolt, size: 16, color: Colors.amber),
                              const SizedBox(width: 8),
                              const Text('Енергонезалежність:', style: TextStyle(fontSize: 13)),
                              const Spacer(),
                              Text(
                                store.hasGenerator ? 'Підключено генератор' : 'Звичайна мережа',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: store.hasGenerator ? AppColors.successGreen : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Action buttons
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: isCurrent ? Colors.grey[300] : AppColors.silpoOrange,
                          foregroundColor: isCurrent ? Colors.black54 : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: Icon(isCurrent ? Icons.check_circle : Icons.store, size: 20),
                        label: Text(
                          isCurrent ? '✓ Ваш основний супермаркет' : 'Обрати цей супермаркет',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        onPressed: isCurrent
                            ? null
                            : () {
                                storeViewModel.selectStore(store);
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('«${store.name}» встановлено як ваш супермаркет!'),
                                    backgroundColor: AppColors.silpoOrange,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                    hintText: 'Пошук серед 460+ супермаркетів Сільпо, адрес...',
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
                height: 38,
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

              const SizedBox(height: 10),

              // Service & Generator Filter Chips (styled to match Silpo screenshot)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SilpoFeatureChip(
                        emoji: '⚡',
                        label: 'З генератором',
                        isSelected: storeViewModel.onlyWithGenerator,
                        onTap: storeViewModel.toggleGeneratorFilter,
                      ),
                      const SizedBox(width: 8),
                      SilpoFeatureChip(
                        emoji: '🥐',
                        label: 'Власна пекарня',
                        isSelected: storeViewModel.onlyWithBakery,
                        onTap: storeViewModel.toggleBakeryFilter,
                      ),
                      const SizedBox(width: 8),
                      SilpoFeatureChip(
                        emoji: '☕',
                        label: "Кав'ярня Feeltrd",
                        isSelected: storeViewModel.onlyWithFeeltrd,
                        onTap: storeViewModel.toggleFeeltrdFilter,
                      ),
                      const SizedBox(width: 8),
                      SilpoFeatureChip(
                        emoji: '🔌',
                        label: 'Зарядка EV',
                        isSelected: storeViewModel.onlyWithEvCharging,
                        onTap: storeViewModel.toggleEvFilter,
                      ),
                      const SizedBox(width: 8),
                      SilpoFeatureChip(
                        emoji: '💊',
                        label: 'Аптека',
                        isSelected: storeViewModel.onlyWithPharmacy,
                        onTap: storeViewModel.togglePharmacyFilter,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Active Selected Store Banner
              if (storeViewModel.selectedStore != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _showStoreDetailsSheet(context, storeViewModel.selectedStore!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.silpoOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.silpoOrange.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.storefront, color: AppColors.silpoOrange, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ВАШ ОБРАНИЙ СУПЕРМАРКЕТ:',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.silpoOrange,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  '${storeViewModel.selectedStore!.name} (${storeViewModel.selectedStore!.city})',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          if (storeViewModel.selectedStore!.hasGenerator)
                            const Text('⚡', style: TextStyle(fontSize: 15)),
                          const SizedBox(width: 4),
                          const Icon(Icons.info_outline, size: 16, color: AppColors.silpoOrange),
                        ],
                      ),
                    ),
                  ),
                ),

              // Store count indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                      Flexible(
                        child: Text(
                          storeViewModel.selectedStore!.city,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.silpoOrange,
                            fontWeight: FontWeight.bold,
                          ),
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
                                margin: const EdgeInsets.only(bottom: 16),
                                elevation: isCurrent ? 3 : 1,
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  side: BorderSide(
                                    color: isCurrent ? AppColors.silpoOrange : (isDark ? Colors.white12 : Colors.grey[200]!),
                                    width: isCurrent ? 2.2 : 1,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () => _showStoreDetailsSheet(context, store),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Store Photo Banner with Theme Overlay
                                      Stack(
                                        children: [
                                          SilpoNetworkImage(
                                            imageUrl: store.imageUrl,
                                            height: 140,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                                            fallbackIcon: Icons.storefront,
                                          ),
                                          // Dark gradient overlay for text readability
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.black.withValues(alpha: 0.1),
                                                    Colors.black.withValues(alpha: 0.65),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Concept Theme Chip
                                          if (store.conceptTheme != null)
                                            Positioned(
                                              top: 10,
                                              left: 10,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withValues(alpha: 0.75),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: Colors.white38),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.palette_outlined, color: AppColors.silpoYellow, size: 14),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      store.conceptTheme!,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          // Distance Badge
                                          Positioned(
                                            top: 10,
                                            right: 10,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(alpha: 0.75),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.near_me, color: Colors.white, size: 12),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    '${store.distanceKm.toStringAsFixed(1)} км',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Status bar on bottom of banner
                                          Positioned(
                                            bottom: 10,
                                            left: 12,
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    color: store.isOpen ? AppColors.successGreen : Colors.grey,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  store.isOpen ? 'Відчинено зараз' : 'Зачинено',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Store Details
                                      Padding(
                                        padding: const EdgeInsets.all(14),
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
                                                      Text(
                                                        store.name,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 3),
                                                      Row(
                                                        children: [
                                                          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.silpoOrange),
                                                          const SizedBox(width: 4),
                                                          Expanded(
                                                            child: Text(
                                                              '${store.city}, ${store.address}',
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    store.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                                                    color: store.isFavorite ? Colors.amber : Colors.grey,
                                                    size: 26,
                                                  ),
                                                  onPressed: () => storeViewModel.toggleFavorite(store.filialId),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 10),

                                            // Amenities Pills (styled like the screenshot)
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 6,
                                              children: [
                                                if (store.hasGenerator)
                                                  const SilpoFeatureChip(
                                                    emoji: '⚡',
                                                    label: 'З генератором',
                                                    isCompact: true,
                                                  ),
                                                if (store.hasBakery)
                                                  const SilpoFeatureChip(
                                                    emoji: '🥐',
                                                    label: 'Власна пекарня',
                                                    isCompact: true,
                                                  ),
                                                if (store.hasFeeltrd)
                                                  const SilpoFeatureChip(
                                                    emoji: '☕',
                                                    label: "Кав'ярня Feeltrd",
                                                    isCompact: true,
                                                  ),
                                                if (store.hasEvCharging)
                                                  const SilpoFeatureChip(
                                                    emoji: '🔌',
                                                    label: 'Зарядка EV',
                                                    isCompact: true,
                                                  ),
                                                if (store.hasPharmacy)
                                                  const SilpoFeatureChip(
                                                    emoji: '💊',
                                                    label: 'Аптека',
                                                    isCompact: true,
                                                  ),
                                              ],
                                            ),

                                            const SizedBox(height: 14),

                                            // Working Hours and Selection Action
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(Icons.schedule, size: 14, color: Colors.grey),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      store.workingHours,
                                                      style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                                                    ),
                                                  ],
                                                ),
                                                FilledButton(
                                                  onPressed: isCurrent
                                                      ? null
                                                      : () {
                                                          storeViewModel.selectStore(store);
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                              content: Text('«${store.name}» обрано як ваш супермаркет Сільпо!'),
                                                              backgroundColor: AppColors.silpoOrange,
                                                              duration: const Duration(seconds: 1),
                                                            ),
                                                          );
                                                        },
                                                  style: FilledButton.styleFrom(
                                                    visualDensity: VisualDensity.compact,
                                                    backgroundColor: isCurrent ? Colors.grey[300] : AppColors.silpoOrange,
                                                    foregroundColor: isCurrent ? Colors.black54 : Colors.white,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                                  ),
                                                  child: Text(
                                                    isCurrent ? '✓ Мій супермаркет' : 'Обрати магазин',
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
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
