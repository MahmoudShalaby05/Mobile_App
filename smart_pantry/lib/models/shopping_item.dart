class ShoppingItem {
  const ShoppingItem(
    this.id,
    this.name,
    this.quantity,
    this.unit, {
    this.isPurchased = false,
  });

  final String id;
  final String name;
  final double quantity;
  final String unit;
  final bool isPurchased;

  ShoppingItem toggle() =>
      ShoppingItem(id, name, quantity, unit, isPurchased: !isPurchased);
  ShoppingItem copyWith({
    String? name,
    double? quantity,
    String? unit,
    bool? isPurchased,
  }) {
    return ShoppingItem(
      id,
      name ?? this.name,
      quantity ?? this.quantity,
      unit ?? this.unit,
      isPurchased: isPurchased ?? this.isPurchased,
    );
  }
}

String normalizeShoppingUnit(String unit) {
  final normalized = unit.trim().toLowerCase();

  if (normalized == 'pcs' || normalized == 'pieces') {
    return 'pieces';
  }

  return normalized;
}
