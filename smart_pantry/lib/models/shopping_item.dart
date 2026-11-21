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
}
