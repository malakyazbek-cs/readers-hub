import 'package:flutter/material.dart';
import '../dbhelper.dart';
import '../models.dart';

const Color deepCosmos = Color(0xFF1F1A3D);
const Color nebulaPurple = Color(0xFF5E35B1);
const Color fantasyBlue = Color(0xFF3B82F6);
const Color stardustGold = Color(0xFFFFE082);
const Color magicPink = Color(0xFFF48FB1);
const Color lightText = Colors.white;
const Color subtleText = Color(0xFFC0C0C0);

class CheckoutItemDetail {
  final int cartId;
  final int productId;
  final String productTitle;
  final String productImageUrl;
  final double priceAtAddition;
  final int quantity;
  final String selectedOptions;

  CheckoutItemDetail.fromMap(Map<String, dynamic> map)
      : cartId = map['cartId'] as int,
        productId = map['productId'] as int,
        productTitle = map['productTitle'] as String,
        productImageUrl = map['productImageUrl'] as String,
        priceAtAddition = map['priceAtAddition'] as double,
        quantity = map['quantity'] as int,
        selectedOptions = map['selectedOptions'] as String;
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Future<List<CheckoutItemDetail>>? _cartDetailsFuture;
  int? _userId;
  bool _isProcessing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_userId == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        _userId = args;
      } else if (args is UserModel) {
        _userId = args.id;
      } else {
        _userId = 1;
      }
      _cartDetailsFuture = _fetchCartDetails(_userId!);
    }
  }

  Future<List<CheckoutItemDetail>> _fetchCartDetails(int userId) async {
    final rawData = await DBHelper.instance.getCartDetailsForCheckout(userId);
    return rawData.map((map) => CheckoutItemDetail.fromMap(map)).toList();
  }

  Future<void> _confirmOrder(List<CheckoutItemDetail> cartDetails, double orderTotal) async {
    if (_userId == null || cartDetails.isEmpty || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final orderHeader = OrderHeaderModel(
        userId: _userId!,
        orderDate: DateTime.now().toIso8601String(),
        total: orderTotal,
        status: 'Pending',
      );

      final rawCartDetails = cartDetails.map((item) => {
        'productId': item.productId,
        'quantity': item.quantity,
        'selectedOptions': item.selectedOptions,
        'priceAtAddition': item.priceAtAddition,
      }).toList();

      final orderId = await DBHelper.instance.createOrder(orderHeader, rawCartDetails);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order #$orderId placed successfully!'),
            backgroundColor: fantasyBlue,
          ),
        );
        Navigator.of(context).pushNamedAndRemoveUntil('/orders', (route) => false, arguments: _userId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: magicPink),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepCosmos,
      appBar: AppBar(
        title: const Text('Confirm Purchase'),
        backgroundColor: nebulaPurple,
        foregroundColor: lightText,
      ),
      body: FutureBuilder<List<CheckoutItemDetail>>(
        future: _cartDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: stardustGold));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No items to checkout', style: TextStyle(color: subtleText)));
          }

          final cartDetails = snapshot.data!;
          final orderTotal = cartDetails.fold(0.0, (sum, item) => sum + (item.priceAtAddition * item.quantity));

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartDetails.length,
                  itemBuilder: (context, index) {
                    final item = cartDetails[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: nebulaPurple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.asset(
                              'assets/${item.productImageUrl}',
                              width: 50, height: 50, fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.book, color: lightText),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.productTitle, style: const TextStyle(color: lightText, fontWeight: FontWeight.bold)),
                                Text('Qty: ${item.quantity} | ${item.selectedOptions}', style: const TextStyle(color: subtleText, fontSize: 12)),
                              ],
                            ),
                          ),
                          Text('\$${(item.priceAtAddition * item.quantity).toStringAsFixed(2)}', style: const TextStyle(color: stardustGold, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: nebulaPurple,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount', style: TextStyle(color: lightText, fontSize: 18)),
                        Text('\$${orderTotal.toStringAsFixed(2)}', style: const TextStyle(color: stardustGold, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isProcessing ? null : () => _confirmOrder(cartDetails, orderTotal),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: magicPink,
                        foregroundColor: lightText,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isProcessing
                          ? const CircularProgressIndicator(color: lightText)
                          : const Text('PLACE ORDER', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}