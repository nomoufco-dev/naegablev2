import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

/// Layar Login Naegablé Bakehaus sesuai spesifikasi Figma (DESIGN_SPEC_FIGMA.md):
/// Background cokelat, kartu putih rounded-3xl berisi logo,
/// field Username & Password (bg blush #F5CBD7, rounded-full), link "Forgot Password?",
/// tombol "Login" pink rounded-full.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    context.go('/pos');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 380),
              padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 36.0),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(28.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x2B000000),
                    blurRadius: 16.0,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Logo Script & Subtitle Caps
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'naegablé',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 36.0,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: AppColors.primary,
                            height: 1.0,
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          'BAKEHAUS',
                          style: TextStyle(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3.5,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32.0),

                  // Field Username
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.blush,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
                    child: TextField(
                      controller: _usernameController,
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Username',
                        hintStyle: TextStyle(
                          color: Color(0x99442F2A),
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: AppColors.primary,
                          size: 20.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14.0),

                  // Field Password
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.blush,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: const TextStyle(
                          color: Color(0x99442F2A),
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppColors.primary,
                          size: 20.0,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.primary,
                            size: 20.0,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),

                  // Link Forgot Password? Rata Kanan
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // Tombol Login Pink Rounded-Full
                  SizedBox(
                    height: 48.0,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blush,
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
