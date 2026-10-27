import 'package:flutter/material.dart';

const Color deepCosmos = Color(0xFF1F1A3D);
const Color nebulaPurple = Color(0xFF5E35B1);
const Color fantasyBlue = Color(0xFF3B82F6);
const Color stardustGold = Color(0xFFFFE082);
const Color lightText = Colors.white;
const Color subtleText = Color(0xFFC0C0C0);
const Color magicPink = Color(0xFFF48FB1);


class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  final List<Map<String, dynamic>> adminModules = const [
    {
      'title': 'Manage Products',
      'icon': Icons.inventory_2_outlined,
      'route': '/adminProducts',
      'color': nebulaPurple,
    },
    {
      'title': 'View Orders',
      'icon': Icons.receipt_long,
      'route': '/adminOrders',
      'color': fantasyBlue,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepCosmos,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: nebulaPurple,
        foregroundColor: lightText,
        elevation: 10,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: stardustGold,
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
            tooltip: 'Logout',
          ),
        ],
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Welcome, Administrator!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: lightText,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Quick access to critical management tools.',
                style: TextStyle(
                  fontSize: 16,
                  color: subtleText,
                ),
              ),
              const Divider(color: subtleText, height: 40),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.0,
                ),
                itemCount: adminModules.length,
                itemBuilder: (context, index) {
                  final module = adminModules[index];
                  return _buildDashboardTile(
                    context,
                    title: module['title'],
                    icon: module['icon'],
                    route: module['route'],
                    color: module['color'],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardTile(
      BuildContext context, {
        required String title,
        required IconData icon,
        required String route,
        required Color color,
      }) {
    Color tileTextColor = color == stardustGold ? deepCosmos : lightText;
    Color iconColor = color == stardustGold ? deepCosmos : stardustGold;

    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Icon(
                icon,
                size: 40,
                color: iconColor,
              ),
            ),

            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: tileTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}