import 'package:flutter/material.dart';

import '../../models/shopping_item.dart';

class AddShoppingItemDialog extends StatefulWidget {
  final void Function(String name, double quantity, String unit) onAdd;

  final ShoppingItem? existingItem;

  const AddShoppingItemDialog({
    super.key,
    required this.onAdd,
    this.existingItem,
  });

  @override
  State<AddShoppingItemDialog> createState() => _AddShoppingItemDialogState();
}

class _AddShoppingItemDialogState extends State<AddShoppingItemDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;

  late String _selectedUnit;

  bool get _isEditing => widget.existingItem != null;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.existingItem?.name ?? '',
    );

    _quantityController = TextEditingController(
      text: widget.existingItem?.quantity.toString() ?? '',
    );

    _selectedUnit = widget.existingItem?.unit ?? 'kg';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Shopping Item' : 'Add Shopping Item'),

      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter an item name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final quantity = double.tryParse(value ?? '');

                  if (quantity == null || !quantity.isFinite || quantity <= 0) {
                    return 'Enter a valid quantity';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _selectedUnit,
                decoration: const InputDecoration(labelText: 'Unit'),
                items: [
                  const DropdownMenuItem(value: 'kg', child: Text('Kilograms')),
                  const DropdownMenuItem(value: 'g', child: Text('Grams')),
                  const DropdownMenuItem(value: 'L', child: Text('Liters')),
                  const DropdownMenuItem(
                    value: 'ml',
                    child: Text('Milliliters'),
                  ),
                  const DropdownMenuItem(value: 'pcs', child: Text('Pieces')),

                  // Support other existing item units.
                  if (widget.existingItem != null &&
                      ![
                        'kg',
                        'g',
                        'L',
                        'ml',
                        'pcs',
                      ].contains(widget.existingItem!.unit))
                    DropdownMenuItem(
                      value: widget.existingItem!.unit,
                      child: Text(widget.existingItem!.unit),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedUnit = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),

        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onAdd(
                _nameController.text.trim(),
                double.parse(_quantityController.text),
                _selectedUnit,
              );

              Navigator.pop(context);
            }
          },
          child: Text(_isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
