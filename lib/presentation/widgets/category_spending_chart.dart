import 'package:flutter/material.dart';
import '../../domain/entities/receipt.dart';
import '../../core/constants/app_colors.dart';

class CategorySpendingChart extends StatelessWidget {
  final List<CategorySpending> spendingList;

  const CategorySpendingChart({
    super.key,
    required this.spendingList,
  });

  @override
  Widget build(BuildContext context) {
    if (spendingList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: spendingList.map((item) {
        final color = _getCategoryColor(item.category);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.category,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                  Text(
                    '${item.amount.toStringAsFixed(1)} ₴ (${item.percentage.toStringAsFixed(0)}%)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (item.percentage / 100).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getCategoryColor(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('сир') || cat.contains('масло')) return AppColors.silpoYellow;
    if (cat.contains('риба')) return AppColors.categoryDairy;
    if (cat.contains('м’яс') || cat.contains('мяс')) return AppColors.categoryMeat;
    if (cat.contains('овоч') || cat.contains('фрукт')) return AppColors.categoryProduce;
    if (cat.contains('пекарн')) return AppColors.categoryBakery;
    if (cat.contains('молоч')) return AppColors.categoryDairy;
    if (cat.contains('кава') || cat.contains('чай')) return AppColors.silpoOrange;
    return AppColors.categoryGrocery;
  }
}
