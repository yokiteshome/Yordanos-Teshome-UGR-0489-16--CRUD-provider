import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart.dart';
import '../providers/cart_provider.dart';

Color colorWithAlpha(Color color, double opacity) {
  return color.withAlpha((255 * opacity).toInt());
}

class EditCartScreen extends StatefulWidget {
  final List<Cart> cartItems;
  final int cartId;

  const EditCartScreen({
    super.key,
    required this.cartItems,
    required this.cartId,
  });

  @override
  State<EditCartScreen> createState() => _EditCartScreenState();
}

class _EditCartScreenState extends State<EditCartScreen> {
  late List<Cart> _editableItems;
  late List<TextEditingController> _quantityControllers;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _editableItems = List.from(widget.cartItems);
    _quantityControllers = _editableItems
        .map((item) => TextEditingController(text: item.quantity.toString()))
        .toList();
  }

  @override
  void dispose() {
    for (var controller in _quantityControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _removeItem(int index) {
    setState(() {
      _quantityControllers[index].dispose();
      _quantityControllers.removeAt(index);
      _editableItems.removeAt(index);
    });
  }

  Future<void> _saveChanges() async {
    for (var controller in _quantityControllers) {
      final quantity = int.tryParse(controller.text);
      if (quantity == null || quantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter valid quantities (greater than 0)'),
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final products = <Map<String, dynamic>>[];
      for (int i = 0; i < _editableItems.length; i++) {
        final item = _editableItems[i];
        final newQuantity = int.parse(_quantityControllers[i].text);

        products.add({
          'id': item.id,
          'title': item.title,
          'price': item.price,
          'quantity': newQuantity,
          'total': item.price * newQuantity,
          'discountPercentage': item.discountPercentage,
          'discountedTotal':
              (item.price * newQuantity) -
              ((item.price * newQuantity) * item.discountPercentage / 100),
          'thumbnail': item.thumbnail,
        });
      }

      final provider = context.read<CartProvider>();
      await provider.updateCart(widget.cartId, products);

      if (!mounted) return;

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      final updatedProvider = context.read<CartProvider>();
      if (updatedProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating cart: ${updatedProvider.error}'),
          ),
        );
        setState(() => _isLoading = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cart updated successfully!')),
        );
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Cart'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primaryColor,
      ),
      body: _editableItems.isEmpty
          ? Center(
              child: Text(
                'No items in cart',
                style: TextStyle(
                  fontSize: 18,
                  color: colorWithAlpha(primaryColor, 0.6),
                ),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cart ${widget.cartId}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Edit Items',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _editableItems.length,
                      itemBuilder: (context, index) {
                        final item = _editableItems[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colorWithAlpha(primaryColor, 0.2),
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: colorWithAlpha(primaryColor, 0.05),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: Colors.white,
                                      ),
                                      child: item.thumbnail.isNotEmpty
                                          ? Image.network(
                                              item.thumbnail,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Icon(
                                                    Icons.image,
                                                    color: colorWithAlpha(
                                                      primaryColor,
                                                      0.5,
                                                    ),
                                                  ),
                                            )
                                          : Icon(
                                              Icons.image,
                                              color: colorWithAlpha(
                                                primaryColor,
                                                0.5,
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Price: \$${item.price.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: colorWithAlpha(
                                                primaryColor,
                                                0.7,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Discount: ${item.discountPercentage}%',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: colorWithAlpha(
                                                primaryColor,
                                                0.7,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Divider(
                                  color: colorWithAlpha(primaryColor, 0.2),
                                  thickness: 1,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _quantityControllers[index],
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: 'Quantity',
                                          labelStyle: TextStyle(
                                            color: colorWithAlpha(
                                              primaryColor,
                                              0.6,
                                            ),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            borderSide: BorderSide(
                                              color: colorWithAlpha(
                                                primaryColor,
                                                0.3,
                                              ),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            borderSide: BorderSide(
                                              color: colorWithAlpha(
                                                primaryColor,
                                                0.3,
                                              ),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            borderSide: BorderSide(
                                              color: primaryColor,
                                              width: 2,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 10,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: colorWithAlpha(
                                          primaryColor,
                                          0.6,
                                        ),
                                      ),
                                      onPressed: () => _removeItem(index),
                                      tooltip: 'Remove item',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                            label: const Text('Cancel'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorWithAlpha(
                                primaryColor,
                                0.2,
                              ),
                              foregroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _saveChanges,
                            icon: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: Text(
                              _isLoading ? 'Saving...' : 'Save Changes',
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
