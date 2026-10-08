import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_naegable/app/app.dart';
import 'package:pos_naegable/core/utils/currency_formatter.dart';

void main() {
  group('POS Naegable Foundation Tests', () {
    test('CurrencyFormatter formats IDR correctly', () {
      expect(CurrencyFormatter.format(25000), 'Rp 25.000');
      expect(CurrencyFormatter.format(1500000), 'Rp 1.500.000');
      expect(CurrencyFormatter.format(0), 'Rp 0');
    });

    testWidgets('PosNaegableApp initializes and displays brand mark on splash', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: PosNaegableApp(),
        ),
      );

      // Verifikasi komponen teks brand pada Splash screen
      expect(find.text('naegablé'), findsOneWidget);
      expect(find.text('BAKEHAUS'), findsOneWidget);
    });
  });
}
