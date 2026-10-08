import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/sqlite_order_datasource.dart';

/// Implementasi OrderRepository berbasis SQLite lokal.
class SqliteOrderRepository implements OrderRepository {
  SqliteOrderRepository(this._datasource);

  final SqliteOrderDatasource _datasource;

  @override
  Future<List<OrderEntity>> getOrders() async {
    final rows = await _datasource.fetchOrders();
    final List<OrderEntity> orders = [];

    for (final row in rows) {
      final orderId = row['id'] as String;
      final itemRows = await _datasource.fetchOrderItems(orderId);
      final items = itemRows.map(_mapRowToItemEntity).toList();
      orders.add(_mapRowToOrderEntity(row, items));
    }

    return orders;
  }

  @override
  Future<OrderEntity?> getOrderById(String id) async {
    final row = await _datasource.fetchOrderById(id);
    if (row == null) return null;
    final itemRows = await _datasource.fetchOrderItems(id);
    final items = itemRows.map(_mapRowToItemEntity).toList();
    return _mapRowToOrderEntity(row, items);
  }

  @override
  Future<void> createOrder(OrderEntity order) async {
    final now = DateTime.now().toIso8601String();
    final orderRow = {
      'id': order.id,
      'store_id': order.storeId,
      'order_number': order.orderNumber,
      'cashier_id': order.cashierId ?? 'profile-admin-001',
      'order_type': order.orderType,
      'order_status': order.orderStatus,
      'customer_name': order.customerName,
      'customer_phone': order.customerPhone,
      'delivery_address': order.deliveryAddress,
      'subtotal': order.subtotal,
      'discount_amount': order.discountAmount,
      'tax_amount': order.taxAmount,
      'delivery_fee': order.deliveryFee,
      'total_amount': order.totalAmount,
      'notes': order.notes,
      'created_at': order.createdAt?.toIso8601String() ?? now,
      'updated_at': now,
    };

    final itemRows = order.items.map((item) {
      return {
        'id': item.id,
        'order_id': order.id,
        'product_id': item.productId,
        'variant_id': item.variantId,
        'product_name': item.productName,
        'unit_price': item.unitPrice,
        'quantity': item.quantity,
        'subtotal': item.subtotal,
        'notes': item.notes,
        'created_at': item.createdAt?.toIso8601String() ?? now,
      };
    }).toList();

    Map<String, dynamic>? paymentRow;
    if (order.paymentMethod != null) {
      paymentRow = {
        'id': 'pay-${order.id}',
        'order_id': order.id,
        'store_id': order.storeId,
        'payment_method': order.paymentMethod,
        'payment_status': 'paid',
        'amount_tendered': order.amountTendered ?? order.totalAmount,
        'change_amount': order.changeAmount ?? 0.0,
        'reference_number': 'REF-${DateTime.now().millisecondsSinceEpoch}',
        'paid_at': now,
        'created_at': now,
      };
    }

    await _datasource.insertCompleteOrder(
      orderRow: orderRow,
      itemRows: itemRows,
      paymentRow: paymentRow,
    );
  }

  @override
  Future<void> updateOrderStatus(String id, String status) async {
    await _datasource.updateOrderStatus(id, status);
  }

  @override
  Future<void> deleteOrder(String id) async {
    await _datasource.deleteOrder(id);
  }

  @override
  Future<Map<String, dynamic>> getSalesSummary() async {
    final orders = await getOrders();
    double totalRevenue = 0.0;
    int totalItemsSold = 0;
    final Map<String, int> productSales = {};

    for (final order in orders) {
      totalRevenue += order.totalAmount;
      for (final item in order.items) {
        totalItemsSold += item.quantity;
        productSales[item.productName] = (productSales[item.productName] ?? 0) + item.quantity;
      }
    }

    return {
      'total_orders': orders.length,
      'total_revenue': totalRevenue,
      'total_items_sold': totalItemsSold,
      'average_order_value': orders.isEmpty ? 0.0 : totalRevenue / orders.length,
      'product_sales': productSales,
    };
  }

  OrderEntity _mapRowToOrderEntity(Map<String, dynamic> row, List<OrderItemEntity> items) {
    return OrderEntity(
      id: row['id'] as String,
      storeId: row['store_id'] as String,
      orderNumber: row['order_number'] as String,
      cashierId: row['cashier_id'] as String?,
      orderType: row['order_type'] as String,
      orderStatus: row['order_status'] as String,
      customerName: row['customer_name'] as String?,
      customerPhone: row['customer_phone'] as String?,
      deliveryAddress: row['delivery_address'] as String?,
      subtotal: (row['subtotal'] as num).toDouble(),
      discountAmount: (row['discount_amount'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (row['tax_amount'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (row['delivery_fee'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (row['total_amount'] as num).toDouble(),
      notes: row['notes'] as String?,
      items: items,
      createdAt: row['created_at'] != null ? DateTime.tryParse(row['created_at'] as String) : null,
      updatedAt: row['updated_at'] != null ? DateTime.tryParse(row['updated_at'] as String) : null,
    );
  }

  OrderItemEntity _mapRowToItemEntity(Map<String, dynamic> row) {
    return OrderItemEntity(
      id: row['id'] as String,
      orderId: row['order_id'] as String,
      productId: row['product_id'] as String,
      variantId: row['variant_id'] as String?,
      productName: row['product_name'] as String,
      unitPrice: (row['unit_price'] as num).toDouble(),
      quantity: row['quantity'] as int,
      subtotal: (row['subtotal'] as num).toDouble(),
      notes: row['notes'] as String?,
      createdAt: row['created_at'] != null ? DateTime.tryParse(row['created_at'] as String) : null,
    );
  }
}
