
import 'package:flutter/material.dart';

class AddShoppingItemDialog extends StatefulWidget {
  final void Function(
    String name,
    double quantity,
    String unit,
  ) onAdd;

  const AddShoppingItemDialog({
    super.key,
    required this.onAdd,
  });

  @override
  State<AddShoppingItemDialog> createState() =>
      _AddShoppingItemDialogState();
}

class _AddShoppingItemDialogState
    extends State<AddShoppingItemDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();

  String _selectedUnit = 'kg';

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Shopping Item'),

      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Enter an item name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final quantity =
                      double.tryParse(value ?? '');

                  if (quantity == null ||
                      !quantity.isFinite ||
                      quantity <= 0) {
                    return 'Enter a valid quantity';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _selectedUnit,
                decoration: const InputDecoration(
                  labelText: 'Unit',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'kg',
                    child: Text('Kilograms'),
                  ),
                  DropdownMenuItem(
                    value: 'g',
                    child: Text('Grams'),
                  ),
                  DropdownMenuItem(
                    value: 'L',
                    child: Text('Liters'),
                  ),
                  DropdownMenuItem(
                    value: 'ml',
                    child: Text('Milliliters'),
                  ),
                  DropdownMenuItem(
                    value: 'pcs',
                    child: Text('Pieces'),
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
          child: const Text('Add Item'),
        ),
      ],
    );
  }
}
