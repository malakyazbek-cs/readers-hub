import 'package:flutter/material.dart';
import 'package:readershub/dbhelper.dart';

const Color magicPink = Color(0xFFF48FB1);

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = DBHelper.instance.getOrdersDetail();
  }

  String _formatOptions(String? selectedOptions) {
    if (selectedOptions == null || selectedOptions.isEmpty) {
      return '';
    }
    return 'Options: $selectedOptions';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: magicPink,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          final orders = snapshot.data!;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final int orderId = order['orderId'] as int;
              final String username = order['username'] as String;
              final String productTitle = order['productTitle'] as String;
              final int quantity = order['quantity'] as int;
              final String selectedOptions =
                  order['selectedOptions'] as String? ?? '';

              return ListTile(
                title: Text('Order #$orderId - $productTitle'),
                subtitle: Text(
                  'User: $username | Quantity: $quantity\n${_formatOptions(selectedOptions)}',
                ),
                isThreeLine: true,
                onTap: () {
                  debugPrint('Order #$orderId tapped');
                },
              );
            },
          );
        },
      ),
    );
  }
}
