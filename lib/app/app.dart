import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'app_router.dart';

/// Root widget aplikasi POS Naegable.
class PosNaegableApp extends StatelessWidget {
  const PosNaegableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Naegablé Bakehaus POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
