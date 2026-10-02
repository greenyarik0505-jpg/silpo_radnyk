import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum SilpoBadgeType {
  discount,
  privateLabel,
  bonus,
  dietary,
  cinotyzhik,
}

class SilpoBadge extends StatelessWidget {
  final String text;
  final SilpoBadgeType type;
  final IconData? icon;

  const SilpoBadge({
    super.key,
    required this.text,
    this.type = SilpoBadgeType.discount,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor, border) = switch (type) {
      SilpoBadgeType.discount => (
          AppColors.discountRed,
          Colors.white,
          null,
        ),
      SilpoBadgeType.cinotyzhik => (
          AppColors.silpoOrange,
          Colors.white,
          null,
        ),
      SilpoBadgeType.privateLabel => (
          AppColors.silpoYellowLight,
          const Color(0xFF92400E),
          Border.all(color: AppColors.silpoYellow),
        ),
      SilpoBadgeType.bonus => (
          AppColors.vlasnyiRakhunokLight,
          AppColors.vlasnyiRakhunok,
          null,
        ),
      SilpoBadgeType.dietary => (
          AppColors.successGreenLight,
          AppColors.successGreen,
          Border.all(color: AppColors.successGreen.withValues(alpha: 0.3)),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
