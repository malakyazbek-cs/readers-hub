import 'package:flutter/material.dart';
import 'admin_home_screen.dart';

const Color deepCosmos = Color(0xFF1F1A3D);
const Color nebulaPurple = Color(0xFF5E35B1);
const Color fantasyBlue = Color(0xFF3B82F6);
const Color stardustGold = Color(0xFFFFE082);
const Color magicPink = Color(0xFFF48FB1);
const Color lightText = Colors.white;
const Color subtleText = Color(0xFFC0C0C0);
const Color errorRed = Colors.redAccent;


class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _error = '';

  void _login() {
    if (_formKey.currentState!.validate()) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_userCtrl.text == 'malak' && _passCtrl.text == '0000') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
          );
        } else {
          setState(() {
            _error = 'Invalid admin credentials.';
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepCosmos,
      appBar: AppBar(
        title: const Text('Admin Login'),
        backgroundColor: nebulaPurple,
        foregroundColor: lightText,
        elevation: 8,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Card(
            color: deepCosmos.withOpacity(0.8),
            elevation: 15,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: nebulaPurple, width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.security,
                      size: 60,
                      color: fantasyBlue,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Administrator Login',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: lightText,
                      ),
                    ),
                    const SizedBox(height: 30),

                    _buildTextFormField(
                      controller: _userCtrl,
                      label: 'Username',
                      icon: Icons.person_outline,
                      validatorMessage: 'Username is required',
                    ),
                    const SizedBox(height: 20),

                    _buildTextFormField(
                      controller: _passCtrl,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      validatorMessage: 'Password is required',
                    ),

                    const SizedBox(height: 20),

                    if (_error.isNotEmpty)
                      Text(_error, style: TextStyle(color: errorRed, fontWeight: FontWeight.bold)),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: magicPink,
                          foregroundColor: lightText,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 8,
                        ),
                        onPressed: _login,
                        child: const Text(
                          'Login',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String validatorMessage,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: lightText),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: subtleText),
        prefixIcon: Icon(icon, color: fantasyBlue),
        fillColor: Colors.white.withOpacity(0.05),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: fantasyBlue, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: stardustGold, width: 2.0),
        ),
        errorStyle: TextStyle(color: errorRed),
      ),
      validator: (v) => v == null || v.isEmpty ? validatorMessage : null,
    );
  }
}