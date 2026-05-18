import 'package:flutter/material.dart';
import '../models/cart.dart';

Color colorWithAlpha(Color color, double opacity) {
  return color.withAlpha((255 * opacity).toInt());
}

class CartDetailsScreen extends StatelessWidget {
  final List<Cart> cartItems;
  final int cartId;

  const CartDetailsScreen({
    super.key,
    required this.cartItems,
    required this.cartId,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    final totalItems = cartItems.length;
    final uniqueTypes = cartItems.map((item) => item.title).toSet().length;
    final totalPrice = cartItems.fold<double>(
      0,
      (sum, item) => sum + item.total,
    );
    final totalDiscount = cartItems.fold<double>(
      0,
      (sum, item) =>
          sum + (item.price * item.quantity * item.discountPercentage / 100),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Cart Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.menu, color: primaryColor, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'ORDER DETAILS',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorWithAlpha(primaryColor, 0.7),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatColumn(
                          context,
                          primaryColor,
                          totalItems.toString(),
                          'ITEMS',
                        ),
                        _buildStatColumn(
                          context,
                          primaryColor,
                          uniqueTypes.toString(),
                          'TYPES',
                        ),
                        _buildStatColumn(
                          context,
                          primaryColor,
                          '\$${totalDiscount.toStringAsFixed(2)}',
                          'SAVINGS',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Divider(
                      color: colorWithAlpha(primaryColor, 0.2),
                      thickness: 1,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL PAYABLE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorWithAlpha(primaryColor, 0.7),
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '\$${totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Products',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final product = cartItems[index];
                  return _buildProductCard(context, product, primaryColor);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    BuildContext context,
    Color primaryColor,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colorWithAlpha(primaryColor, 0.6),
            letterSpacing: 0.3,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Cart product,
    Color primaryColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorWithAlpha(primaryColor, 0.2)),
        borderRadius: BorderRadius.circular(8),
        color: colorWithAlpha(primaryColor, 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Center(
                child: product.thumbnail.isNotEmpty
                    ? Image.network(
                        product.thumbnail,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.image,
                          color: colorWithAlpha(primaryColor, 0.5),
                          size: 48,
                        ),
                      )
                    : Icon(
                        Icons.image,
                        color: colorWithAlpha(primaryColor, 0.5),
                        size: 48,
                      ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Qty: ${product.quantity}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorWithAlpha(primaryColor, 0.7),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${product.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
