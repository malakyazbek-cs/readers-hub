import 'package:flutter/material.dart';
import 'package:readershub/screens/customer_login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_home_screen.dart';
import 'screens/admin_products_screen.dart';
import 'screens/admin_orders_screen.dart';
import 'screens/customer_screen.dart';
import 'screens/customer_register_screen.dart';
import 'screens/customer_home_screen.dart';
import 'screens/item_details_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/customer_orders_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Readers Hub',
      theme: ThemeData(primarySwatch: Colors.brown),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const WelcomeScreen(),
        '/adminLogin': (context) => const AdminLoginScreen(),
        '/adminHome': (context) => const AdminHomeScreen(),
        '/adminProducts': (context) => const AdminProductsScreen(),
        '/adminOrders': (context) => const AdminOrdersScreen(),
        '/customer': (context) => const CustomerScreen(),
        '/customerLogin': (context) => const CustomerLoginScreen(),
        '/customerRegister': (context) => const CustomerRegisterScreen(),
        '/customerHome': (context) => const CustomerHomeScreen(),
        '/itemDetails': (context) => const ItemDetailsScreen(),
        '/cart': (context) => const CartScreen(),
        '/checkout': (context) => const CheckoutScreen(),
        '/customerOrders': (context) => const CustomerOrdersScreen(),
      },
    );
  }
}
