import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_naegable/app/app_router.dart';
import 'package:pos_naegable/features/history/presentation/screens/deleted_history_screen.dart';

void main() {
  testWidgets('Navigasi tombol sampah di AppBar OrderListScreen membuka DeletedHistoryScreen mode orders', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: appRouter,
        ),
      ),
    );

    // Buka rute /orders
    appRouter.go('/orders');
    await tester.pumpAndSettle();

    // Pastikan tombol sampah ada di AppBar
    final trashButtonFinder = find.byKey(const Key('trash_button'));
    expect(trashButtonFinder, findsOneWidget);

    // Tap tombol sampah
    await tester.tap(trashButtonFinder);
    await tester.pumpAndSettle();

    // Verifikasi DeletedHistoryScreen terbuka
    expect(find.byType(DeletedHistoryScreen), findsOneWidget);
    expect(find.text('Riwayat Pesanan Terhapus'), findsOneWidget);
    expect(
      find.text('Riwayat pesanan masih dapat dilihat hingga 3 bulan terakhir.'),
      findsOneWidget,
    );
  });
}
