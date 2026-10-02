class ReceiptItem {
  final String name;
  final double quantity;
  final String unit;
  final double price;
  final double total;
  final double discountAmount;
  final String category;

  const ReceiptItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.total,
    required this.discountAmount,
    required this.category,
  });
}

class FiscalReceipt {
  final String id;
  final String fiscalNumber;
  final DateTime dateTime;
  final String storeAddress;
  final double totalAmount;
  final double discountAmount;
  final int bonusPointsEarned;
  final List<ReceiptItem> items;
  final String paymentMethod; // Apple Pay, Картка, Готівка

  const FiscalReceipt({
    required this.id,
    required this.fiscalNumber,
    required this.dateTime,
    required this.storeAddress,
    required this.totalAmount,
    required this.discountAmount,
    required this.bonusPointsEarned,
    required this.items,
    this.paymentMethod = 'Apple Pay',
  });
}

class CategorySpending {
  final String category;
  final double amount;
  final double percentage;
  final int itemsCount;

  const CategorySpending({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.itemsCount,
  });
}

class InflationPoint {
  final String month;
  final double personalInflationRate; // e.g. +3.2%
  final double silpoAverageBasket; // e.g. 520.0 грн

  const InflationPoint({
    required this.month,
    required this.personalInflationRate,
    required this.silpoAverageBasket,
  });
}
