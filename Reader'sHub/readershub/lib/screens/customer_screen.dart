import 'package:flutter/material.dart';

const Color deepCosmos = Color(0xFF1F1A3D);
const Color nebulaPurple = Color(0xFF5E35B1);
const Color fantasyBlue = Color(0xFF3B82F6);
const Color stardustGold = Color(0xFFFFE082);
const Color magicPink = Color(0xFFF48FB1);
const Color lightText = Colors.white;
const Color subtleText = Color(0xFFC0C0C0);

class CustomerScreen extends StatelessWidget {
  const CustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepCosmos,
      appBar: AppBar(
        title: const Text('Customer Screen'),
        centerTitle: true,
        backgroundColor: nebulaPurple,
        foregroundColor: lightText,
        elevation: 8,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.person,
                size: 80,
                color: stardustGold,
              ),
              const SizedBox(height: 30),
              const Text(
                'Access Our Shop',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: lightText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Sign in or create an account.',
                style: TextStyle(
                  fontSize: 16,
                  color: subtleText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: magicPink,
                  foregroundColor: lightText,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/customerLogin');
                },
                child: const Text(
                  'Sign In',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/customerRegister');
                },
                child: const Text(
                  'Create an Account ( Register )',
                  style: TextStyle(
                    fontSize: 16,
                    color: fantasyBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
