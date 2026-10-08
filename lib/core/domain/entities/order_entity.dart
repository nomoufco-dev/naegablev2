/// Entitas item pesanan di keranjang dan riwayat transaksi.
class OrderItemEntity {
  const OrderItemEntity({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
    this.variantId,
    this.notes,
    this.createdAt,
  });

  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double subtotal;
  final String? variantId;
  final String? notes;
  final DateTime? createdAt;

  OrderItemEntity copyWith({
    String? id,
    String? orderId,
    String? productId,
    String? productName,
    double? unitPrice,
    int? quantity,
    double? subtotal,
    String? variantId,
    String? notes,
    DateTime? createdAt,
  }) {
    return OrderItemEntity(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      subtotal: subtotal ?? this.subtotal,
      variantId: variantId ?? this.variantId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Entitas utama transaksi penjualan (Order).
class OrderEntity {
  const OrderEntity({
    required this.id,
    required this.storeId,
    required this.orderNumber,
    required this.orderType,
    required this.orderStatus,
    required this.subtotal,
    required this.totalAmount,
    this.cashierId,
    this.customerName,
    this.customerPhone,
    this.deliveryAddress,
    this.discountAmount = 0.0,
    this.taxAmount = 0.0,
    this.deliveryFee = 0.0,
    this.notes,
    this.items = const [],
    this.paymentMethod,
    this.amountTendered,
    this.changeAmount,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String storeId;
  final String orderNumber;
  final String? cashierId;
  final String orderType; // 'dine_in', 'take_away', 'delivery'
  final String orderStatus; // 'completed', 'pending', 'cancelled'
  final String? customerName;
  final String? customerPhone;
  final String? deliveryAddress;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double deliveryFee;
  final double totalAmount;
  final String? notes;
  final List<OrderItemEntity> items;
  final String? paymentMethod; // 'cash', 'qris', 'card'
  final double? amountTendered;
  final double? changeAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderEntity copyWith({
    String? id,
    String? storeId,
    String? orderNumber,
    String? cashierId,
    String? orderType,
    String? orderStatus,
    String? customerName,
    String? customerPhone,
    String? deliveryAddress,
    double? subtotal,
    double? discountAmount,
    double? taxAmount,
    double? deliveryFee,
    double? totalAmount,
    String? notes,
    List<OrderItemEntity>? items,
    String? paymentMethod,
    double? amountTendered,
    double? changeAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      orderNumber: orderNumber ?? this.orderNumber,
      cashierId: cashierId ?? this.cashierId,
      orderType: orderType ?? this.orderType,
      orderStatus: orderStatus ?? this.orderStatus,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amountTendered: amountTendered ?? this.amountTendered,
      changeAmount: changeAmount ?? this.changeAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
