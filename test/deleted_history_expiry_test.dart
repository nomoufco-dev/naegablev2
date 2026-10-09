import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_naegable/core/di/providers.dart';
import 'package:pos_naegable/core/domain/entities/order_entity.dart';
import 'package:pos_naegable/core/domain/repositories/order_repository.dart';
import 'package:pos_naegable/core/utils/date_formatter.dart';
import 'package:pos_naegable/features/history/presentation/screens/deleted_history_screen.dart';

class MockOrderRepo implements OrderRepository {
  final List<OrderEntity> _orders = [];

  MockOrderRepo(List<OrderEntity> orders) {
    _orders.addAll(orders);
  }

  @override
  Future<List<OrderEntity>> getOrders() async => List.from(_orders);

  @override
  Future<OrderEntity?> getOrderById(String id) async =>
      _orders.where((o) => o.id == id).firstOrNull;

  @override
  Future<void> createOrder(OrderEntity order) async {
    _orders.add(order);
  }

  @override
  Future<void> updateOrderStatus(String id, String status) async {
    final idx = _orders.indexWhere((o) => o.id == id);
    if (idx != -1) {
      _orders[idx] = _orders[idx].copyWith(orderStatus: status);
    }
  }

  @override
  Future<void> deleteOrder(String id) async {
    _orders.removeWhere((o) => o.id == id);
  }

  @override
  Future<Map<String, dynamic>> getSalesSummary() async => {};
}

void main() {
  group('Logika Kedaluwarsa 3 Bulan (DateFormatter.isWithin3Months)', () {
    final now = DateTime(2026, 10, 9, 12, 0, 0);

    test('Batas tepat 3 bulan (2026-07-09 12:00:00 vs 2026-10-09 12:00:00) -> belum kedaluwarsa', () {
      final exact3Months = DateTime(2026, 7, 9, 12, 0, 0);
      expect(DateFormatter.isWithin3Months(exact3Months, now: now), isTrue);
    });

    test('Lewat 1 hari dari 3 bulan (2026-07-08 12:00:00) -> kedaluwarsa', () {
      final expiredBy1Day = DateTime(2026, 7, 8, 12, 0, 0);
      expect(DateFormatter.isWithin3Months(expiredBy1Day, now: now), isFalse);
    });

    test('Lewat 1 detik dari 3 bulan (2026-07-09 11:59:59) -> kedaluwarsa', () {
      final expiredBy1Sec = DateTime(2026, 7, 9, 11, 59, 59);
      expect(DateFormatter.isWithin3Months(expiredBy1Sec, now: now), isFalse);
    });

    test('Kurang dari 3 bulan (2026-07-10 12:00:00) -> belum kedaluwarsa', () {
      final within3Months = DateTime(2026, 7, 10, 12, 0, 0);
      expect(DateFormatter.isWithin3Months(within3Months, now: now), isTrue);
    });

    test('Order baru (1 minggu lalu) -> belum kedaluwarsa', () {
      final recent = DateTime(2026, 10, 2, 12, 0, 0);
      expect(DateFormatter.isWithin3Months(recent, now: now), isTrue);
    });

    test('Penanganan batas bulan (31 Maret - 3 bulan -> 31 Desember tahun sebelumnya)', () {
      final mar31 = DateTime(2026, 3, 31, 10, 0, 0);
      final dec31PrevYear = DateTime(2025, 12, 31, 10, 0, 0);
      final dec30PrevYear = DateTime(2025, 12, 30, 10, 0, 0);

      expect(DateFormatter.isWithin3Months(dec31PrevYear, now: mar31), isTrue);
      expect(DateFormatter.isWithin3Months(dec30PrevYear, now: mar31), isFalse);
    });
  });

  group('DeletedHistoryScreen Widget Filter Tests', () {
    testWidgets('Tampilkan order cancelled < 3 bulan, sembunyikan order cancelled > 3 bulan & order aktif',
        (WidgetTester tester) async {
      final validCancelledOrder = OrderEntity(
        id: 'ord-valid',
        storeId: 'store-1',
        orderNumber: 'TRX-VALID-CANCELLED',
        orderType: 'take_away',
        orderStatus: 'cancelled',
        customerName: 'Siti',
        subtotal: 20000.0,
        totalAmount: 22000.0,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      );

      final expiredCancelledOrder = OrderEntity(
        id: 'ord-expired',
        storeId: 'store-1',
        orderNumber: 'TRX-EXPIRED-CANCELLED',
        orderType: 'take_away',
        orderStatus: 'cancelled',
        customerName: 'Doni',
        subtotal: 30000.0,
        totalAmount: 33000.0,
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        updatedAt: DateTime.now().subtract(const Duration(days: 120)),
      );

      final activeOrder = OrderEntity(
        id: 'ord-active',
        storeId: 'store-1',
        orderNumber: 'TRX-ACTIVE-ORDER',
        orderType: 'dine_in',
        orderStatus: 'completed',
        customerName: 'Rina',
        subtotal: 40000.0,
        totalAmount: 44000.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final repo = MockOrderRepo([
        validCancelledOrder,
        expiredCancelledOrder,
        activeOrder,
      ]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderRepositoryProvider.overrideWithValue(repo),
          ],
          child: const MaterialApp(
            home: DeletedHistoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Order cancelled belum kedaluwarsa HARUS tampil
      expect(find.text('Siti'), findsOneWidget);
      expect(find.text('TRX-VALID-CANCELLED'), findsOneWidget);

      // Order cancelled kedaluwarsa (> 3 bulan) TIDAK Boleh tampil
      expect(find.text('Doni'), findsNothing);
      expect(find.text('TRX-EXPIRED-CANCELLED'), findsNothing);

      // Order aktif TIDAK Boleh tampil
      expect(find.text('Rina'), findsNothing);
      expect(find.text('TRX-ACTIVE-ORDER'), findsNothing);

      // Banner 3 bulan tetap ada
      expect(
        find.text('Riwayat pesanan masih dapat dilihat hingga 3 bulan terakhir.'),
        findsOneWidget,
      );
    });
  });
}