import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Custom colors extracted from the UI image
  final Color _bgColorTop = const Color(0xFF2D1B36); // Dark purple top
  final Color _bgColorBottom = const Color(0xFF121212); // Near black bottom
  final Color _inputFill = const Color(0xFF1E1E1E); // Dark input background
  final Color _primaryButton = const Color(0xFFA12B51); // Dark pink/burgundy
  final Color _secondaryText = const Color(0xFF9E9E9E); // Muted grey

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiService.login(email, password);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgColorTop, _bgColorBottom],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // --- Logo Section ---
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.flash_on,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'BIG',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const Text(
                      'BIKE',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white38),
                    ),
                  ],
                ),
                const SizedBox(height: 60),

                // --- Header Text ---
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue your journey',
                  style: TextStyle(fontSize: 16, color: _secondaryText),
                ),
                const SizedBox(height: 40),

                // --- Email Field ---
                _buildLabel('Email'),
                const SizedBox(height: 8),
                _buildTextField(
                  hint: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // --- Password Field ---
                _buildLabel('Password'),
                const SizedBox(height: 8),
                _buildTextField(
                  hint: 'Enter your password',
                  controller: _passwordController,
                  isPassword: true,
                  suffix: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: _secondaryText,
                      size: 20,
                    ),
                    onPressed: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),

                // --- Forgot Password ---
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text('Forgot Password?',
                        style: TextStyle(color: _secondaryText)),
                  ),
                ),
                const SizedBox(height: 20),

                // --- Sign In Button ---
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryButton,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Sign In',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward,
                                  color: Colors.white, size: 20),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 30),

                // --- Divider ---
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white10)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Or continue with',
                          style: TextStyle(color: _secondaryText)),
                    ),
                    Expanded(child: Divider(color: Colors.white10)),
                  ],
                ),
                const SizedBox(height: 30),

                // --- Social Buttons ---
                Row(
                  children: [
                    Expanded(
                        child: _buildSocialButton(
                            label: 'Google', icon: Icons.g_mobiledata)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildSocialButton(
                            label: 'Facebook', icon: Icons.facebook)),
                  ],
                ),
                const SizedBox(height: 40),

                // --- Sign Up Link ---
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: _secondaryText),
                      children: const [
                        TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(
                              color: Color(0xFFC084FC),
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widget for Labels
  Widget _buildLabel(String text) {
    return Text(text,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w500));
  }

  // Helper Widget for Input Fields
  Widget _buildTextField({
    required String hint,
    bool isPassword = false,
    Widget? suffix,
    TextEditingController? controller,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword && !_isPasswordVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _secondaryText.withOpacity(0.5)),
        filled: true,
        fillColor: _inputFill,
        suffixIcon: suffix,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Helper Widget for Social Buttons
  Widget _buildSocialButton({required String label, required IconData icon}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: _inputFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
