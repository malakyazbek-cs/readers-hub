import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models.dart';
import '../dbhelper.dart';

const Color deepCosmos = Color(0xFF1F1A3D);
const Color nebulaPurple = Color(0xFF5E35B1);
const Color fantasyBlue = Color(0xFF3B82F6);
const Color stardustGold = Color(0xFFFFE082);
const Color magicPink = Color(0xFFF48FB1);
const Color lightText = Colors.white;
const Color subtleText = Color(0xFFC0C0C0);

class OrderItemDetail {
  final OrderItemModel orderItem;
  final ProductModel product;
  OrderItemDetail({required this.orderItem, required this.product});
}

class CustomerOrdersScreen extends StatefulWidget {
  const CustomerOrdersScreen({super.key});

  @override
  State<CustomerOrdersScreen> createState() => _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends State<CustomerOrdersScreen> {
  int? _userId;
  late Future<List<OrderHeaderModel>> _ordersFuture = Future.value([]);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_userId == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is UserModel) {
        _userId = args.id;
      } else if (args is int) {
        _userId = args;
      }

      if (_userId != null) {
        _ordersFuture = DBHelper.instance.getOrdersByUserId(_userId!);
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: User not logged in or ID not provided.')),
          );
        });
      }
    }
  }

  Future<List<OrderItemDetail>> _fetchOrderItemsDetails(int orderId) async {
    final orderItems = await DBHelper.instance.getOrderItemsByOrderId(orderId);
    final List<OrderItemDetail> details = [];

    for (var item in orderItems) {
      final product = await DBHelper.instance.getProductById(item.productId);
      if (product != null) {
        details.add(OrderItemDetail(orderItem: item, product: product));
      }
    }
    return details;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'shipped':
        return fantasyBlue;
      case 'delivered':
        return nebulaPurple;
      case 'pending':
        return magicPink;
      default:
        return subtleText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepCosmos,
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: nebulaPurple,
        foregroundColor: lightText,
      ),
      body: FutureBuilder<List<OrderHeaderModel>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: stardustGold));
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading orders: ${snapshot.error}',
                style: const TextStyle(color: lightText),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('You have no past orders.', style: TextStyle(color: subtleText, fontSize: 18)),
            );
          } else {
            final orders = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final orderDate = DateTime.tryParse(order.orderDate) ?? DateTime.now();

                return Card(
                  color: deepCosmos,
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(color: nebulaPurple, width: 1),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      collapsedIconColor: subtleText,
                      iconColor: magicPink,
                      title: Text(
                        'Order #${order.id}',
                        style: const TextStyle(color: lightText, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Text(
                        'Date: ${DateFormat('MMM dd, yyyy').format(orderDate)}',
                        style: const TextStyle(color: subtleText, fontSize: 14),
                      ),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${order.total.toStringAsFixed(2)}',
                            style: const TextStyle(color: stardustGold, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order.status),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              order.status,
                              style: const TextStyle(color: lightText, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      children: [
                        const Divider(height: 1, color: nebulaPurple),
                        FutureBuilder<List<OrderItemDetail>>(
                          future: _fetchOrderItemsDetails(order.id!),
                          builder: (context, itemSnapshot) {
                            if (itemSnapshot.connectionState == ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: stardustGold))),
                              );
                            } else if (itemSnapshot.hasError || !itemSnapshot.hasData || itemSnapshot.data!.isEmpty) {
                              return const ListTile(
                                title: Text('Error loading items.', style: TextStyle(color: magicPink)),
                              );
                            } else {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: itemSnapshot.data!.map((detail) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(5),
                                          child: Image.asset(
                                            'assets/images/${detail.product.imageUrl}',
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Icon(
                                              Icons.menu_book,
                                              size: 40,
                                              color: fantasyBlue,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${detail.orderItem.quantity}x ${detail.product.title}',
                                                style: const TextStyle(color: lightText, fontSize: 15),
                                              ),
                                              Text(
                                                'Option: ${detail.orderItem.selectedOptions}',
                                                style: const TextStyle(color: subtleText, fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '\$${(detail.orderItem.priceAtPurchase * detail.orderItem.quantity).toStringAsFixed(2)}',
                                          style: const TextStyle(color: stardustGold, fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
