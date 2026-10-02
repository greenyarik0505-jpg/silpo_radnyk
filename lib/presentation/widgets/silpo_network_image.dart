import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Polished image component for Silpo product photos and supermarket storefronts.
/// Displays network photos with subtle gradient placeholders, loading spinner, and stylized fallback icons.
class SilpoNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;
  final Color? backgroundColor;

  const SilpoNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.borderRadius,
    this.fallbackIcon = Icons.shopping_basket_outlined,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(12);

    final placeholderGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
          : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
    );

    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          gradient: backgroundColor == null ? placeholderGradient : null,
          borderRadius: radius,
        ),
        child: Center(
          child: Icon(
            fallbackIcon,
            size: (height != null && height! < 60) ? 22 : 36,
            color: AppColors.silpoOrange.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: width,
        height: height,
        color: backgroundColor ?? (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
        child: Image.network(
          imageUrl!,
          width: width,
          height: height,
          fit: fit,
          filterQuality: FilterQuality.medium,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            final expectedTotal = loadingProgress.expectedTotalBytes;
            final loaded = loadingProgress.cumulativeBytesLoaded;
            final progress = expectedTotal != null ? loaded / expectedTotal : null;

            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                gradient: placeholderGradient,
              ),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 2,
                    color: AppColors.silpoOrange,
                  ),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: backgroundColor,
                gradient: backgroundColor == null ? placeholderGradient : null,
                borderRadius: radius,
              ),
              child: Center(
                child: Icon(
                  fallbackIcon,
                  size: (height != null && height! < 60) ? 22 : 36,
                  color: AppColors.silpoOrange.withValues(alpha: 0.6),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
