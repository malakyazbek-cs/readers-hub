import 'package:flutter/material.dart';
import '../dbhelper.dart';
import '../models.dart';

const Color magicPink = Color(0xFFF48FB1);

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  Future<void> deleteProduct(int id) async {
    await DBHelper.instance.deleteProduct(id);
    setState(() {}); // Refresh the list after deletion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products'),
        backgroundColor: magicPink,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: DBHelper.instance.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          final products = snapshot.data!;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: ListTile(
                  leading: Image.asset(
                    'assets/${product.imageUrl}',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(product.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${product.category} - \$${product.price.toStringAsFixed(2)}'),
                      if (product.options.isNotEmpty)
                        Text('Options: ${product.options}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () {
                      deleteProduct(product.id!);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
