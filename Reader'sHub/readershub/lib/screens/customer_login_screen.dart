import 'package:flutter/material.dart';
import '../dbhelper.dart';

const Color deepCosmos = Color(0xFF1F1A3D);
const Color nebulaPurple = Color(0xFF5E35B1);
const Color fantasyBlue = Color(0xFF3B82F6);
const Color stardustGold = Color(0xFFFFE082);
const Color magicPink = Color(0xFFF48FB1);
const Color lightText = Colors.white;
const Color subtleText = Color(0xFFC0C0C0);
const Color errorRed = Colors.redAccent;

class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _message = '';
  Color _messageColor = errorRed;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _message = '';
      });

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      try {
        final user = await DBHelper.instance.loginUser(email, password);

        if (user != null) {
          if (mounted) {
            setState(() {
              _message = 'Login Successful! Welcome back, ${user.username}!';
              _messageColor = stardustGold;
            });
            await Future.delayed(const Duration(milliseconds: 1500));
            Navigator.pushReplacementNamed(
              context,
              '/customerHome',
              arguments: user,
            );
          }
        } else {
          if (mounted) {
            setState(() {
              _message = 'Invalid Email or Password. Please try again.';
              _messageColor = errorRed;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _message = 'An error occurred during login: $e';
            _messageColor = errorRed;
          });
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepCosmos,
      appBar: AppBar(
        title: const Text('Customer Login'),
        backgroundColor: nebulaPurple,
        foregroundColor: lightText,
        elevation: 8,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Welcome Back to Readers Hub',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: lightText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                _buildTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@') ||
                        !value.contains('.com')) {
                      return 'Please enter a valid email.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                if (_message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      _message,
                      style: TextStyle(
                        color: _messageColor,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: magicPink,
                    foregroundColor: lightText,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 5,
                  ),
                  onPressed: _isLoading ? null : _loginUser,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: lightText)
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/customerRegister');
                  },
                  child: const Text(
                    "Don't have an account? Register here",
                    style: TextStyle(color: fantasyBlue, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: lightText),
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: subtleText),
        prefixIcon: Icon(icon, color: fantasyBlue),
        fillColor: nebulaPurple.withOpacity(0.3),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: fantasyBlue, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: stardustGold, width: 2.0),
        ),
        errorStyle: const TextStyle(color: stardustGold),
      ),
    );
  }
}
