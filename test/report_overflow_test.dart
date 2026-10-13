import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_naegable/core/di/providers.dart';
import 'package:pos_naegable/core/domain/repositories/order_repository.dart';
import 'package:pos_naegable/features/reports/presentation/screens/sales_report_screen.dart';

class _MockOrderRepo implements OrderRepository {
  @override
  Future<Map<String, dynamic>> getSalesSummary() async {
    return {
      'total_orders': 2,
      'total_revenue': 182600.0,
      'total_items_sold': 7,
      'average_order_value': 91300.0,
      'product_sales': {'Butter Croissant': 4, 'Pain au Chocolat': 3},
    };
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('Report screen tidak overflow di layar kecil', (tester) async {
    // Ukuran HP kecil
    tester.view.physicalSize = const Size(360 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          orderRepositoryProvider.overrideWithValue(_MockOrderRepo()),
        ],
        child: const MaterialApp(home: SalesReportScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Tidak boleh ada FlutterError (termasuk RenderFlex overflow)
    expect(tester.takeException(), isNull);
  });
}
