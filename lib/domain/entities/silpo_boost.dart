import 'package:flutter/material.dart';

/// Loyalty booster coupon for Silpo «Власний Рахунок» (Balochka Boost).
class SilpoBoostCoupon {
  final String id;
  final String title;
  final String category;
  final double multiplier;
  final int extraBonusPoints;
  final String badgeText;
  final String description;
  final bool isActivated;
  final DateTime expiresAt;
  final IconData icon;

  const SilpoBoostCoupon({
    required this.id,
    required this.title,
    required this.category,
    this.multiplier = 1.0,
    this.extraBonusPoints = 0,
    required this.badgeText,
    required this.description,
    this.isActivated = false,
    required this.expiresAt,
    this.icon = Icons.bolt,
  });

  SilpoBoostCoupon copyWith({
    String? id,
    String? title,
    String? category,
    double? multiplier,
    int? extraBonusPoints,
    String? badgeText,
    String? description,
    bool? isActivated,
    DateTime? expiresAt,
    IconData? icon,
  }) {
    return SilpoBoostCoupon(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      multiplier: multiplier ?? this.multiplier,
      extraBonusPoints: extraBonusPoints ?? this.extraBonusPoints,
      badgeText: badgeText ?? this.badgeText,
      description: description ?? this.description,
      isActivated: isActivated ?? this.isActivated,
      expiresAt: expiresAt ?? this.expiresAt,
      icon: icon ?? this.icon,
    );
  }
}
