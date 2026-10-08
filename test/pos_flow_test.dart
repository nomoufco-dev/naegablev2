import 'package:flutter_test/flutter_test.dart';
import 'package:pos_naegable/core/domain/entities/order_entity.dart';
import 'package:pos_naegable/core/domain/entities/product_entity.dart';
import 'package:pos_naegable/core/domain/repositories/order_repository.dart';
import 'package:pos_naegable/features/pos/presentation/controllers/cart_controller.dart';

class FakeOrderRepository implements OrderRepository {
  final List<OrderEntity> orders = [];

  @override
  Future<void> createOrder(OrderEntity order) async {
    orders.add(order);
  }

  @override
  Future<void> updateOrderStatus(String id, String status) async {
    final index = orders.indexWhere((o) => o.id == id);
    if (index != -1) {
      orders[index] = orders[index].copyWith(orderStatus: status);
    }
  }

  @override
  Future<void> deleteOrder(String id) async {
    orders.removeWhere((o) => o.id == id);
  }

  @override
  Future<OrderEntity?> getOrderById(String id) async {
    return orders.where((o) => o.id == id).firstOrNull;
  }

  @override
  Future<List<OrderEntity>> getOrders() async {
    return List.from(orders);
  }

  @override
  Future<Map<String, dynamic>> getSalesSummary() async {
    double total = orders.fold(0.0, (sum, o) => sum + o.totalAmount);
    return {
      'total_orders': orders.length,
      'total_revenue': total,
      'total_items_sold': orders.fold(0, (sum, o) => sum + o.items.length),
      'average_order_value': orders.isEmpty ? 0.0 : total / orders.length,
    };
  }
}

void main() {
  group('POS Naegablé Cart & Business Logic Tests', () {
    late CartNotifier notifier;
    late FakeOrderRepository fakeOrderRepo;

    final testProductA = ProductEntity(
      id: 'prod-01',
      storeId: 'store-01',
      name: 'Butter Croissant',
      price: 20000.0,
      currentStock: 10,
    );

    final testProductB = ProductEntity(
      id: 'prod-02',
      storeId: 'store-01',
      name: 'Caffe Latte',
      price: 30000.0,
      currentStock: 10,
    );

    setUp(() {
      notifier = CartNotifier();
      fakeOrderRepo = FakeOrderRepository();
    });

    test('Initial cart is empty', () {
      expect(notifier.state.isEmpty, isTrue);
      expect(notifier.state.totalQuantity, 0);
      expect(notifier.state.grandTotal, 0.0);
    });

    test('Add item increments quantity and calculates subtotal correctly', () {
      notifier.addItem(testProductA);
      expect(notifier.state.items.length, 1);
      expect(notifier.state.totalQuantity, 1);
      expect(notifier.state.subtotal, 20000.0);

      // Tambah produk yang sama -> quantity menjadi 2
      notifier.addItem(testProductA);
      expect(notifier.state.items.length, 1);
      expect(notifier.state.totalQuantity, 2);
      expect(notifier.state.subtotal, 40000.0);
    });

    test('PB1 tax (10%) and grand total calculated accurately', () {
      notifier.addItem(testProductA); // 20.000
      notifier.addItem(testProductB); // 30.000
      // Subtotal = 50.000
      // Pajak 10% = 5.000
      // Grand total = 55.000
      expect(notifier.state.subtotal, 50000.0);
      expect(notifier.state.taxAmount, 5000.0);
      expect(notifier.state.grandTotal, 55000.0);
    });

    test('Delivery mode adds delivery fee to grand total', () {
      notifier.addItem(testProductA); // 20.000
      notifier.setOrderType('delivery', deliveryFee: 10000.0);

      // Subtotal: 20.000
      // Pajak: 2.000
      // Delivery Fee: 10.000
      // Grand Total: 32.000
      expect(notifier.state.effectiveDeliveryFee, 10000.0);
      expect(notifier.state.grandTotal, 32000.0);

      // Kembali ke Dine In -> Delivery Fee diabaikan
      notifier.setOrderType('dine_in');
      expect(notifier.state.effectiveDeliveryFee, 0.0);
      expect(notifier.state.grandTotal, 22000.0);
    });

    test('Decrement and remove item behavior', () {
      notifier.addItem(testProductA);
      notifier.addItem(testProductA);
      expect(notifier.state.items.first.quantity, 2);

      notifier.decrementItem(testProductA.id);
      expect(notifier.state.items.first.quantity, 1);

      // Decrement saat quantity 1 menghapus item dari keranjang
      notifier.decrementItem(testProductA.id);
      expect(notifier.state.isEmpty, isTrue);
    });

    test('Checkout flow successfully saves order to repository and clears cart', () async {
      notifier.addItem(testProductA);
      notifier.addItem(testProductB);

      final completedOrder = await notifier.checkout(
        orderRepo: fakeOrderRepo,
        paymentMethod: 'cash',
        amountTendered: 60000.0,
      );

      expect(completedOrder.items.length, 2);
      expect(completedOrder.totalAmount, 55000.0);
      expect(completedOrder.amountTendered, 60000.0);
      expect(completedOrder.changeAmount, 5000.0);
      expect(fakeOrderRepo.orders.length, 1);

      // Keranjang otomatis bersih setelah checkout
      expect(notifier.state.isEmpty, isTrue);
    });
  });
}
