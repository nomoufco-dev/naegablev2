import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_naegable/core/di/providers.dart';
import 'package:pos_naegable/core/domain/entities/order_entity.dart';
import 'package:pos_naegable/core/domain/repositories/order_repository.dart';
import 'package:pos_naegable/features/history/presentation/screens/transaction_history_screen.dart';

class InMemoryOrderRepo implements OrderRepository {
  final List<OrderEntity> _orders = [];

  InMemoryOrderRepo(List<OrderEntity> initial) {
    _orders.addAll(initial);
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
  final sampleOrder1 = OrderEntity(
    id: 'ord-001',
    storeId: 'store-1',
    orderNumber: 'TRX20261002-001',
    orderType: 'dine_in',
    orderStatus: 'completed',
    customerName: 'Gaby',
    subtotal: 56000.0,
    taxAmount: 5600.0,
    totalAmount: 61600.0,
    createdAt: DateTime(2026, 10, 2, 11, 0),
    items: [
      const OrderItemEntity(
        id: 'item-1',
        orderId: 'ord-001',
        productId: 'prod-1',
        productName: 'Dubai Chewy Cookie',
        unitPrice: 28000.0,
        quantity: 2,
        subtotal: 56000.0,
      ),
    ],
  );

  final sampleOrder2 = OrderEntity(
    id: 'ord-002',
    storeId: 'store-1',
    orderNumber: 'TRX20261002-002',
    orderType: 'take_away',
    orderStatus: 'cancelled',
    customerName: 'Budi',
    subtotal: 25000.0,
    taxAmount: 2500.0,
    totalAmount: 27500.0,
    createdAt: DateTime(2026, 10, 2, 11, 30),
    items: [
      const OrderItemEntity(
        id: 'item-2',
        orderId: 'ord-002',
        productId: 'prod-2',
        productName: 'Butter Croissant',
        unitPrice: 25000.0,
        quantity: 1,
        subtotal: 25000.0,
      ),
    ],
  );

  testWidgets(
      'TransactionHistoryScreen visual mirror matches daftar pesanan design and hides cancelled orders',
      (WidgetTester tester) async {
    final repo = InMemoryOrderRepo([sampleOrder1, sampleOrder2]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          orderRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(
          home: TransactionHistoryScreen(),
        ),
      ),
    );

    // Initial pump & wait for future provider
    await tester.pumpAndSettle();

    // 1. Header verifications
    expect(find.text('Daftar Pesanan'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.assignment_return_outlined), findsOneWidget);

    // 2. Tab "Pesanan Dibatalkan" telah dihapus
    expect(find.text('Pesanan Dibatalkan'), findsNothing);

    // 3. Hanya menampilkan pesanan aktif (Gaby) dan TIDAK menampilkan pesanan dibatalkan (Budi)
    expect(find.text('Gaby'), findsOneWidget);
    expect(find.text('TRX20261002-001'), findsOneWidget);
    expect(find.text('Pesanan Baru'), findsOneWidget);
    expect(find.textContaining('Jadwal Pengambilan:', findRichText: true), findsOneWidget);
    expect(find.text('Budi'), findsNothing);

    // 4. Accordion expand
    expect(find.text('Dubai Chewy Cookie x2'), findsNothing);
    await tester.tap(find.text('Gaby'));
    await tester.pumpAndSettle();

    // After expand, item breakdown & total are visible
    expect(find.text('Dubai Chewy Cookie x2'), findsOneWidget);
    expect(find.text('Lihat Struk'), findsOneWidget);
    expect(find.text('Batalkan'), findsOneWidget);
  });
}