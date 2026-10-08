import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'app/app_bootstrap.dart';

/// Entrypoint minimalis aplikasi POS Naegable.
/// Seluruh inisialisasi diatur melalui AppBootstrap dan PosNaegableApp.
void main() async {
  await AppBootstrap.init();

  runApp(
    const ProviderScope(
      child: PosNaegableApp(),
    ),
  );
}
