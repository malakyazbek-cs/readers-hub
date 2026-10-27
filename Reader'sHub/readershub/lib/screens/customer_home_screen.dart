import 'package:flutter/material.dart';
import 'package:readershub/screens/admin_home_screen.dart';
import '../dbhelper.dart';
import '../models.dart';

const Color fantasyBlue = Color(0xFF3B82F6);

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  late Future<List<ProductModel>> _productsFuture;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _productsFuture = DBHelper.instance.getProducts();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is UserModel && _currentUser == null) {
      _currentUser = args;
    }

    final welcomeTitle =
    _currentUser != null ? 'Welcome ${_currentUser!.username}' : 'Shop';

    return Scaffold(
      appBar: AppBar(
        title: Text(welcomeTitle),
        backgroundColor: nebulaPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/cart',
                arguments: _currentUser,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.receipt),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/customerOrders',
                arguments: _currentUser,
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error loading products: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found.'));
          } else {
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                final imageWidget = Image.asset(
                  'assets/${product.imageUrl}',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported,
                      size: 50,
                    );
                  },
                );

                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: imageWidget,
                  ),
                  title: Text(product.title),
                  subtitle: Text(
                    '${product.category} - \$${product.price.toStringAsFixed(2)}',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    if (product.id != null && _currentUser != null) {
                      Navigator.pushNamed(
                      context,
                      '/itemDetails',
                      arguments: {
                      'productId': product.id,
                      'userId': _currentUser!.id,
                      },
                    );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Error: Product ID is missing.'),
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
