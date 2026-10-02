import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Reusable Silpo store feature pill badge and filter chip.
/// Designed to exactly match the dark-navy pill style from the official Silpo app:
/// 🍕 Власна піцерія | 🍣 Суші-бар | 🧀 Власна сироварня | 🍷 Винний бутік
class SilpoFeatureChip extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isCompact;

  const SilpoFeatureChip({
    super.key,
    required this.emoji,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isInteractive = onTap != null;

    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 14,
        vertical: isCompact ? 5 : 8,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.silpoOrange
            : const Color(0xFF131D2D), // Silpo deep navy container
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.85),
          width: isSelected ? 1.6 : 1.2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.silpoOrange.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: TextStyle(
              fontSize: isCompact ? 12 : 14,
              height: 1.1,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: isCompact ? 11 : 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );

    if (isInteractive) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: child,
        ),
      );
    }

    return child;
  }
}
