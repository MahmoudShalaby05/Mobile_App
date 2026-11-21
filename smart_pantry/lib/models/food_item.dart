class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
    required this.location,
    required this.expirationDate,
  });

  final String id;
  final String name;
  final double quantity;
  final String unit;
  final String category;
  final String location;
  final DateTime expirationDate;

  int get daysRemaining {
    final now = DateTime.now();
    return DateTime.utc(
      expirationDate.year,
      expirationDate.month,
      expirationDate.day,
    ).difference(DateTime.utc(now.year, now.month, now.day)).inDays;
  }

  bool get isExpiringSoon => daysRemaining >= 0 && daysRemaining <= 3;
}

String quantityLabel(double quantity) =>
    quantity.toStringAsFixed(quantity == quantity.roundToDouble() ? 0 : 2);

String normalizeName(String name) =>
    name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
