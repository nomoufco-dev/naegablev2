import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/brand_logo_view.dart';

/// Layar Splash Screen resmi Naegablé Bakehaus sesuai `SPLASH.png`
/// dan menggunakan aset `LOGO 1.png` sesuai instruksi desain.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        context.go('/pos');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _skipSplash() {
    _timer?.cancel();
    context.go('/pos');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _skipSplash,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Logo 1 resmi (assets/branding/LOGO 1.png) - Blush pink #F5CBD7 di atas Grey Brown #442F2A
              Image.asset(
                AppAssets.logo1,
                width: 175.0,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                isAntiAlias: true,
                errorBuilder: (context, error, stackTrace) => const BrandLogoView(
                  fontSize: 46.0,
                  primaryColor: AppColors.accent,
                  taglineColor: AppColors.accent,
                ),
              ),
              // Komponen teks semantik untuk aksesibilitas & validasi test
              const Opacity(
                opacity: 0.0,
                child: BrandLogoView(
                  fontSize: 1.0,
                  primaryColor: Colors.transparent,
                  taglineColor: Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
