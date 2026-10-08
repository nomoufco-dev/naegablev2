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
import 'package:pos_naegable/features/pos/presentation/controllers/cart_controller.dart';
import 'package:pos_naegable/features/pos/presentation/controllers/pos_controller.dart';
import 'package:pos_naegable/features/pos/presentation/screens/pos_screen.dart';
import 'package:pos_naegable/features/pos/presentation/widgets/quick_management_modal.dart';
import 'package:pos_naegable/features/splash/presentation/screens/splash_screen.dart';

class MockProductRepo implements ProductRepository {
  final List<ProductEntity> list = [
    const ProductEntity(
      id: 'p1',
      storeId: 's1',
      name: 'Dubai Chewy Cookie',
      price: 28000.0,
      currentStock: 100,
    ),
    const ProductEntity(
      id: 'p2',
      storeId: 's1',
      name: 'Dubai Chewy Cookie',
      price: 28000.0,
      currentStock: 100,
    ),
    const ProductEntity(
      id: 'p3',
      storeId: 's1',
      name: 'Dubai Chewy Cookie',
      price: 28000.0,
      currentStock: 100,
    ),
  ];

  @override
  Future<void> deleteProduct(String id) async {}
  @override
  Future<ProductEntity?> getProductById(String id) async => list.first;
  @override
  Future<List<ProductEntity>> getProducts({String? categoryId, String? searchQuery}) async => list;
  @override
  Future<void> saveProduct(ProductEntity product) async {}
  @override
  Future<void> updateStock(String id, int quantityDelta) async {}
}

class MockCategoryRepo implements CategoryRepository {
  @override
  Future<void> deleteCategory(String id) async {}
  @override
  Future<List<CategoryEntity>> getCategories() async => [
    const CategoryEntity(id: 'c1', storeId: 's1', name: 'Dubai Chewy Cookie', slug: 'dubai-chewy-cookie'),
    const CategoryEntity(id: 'c2', storeId: 's1', name: 'Soft Cookies', slug: 'soft-cookies'),
    const CategoryEntity(id: 'c3', storeId: 's1', name: 'Fudgy Brownies', slug: 'fudgy-brownies'),
  ];
  @override
  Future<CategoryEntity?> getCategoryById(String id) async => null;
  @override
  Future<void> saveCategory(CategoryEntity category) async {}
}

class MockDeliveryRepo implements DeliverySettingsRepository {
  @override
  Future<DeliverySettingsEntity> getSettings() async => const DeliverySettingsEntity(
    id: 'd1', storeId: 's1', isDeliveryEnabled: true,
  );
  @override
  Future<void> toggleDeliveryStatus(bool isEnabled) async {}
  @override
  Future<void> updateSettings(DeliverySettingsEntity settings) async {}
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
  Future<Map<String, dynamic>> getSalesSummary() async => {};
}

void main() {
  const phoneSize = Size(412, 892);

  testWidgets('1. Golden Splash Screen', (WidgetTester tester) async {
    tester.view.physicalSize = phoneSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
    await expectLater(
      find.byType(SplashScreen),
      matchesGoldenFile('goldens/01_splash_screen.png'),
    );
  });

  testWidgets('2. Golden Bottom Nav Upward Dome (nav 1.png)', (WidgetTester tester) async {
    tester.view.physicalSize = phoneSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(MockProductRepo()),
          categoryRepositoryProvider.overrideWithValue(MockCategoryRepo()),
          deliverySettingsRepositoryProvider.overrideWithValue(MockDeliveryRepo()),
          orderRepositoryProvider.overrideWithValue(MockOrderRepo()),
          selectedCategoryIdProvider.overrideWith((ref) => 'c1'),
        ],
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: PosScreen(),
        ),
      ),
    );
    await tester.pump();
    await expectLater(
      find.byType(PosScreen),
      matchesGoldenFile('goldens/02_nav_shape_dome.png'),
    );
  });

  testWidgets('3. Golden KERANJANG PRIVEW 1 (Collapsed)', (WidgetTester tester) async {
    tester.view.physicalSize = phoneSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final productRepo = MockProductRepo();
    final container = ProviderContainer(
      overrides: [
        productRepositoryProvider.overrideWithValue(productRepo),
        categoryRepositoryProvider.overrideWithValue(MockCategoryRepo()),
        deliverySettingsRepositoryProvider.overrideWithValue(MockDeliveryRepo()),
        orderRepositoryProvider.overrideWithValue(MockOrderRepo()),
        selectedCategoryIdProvider.overrideWith((ref) => 'c1'),
      ],
    );
    container.read(cartProvider.notifier).addItem(productRepo.list[0]);
    container.read(cartProvider.notifier).addItem(productRepo.list[0]);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: PosScreen(),
        ),
      ),
    );
    await tester.pump();
    await expectLater(
      find.byType(PosScreen),
      matchesGoldenFile('goldens/03_keranjang_preview_1.png'),
    );
  });

  testWidgets('4. Golden KERANJANG PRIVEW 2 (Expanded)', (WidgetTester tester) async {
    tester.view.physicalSize = phoneSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final productRepo = MockProductRepo();
    final container = ProviderContainer(
      overrides: [
        productRepositoryProvider.overrideWithValue(productRepo),
        categoryRepositoryProvider.overrideWithValue(MockCategoryRepo()),
        deliverySettingsRepositoryProvider.overrideWithValue(MockDeliveryRepo()),
        orderRepositoryProvider.overrideWithValue(MockOrderRepo()),
        selectedCategoryIdProvider.overrideWith((ref) => 'c1'),
      ],
    );
    container.read(cartProvider.notifier).addItem(productRepo.list[0]);
    container.read(cartProvider.notifier).addItem(productRepo.list[0]);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: PosScreen(),
        ),
      ),
    );
    await tester.pump();

    // Tap chevron to expand
    await tester.tap(find.byIcon(Icons.keyboard_arrow_up));
    await tester.pump();

    await expectLater(
      find.byType(PosScreen),
      matchesGoldenFile('goldens/04_keranjang_preview_2.png'),
    );
  });

  testWidgets('5. Golden CRUD OPEN MENU (Kelola Sistem)', (WidgetTester tester) async {
    tester.view.physicalSize = phoneSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          deliverySettingsRepositoryProvider.overrideWithValue(MockDeliveryRepo()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: const Color(0x73000000), // Dimmed modal overlay
            body: Center(
              child: QuickManagementModal(
                onNavigateToProductCrud: () {},
                onNavigateToCategoryCrud: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/05_crud_open_menu.png'),
    );
  });

  testWidgets('6. Golden Bottom Nav Concave Cradle when + Clicked (nav 2.png)', (WidgetTester tester) async {
    tester.view.physicalSize = phoneSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SizedBox(),
          bottomNavigationBar: CustomBottomNavBar(
            isCloseState: true,
          ),
        ),
      ),
    );
    await tester.pump();
    await expectLater(
      find.byType(CustomBottomNavBar),
      matchesGoldenFile('goldens/06_nav_2_concave_cradle.png'),
    );
  });
}
