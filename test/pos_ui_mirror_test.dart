import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_naegable/core/di/providers.dart';
import 'package:pos_naegable/core/domain/entities/category_entity.dart';
import 'package:pos_naegable/core/domain/entities/delivery_settings_entity.dart';
import 'package:pos_naegable/core/domain/entities/order_entity.dart';
import 'package:pos_naegable/core/domain/entities/product_entity.dart';
import 'package:pos_naegable/core/domain/repositories/category_repository.dart';
import 'package:pos_naegable/core/domain/repositories/delivery_settings_repository.dart';
import 'package:pos_naegable/core/domain/repositories/order_repository.dart';
import 'package:pos_naegable/core/domain/repositories/product_repository.dart';
import 'package:pos_naegable/core/widgets/custom_bottom_nav_bar.dart';
import 'package:pos_naegable/features/pos/presentation/screens/pos_screen.dart';
import 'package:pos_naegable/features/pos/presentation/widgets/category_filter_bar.dart';
import 'package:pos_naegable/features/pos/presentation/widgets/pos_app_bar.dart';
import 'package:pos_naegable/features/pos/presentation/widgets/quick_management_modal.dart';

class MockProductRepo implements ProductRepository {
  final List<ProductEntity> list = [
    const ProductEntity(
      id: 'p1',
      storeId: 's1',
      name: 'Butter Croissant',
      price: 22000.0,
      currentStock: 15,
    ),
    const ProductEntity(
      id: 'p2',
      storeId: 's1',
      name: 'Pain au Chocolat',
      price: 26000.0,
      currentStock: 20,
    ),
  ];

  @override
  Future<void> deleteProduct(String id) async => list.removeWhere((p) => p.id == id);

  @override
  Future<ProductEntity?> getProductById(String id) async => list.where((p) => p.id == id).firstOrNull;

  @override
  Future<List<ProductEntity>> getProducts({String? categoryId, String? searchQuery}) async {
    return list.where((p) {
      if (searchQuery != null && !p.name.toLowerCase().contains(searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<void> saveProduct(ProductEntity product) async {
    final idx = list.indexWhere((p) => p.id == product.id);
    if (idx >= 0) {
      list[idx] = product;
    } else {
      list.add(product);
    }
  }

  @override
  Future<void> updateStock(String id, int quantityDelta) async {}
}

class MockCategoryRepo implements CategoryRepository {
  final List<CategoryEntity> list = [
    const CategoryEntity(id: 'c1', storeId: 's1', name: 'Croissant', slug: 'croissant'),
    const CategoryEntity(id: 'c2', storeId: 's1', name: 'Sourdough', slug: 'sourdough'),
  ];

  @override
  Future<void> deleteCategory(String id) async => list.removeWhere((c) => c.id == id);

  @override
  Future<List<CategoryEntity>> getCategories() async => list;

  @override
  Future<CategoryEntity?> getCategoryById(String id) async => list.where((c) => c.id == id).firstOrNull;

  @override
  Future<void> saveCategory(CategoryEntity category) async => list.add(category);
}

class MockDeliveryRepo implements DeliverySettingsRepository {
  DeliverySettingsEntity current = const DeliverySettingsEntity(
    id: 'd1',
    storeId: 's1',
    isDeliveryEnabled: true,
  );

  @override
  Future<DeliverySettingsEntity> getSettings() async => current;

  @override
  Future<void> toggleDeliveryStatus(bool isEnabled) async {
    current = current.copyWith(isDeliveryEnabled: isEnabled);
  }

  @override
  Future<void> updateSettings(DeliverySettingsEntity settings) async {
    current = settings;
  }
}

class MockOrderRepo implements OrderRepository {
  @override
  Future<void> createOrder(OrderEntity order) async {}
  @override
  Future<void> updateOrderStatus(String id, String status) async {}
  @override
  Future<void> deleteOrder(String id) async {}
  @override
  Future<OrderEntity?> getOrderById(String id) async => null;
  @override
  Future<List<OrderEntity>> getOrders() async => [];
  @override
  Future<Map<String, dynamic>> getSalesSummary() async => {
        'total_orders': 0,
        'total_revenue': 0.0,
        'total_items_sold': 0,
        'average_order_value': 0.0,
        'product_sales': <String, int>{},
      };
}

void main() {
  testWidgets('PosScreen displays exact visual mirror elements: header, search, categories, bottom nav, FAB', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(MockProductRepo()),
          categoryRepositoryProvider.overrideWithValue(MockCategoryRepo()),
          deliverySettingsRepositoryProvider.overrideWithValue(MockDeliveryRepo()),
          orderRepositoryProvider.overrideWithValue(MockOrderRepo()),
        ],
        child: const MaterialApp(
          home: PosScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify AppBar "Kasir" and Search Bar
    expect(find.byType(PosAppBar), findsOneWidget);
    expect(find.text('Kasir'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);

    // 2. Verify Category Filter Bar and Grid Toggle Button
    expect(find.byType(CategoryFilterBar), findsOneWidget);
    expect(find.byIcon(Icons.grid_view), findsOneWidget);
    expect(find.text('Semua Menu'), findsOneWidget);
    expect(find.text('Croissant'), findsOneWidget);

    // 3. Verify Products Rendered
    expect(find.text('Butter Croissant'), findsOneWidget);
    expect(find.text('Pain au Chocolat'), findsOneWidget);

    // 4. Verify Floating Bottom Navigation Bar with Notch & FAB (+)
    expect(find.byType(CustomBottomNavBar), findsOneWidget);
    final navFabFinder = find.descendant(
      of: find.byType(CustomBottomNavBar),
      matching: find.byIcon(Icons.add),
    );
    expect(navFabFinder, findsOneWidget);
    expect(find.byIcon(Icons.storefront_outlined), findsOneWidget);
    expect(find.byIcon(Icons.layers_outlined), findsOneWidget);
    expect(find.byIcon(Icons.history_outlined), findsOneWidget);
    expect(find.byIcon(Icons.bar_chart_outlined), findsOneWidget);

    // 5. Tap Center FAB (+) to trigger Quick Management Modal
    await tester.tap(navFabFinder);
    await tester.pumpAndSettle();

    // 6. Verify QuickManagementModal (features/CRUD PRODUCT KATEGORY DELIVERY ON OF.png)
    expect(find.byType(QuickManagementModal), findsOneWidget);
    expect(find.text('Menu Manajemen Kasir'), findsOneWidget);
    expect(find.text('Kelola Produk'), findsOneWidget);
    expect(find.text('Kelola Kategori'), findsOneWidget);
    expect(find.text('Tipe Pesanan'), findsOneWidget);
    expect(find.text('Layanan Pengiriman'), findsOneWidget);
    expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);

    // 7. Tap Close button (✕) on Quick Management Modal
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.byType(QuickManagementModal), findsNothing);
  });
}
