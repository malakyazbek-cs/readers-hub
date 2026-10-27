import 'package:flutter/material.dart';
import '../models.dart';
import '../dbhelper.dart';

const Color deepCosmos = Color(0xFF1F1A3D);
const Color nebulaPurple = Color(0xFF5E35B1);
const Color fantasyBlue = Color(0xFF3B82F6);
const Color stardustGold = Color(0xFFFFE082);
const Color magicPink = Color(0xFFF48FB1);
const Color lightText = Colors.white;
const Color subtleText = Color(0xFFC0C0C0);

class CartItemDetail {
  final CartItemModel cartItem;
  final ProductModel product;

  CartItemDetail({required this.cartItem, required this.product});
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Future<List<CartItemDetail>>? _cartDetailsFuture;
  int _userId = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is UserModel) {
        _userId = args.id ?? 1;
      } else if (args is int) {
        _userId = args;
      }
      setState(() {
        _cartDetailsFuture = _fetchCartDetails(_userId);
      });
    });
  }

  Future<List<CartItemDetail>> _fetchCartDetails(int userId) async {
    final cartItems = await DBHelper.instance.getCartItems(userId);
    final List<CartItemDetail> details = [];
    for (var item in cartItems) {
      final product = await DBHelper.instance.getProductById(item.productId);
      if (product != null) {
        details.add(CartItemDetail(cartItem: item, product: product));
      }
    }
    return details;
  }

  Future<void> _removeItem(int cartItemId) async {
    await DBHelper.instance.deleteCartItem(cartItemId);
    setState(() {
      _cartDetailsFuture = _fetchCartDetails(_userId);
    });
  }

  Future<void> _clearCart() async {
    await DBHelper.instance.clearCart(_userId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cart cleared successfully!'),
        backgroundColor: nebulaPurple,
      ),
    );
    setState(() {
      _cartDetailsFuture = _fetchCartDetails(_userId);
    });
  }

  void _navigateToCheckout(double total) {
    if (total <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty.'),
          backgroundColor: magicPink,
        ),
      );
      return;
    }
    Navigator.pushNamed(context, '/checkout', arguments: _userId).then((_) {
      setState(() {
        _cartDetailsFuture = _fetchCartDetails(_userId);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepCosmos,
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: nebulaPurple,
        foregroundColor: lightText,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearCart,
          ),
        ],
      ),
      body: _cartDetailsFuture == null
          ? const Center(
        child: CircularProgressIndicator(color: stardustGold),
      )
          : FutureBuilder<List<CartItemDetail>>(
        future: _cartDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: stardustGold),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading cart: ${snapshot.error}',
                style: const TextStyle(color: lightText),
              ),
            );
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(
              child: Text(
                'Your cart is empty!',
                style: TextStyle(color: subtleText, fontSize: 18),
              ),
            );
          }

          final total = data.fold<double>(
            0,
                (s, d) =>
            s + d.cartItem.priceAtAddition * d.cartItem.quantity,
          );

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final detail = data[index];
                    final cartItem = detail.cartItem;
                    final product = detail.product;

                    return Card(
                      color: deepCosmos,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                            color: nebulaPurple, width: 0.5),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/${product.imageUrl}',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.menu_book,
                              size: 60,
                              color: fantasyBlue,
                            ),
                          ),
                        ),
                        title: Text(
                          product.title,
                          style: const TextStyle(
                              color: lightText,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Option: ${cartItem.selectedOptions}',
                              style: const TextStyle(
                                  color: subtleText, fontSize: 12),
                            ),
                            Text(
                              'Unit Price: \$${cartItem.priceAtAddition.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: subtleText, fontSize: 12),
                            ),
                            Text(
                              'Quantity: ${cartItem.quantity}',
                              style: const TextStyle(
                                  color: subtleText, fontSize: 14),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '\$${(cartItem.priceAtAddition * cartItem.quantity).toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: stardustGold,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: magicPink),
                              onPressed: cartItem.id == null
                                  ? null
                                  : () => _removeItem(cartItem.id!),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  color: nebulaPurple,
                  boxShadow: [
                    BoxShadow(color: Colors.black45, blurRadius: 10)
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Items: ${data.length}',
                          style: const TextStyle(
                              color: lightText, fontSize: 16),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Grand Total',
                          style: TextStyle(
                              color: lightText,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: stardustGold,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: ElevatedButton.icon(
                  onPressed:
                  total > 0 ? () => _navigateToCheckout(total) : null,
                  icon: const Icon(Icons.payment),
                  label: const Text(
                    'Proceed to Checkout',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: magicPink,
                    foregroundColor: lightText,
                    minimumSize: const Size(double.infinity, 50),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
