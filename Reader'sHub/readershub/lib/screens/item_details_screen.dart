import 'package:flutter/material.dart';
import '../models.dart';
import '../dbhelper.dart';

class ItemDetailsArgs {
  final int productId;
  final int userId;
  ItemDetailsArgs({required this.productId, required this.userId});
}

const Color deepCosmos = Color(0xFF1F1A3D);
const Color nebulaPurple = Color(0xFF5E35B1);
const Color fantasyBlue = Color(0xFF3B82F6);
const Color stardustGold = Color(0xFFFFE082);
const Color magicPink = Color(0xFFF48FB1);
const Color lightText = Colors.white;
const Color subtleText = Color(0xFFC0C0C0);

class ItemDetailsScreen extends StatefulWidget {
  const ItemDetailsScreen({super.key});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  ProductModel? _product;
  String? _selectedOption;
  int _quantity = 1;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_product == null && _isLoading) {
      _fetchProductDetails();
    }
  }

  Future<void> _fetchProductDetails() async {
    final rawArgs = ModalRoute.of(context)?.settings.arguments;
    ItemDetailsArgs? args;

    if (rawArgs is Map<String, dynamic>) {
      final productId = rawArgs['productId'] as int?;
      final userId = rawArgs['userId'] as int?;
      if (productId != null && userId != null) {
        args = ItemDetailsArgs(productId: productId, userId: userId);
      }
    }

    if (args == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final product = await DBHelper.instance.getProductById(args.productId);

    if (product != null) {
      final optionsList =
      product.options.split(',').map((e) => e.trim()).toList();
      setState(() {
        _product = product;
        _selectedOption = optionsList.isNotEmpty ? optionsList.first : null;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addToCart(int userId, int productId) async {
    if (_product == null || _selectedOption == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select an option.')));
      return;
    }

    final cartItem = CartItemModel(
      userId: userId,
      productId: productId,
      quantity: _quantity,
      selectedOptions: _selectedOption!,
      priceAtAddition: _product!.price,
    );

    try {
      await DBHelper.instance.insertCartItem(cartItem);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_product!.title} added to cart!'),
            backgroundColor: nebulaPurple,
          ),
        );
        Navigator.pushNamed(context, '/cart');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to cart: $e'),
            backgroundColor: magicPink,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rawArgs = ModalRoute.of(context)?.settings.arguments;
    ItemDetailsArgs? args;

    if (rawArgs is Map<String, dynamic>) {
      final productId = rawArgs['productId'] as int?;
      final userId = rawArgs['userId'] as int?;
      if (productId != null && userId != null) {
        args = ItemDetailsArgs(productId: productId, userId: userId);
      }
    }

    if (args == null || _isLoading) {
      return Scaffold(
        backgroundColor: deepCosmos,
        appBar: AppBar(
          title: const Text('Loading...'),
          backgroundColor: nebulaPurple,
          foregroundColor: lightText,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: stardustGold),
        ),
      );
    }

    if (_product == null) {
      return Scaffold(
        backgroundColor: deepCosmos,
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: nebulaPurple,
          foregroundColor: lightText,
        ),
        body: const Center(
          child: Text('Product not found.', style: TextStyle(color: lightText)),
        ),
      );
    }

    final optionsList =
    _product!.options.split(',').map((e) => e.trim()).toList();

    return Scaffold(
      backgroundColor: deepCosmos,
      appBar: AppBar(
        title: Text(_product!.title),
        backgroundColor: nebulaPurple,
        foregroundColor: lightText,
        elevation: 8,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                height: 250,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  image: DecorationImage(
                    image: AssetImage('assets/${_product!.imageUrl}'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              _product!.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: lightText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              '\$${_product!.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: stardustGold,
              ),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 40, color: nebulaPurple),
            if (optionsList.isNotEmpty) ...[
              const Text(
                'Select Option / Format',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: lightText,
                ),
              ),
              const SizedBox(height: 10),
              ...optionsList.map((option) {
                return Card(
                  color: deepCosmos,
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: _selectedOption == option
                          ? magicPink
                          : subtleText.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: RadioListTile<String>(
                    value: option,
                    groupValue: _selectedOption,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                    title: Text(
                      option,
                      style: TextStyle(
                        color: _selectedOption == option
                            ? magicPink
                            : subtleText,
                      ),
                    ),
                    activeColor: magicPink,
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quantity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: lightText,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            color: subtleText),
                        onPressed:
                        _quantity > 1 ? () => setState(() => _quantity--) : null,
                      ),
                      Container(
                        width: 40,
                        alignment: Alignment.center,
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: lightText,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline,
                            color: fantasyBlue),
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _selectedOption != null
                  ? () => _addToCart(args!.userId, args.productId)
                  : null,
              icon: const Icon(Icons.shopping_cart),
              label: Text(
                'Add $_quantity to Cart',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: magicPink,
                foregroundColor: lightText,
                minimumSize: const Size(double.infinity, 50),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
