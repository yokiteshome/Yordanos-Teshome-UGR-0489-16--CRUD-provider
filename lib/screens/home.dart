import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/cart.dart';
import 'cart_details_screen.dart';

Color colorWithAlpha(Color color, double opacity) {
  return color.withAlpha((255 * opacity).toInt());
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCarts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yoyo cart'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: primaryColor),
            onPressed: () => context.read<CartProvider>().loadCarts(),
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.carts.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          if (provider.error != null && provider.carts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadCarts(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: provider.carts.length,
            itemBuilder: (context, index) {
              final cart = provider.carts[index];
              final cartItems = provider.carts
                  .where((item) => item.cartId == cart.cartId)
                  .toList();

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartDetailsScreen(
                        cartItems: cartItems,
                        cartId: cart.cartId,
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Cart number ${cart.cartId}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: primaryColor),
                                  onPressed: () =>
                                      _showUpdateDialog(context, cart),
                                  splashRadius: 20,
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: primaryColor),
                                  onPressed: () =>
                                      _showDeleteConfirm(context, cart.cartId),
                                  splashRadius: 20,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'User ID: ${cart.cartId}',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorWithAlpha(primaryColor, 0.7),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Items Preview:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ...List.generate(
                                cartItems.length,
                                (i) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: colorWithAlpha(
                                          primaryColor,
                                          0.3,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: cartItems[i].thumbnail.isNotEmpty
                                        ? Image.network(
                                            cartItems[i].thumbnail,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Icon(
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
                                ),
                              ),
                              if (cartItems.length > 4)
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: colorWithAlpha(primaryColor, 0.3),
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    color: colorWithAlpha(primaryColor, 0.1),
                                  ),
                                  child: Icon(
                                    Icons.shopping_cart,
                                    color: colorWithAlpha(primaryColor, 0.5),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${cart.total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            Text(
                              '${cartItems.length} items',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorWithAlpha(primaryColor, 0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add_shopping_cart, color: Colors.white),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Cart'),
        content: const Text('This will add a new cart with auto-assigned ID.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              final provider = context.read<CartProvider>();
              final autoUserId = DateTime.now().microsecond % 250 + 1;
              await provider.addCart(autoUserId, [
                {'id': 1, 'quantity': 1},
              ]);
              if (provider.error != null) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Error adding cart: ${provider.error}'),
                  ),
                );
              } else {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Cart added successfully!')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, Cart cart) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Cart'),
        content: Text('Update cart ${cart.cartId} with dummy items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              
              // Dummy data
              final dummyProducts = [
                {
                  'id': 1,
                  'title': 'Dummy Product 1',
                  'price': 10.0,
                  'quantity': 2,
                  'total': 20.0,
                  'discountPercentage': 0.0,
                  'discountedTotal': 20.0,
                  'thumbnail': '',
                },
              ];

              final provider = context.read<CartProvider>();
              await provider.updateCart(cart.cartId, dummyProducts);
              
              if (provider.error != null) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Error: ${provider.error}')),
                );
              } else {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Cart updated with dummy data!')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, int cartId) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete cart $cartId?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              final provider = context.read<CartProvider>();
              await provider.deleteCart(cartId);
              if (provider.error != null) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Error deleting cart: ${provider.error}'),
                  ),
                );
              } else {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Cart deleted successfully!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
