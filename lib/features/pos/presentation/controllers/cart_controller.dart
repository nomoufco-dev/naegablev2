import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/entities/order_entity.dart';
import '../../../../core/domain/entities/product_entity.dart';
import '../../../../core/domain/repositories/order_repository.dart';

class CartItem {
  const CartItem({
    required this.product,
    required this.quantity,
    this.notes,
  });

  final ProductEntity product;
  final int quantity;
  final String? notes;

  double get subtotal => product.price * quantity;

  CartItem copyWith({
    ProductEntity? product,
    int? quantity,
    String? notes,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }
}

class CartState {
  const CartState({
    this.items = const [],
    this.orderType = 'dine_in', // 'dine_in', 'take_away', 'delivery'
    this.deliveryFee = 0.0,
    this.discountAmount = 0.0,
    this.customerName,
    this.customerPhone,
    this.deliveryAddress,
    this.notes,
  });

  final List<CartItem> items;
  final String orderType;
  final double deliveryFee;
  final double discountAmount;
  final String? customerName;
  final String? customerPhone;
  final String? deliveryAddress;
  final String? notes;

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.subtotal);

  // PB1 / Pajak restoran 10%
  double get taxAmount => (subtotal - discountAmount) * 0.10;

  double get effectiveDeliveryFee => orderType == 'delivery' ? deliveryFee : 0.0;

  double get grandTotal {
    final base = (subtotal - discountAmount) + taxAmount + effectiveDeliveryFee;
    return base < 0 ? 0.0 : base;
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  CartState copyWith({
    List<CartItem>? items,
    String? orderType,
    double? deliveryFee,
    double? discountAmount,
    String? customerName,
    String? customerPhone,
    String? deliveryAddress,
    String? notes,
  }) {
    return CartState(
      items: items ?? this.items,
      orderType: orderType ?? this.orderType,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discountAmount: discountAmount ?? this.discountAmount,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      notes: notes ?? this.notes,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addItem(ProductEntity product) {
    final existingIndex = state.items.indexWhere((i) => i.product.id == product.id);

    if (existingIndex >= 0) {
      final updatedList = List<CartItem>.from(state.items);
      final current = updatedList[existingIndex];
      // Pastikan kuantitas tidak melebihi stok yang ada
      if (product.trackStock && current.quantity >= product.currentStock) {
        return;
      }
      updatedList[existingIndex] = current.copyWith(quantity: current.quantity + 1);
      state = state.copyWith(items: updatedList);
    } else {
      if (product.trackStock && product.currentStock <= 0) {
        return;
      }
      state = state.copyWith(items: [...state.items, CartItem(product: product, quantity: 1)]);
    }
  }

  void decrementItem(String productId) {
    final existingIndex = state.items.indexWhere((i) => i.product.id == productId);
    if (existingIndex < 0) return;

    final updatedList = List<CartItem>.from(state.items);
    final current = updatedList[existingIndex];

    if (current.quantity > 1) {
      updatedList[existingIndex] = current.copyWith(quantity: current.quantity - 1);
      state = state.copyWith(items: updatedList);
    } else {
      updatedList.removeAt(existingIndex);
      state = state.copyWith(items: updatedList);
    }
  }

  void removeItem(String productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.product.id != productId).toList(),
    );
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    final existingIndex = state.items.indexWhere((i) => i.product.id == productId);
    if (existingIndex >= 0) {
      final updatedList = List<CartItem>.from(state.items);
      updatedList[existingIndex] = updatedList[existingIndex].copyWith(quantity: quantity);
      state = state.copyWith(items: updatedList);
    }
  }

  void setOrderType(String orderType, {double deliveryFee = 10000.0}) {
    state = state.copyWith(
      orderType: orderType,
      deliveryFee: deliveryFee,
    );
  }

  void setCustomerInfo({
    String? customerName,
    String? customerPhone,
    String? deliveryAddress,
    String? notes,
  }) {
    state = state.copyWith(
      customerName: customerName,
      customerPhone: customerPhone,
      deliveryAddress: deliveryAddress,
      notes: notes,
    );
  }

  void clearCart() {
    state = const CartState();
  }

  Future<OrderEntity> checkout({
    required OrderRepository orderRepo,
    required String paymentMethod,
    double? amountTendered,
  }) async {
    final now = DateTime.now();
    final orderId = 'ord-${now.millisecondsSinceEpoch}';
    final orderNum = 'NGB-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';

    final orderItems = state.items.map((item) {
      return OrderItemEntity(
        id: 'item-${item.product.id}-$orderId',
        orderId: orderId,
        productId: item.product.id,
        productName: item.product.name,
        unitPrice: item.product.price,
        quantity: item.quantity,
        subtotal: item.subtotal,
        notes: item.notes,
        createdAt: now,
      );
    }).toList();

    final tendered = amountTendered ?? state.grandTotal;
    final change = tendered - state.grandTotal;

    final order = OrderEntity(
      id: orderId,
      storeId: 'store-main-001',
      orderNumber: orderNum,
      cashierId: 'profile-admin-001',
      orderType: state.orderType,
      orderStatus: 'completed',
      customerName: state.customerName,
      customerPhone: state.customerPhone,
      deliveryAddress: state.deliveryAddress,
      subtotal: state.subtotal,
      discountAmount: state.discountAmount,
      taxAmount: state.taxAmount,
      deliveryFee: state.effectiveDeliveryFee,
      totalAmount: state.grandTotal,
      notes: state.notes,
      items: orderItems,
      paymentMethod: paymentMethod,
      amountTendered: tendered,
      changeAmount: change > 0 ? change : 0.0,
      createdAt: now,
      updatedAt: now,
    );

    await orderRepo.createOrder(order);
    clearCart();
    return order;
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
