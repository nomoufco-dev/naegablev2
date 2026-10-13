import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_naegable/core/di/providers.dart';
import 'package:pos_naegable/core/domain/entities/category_entity.dart';
import 'package:pos_naegable/core/domain/entities/product_entity.dart';
import 'package:pos_naegable/core/domain/repositories/category_repository.dart';
import 'package:pos_naegable/core/domain/repositories/product_repository.dart';
import 'package:pos_naegable/features/product_crud/presentation/screens/product_management_screen.dart';
import 'package:pos_naegable/features/category_crud/presentation/screens/category_management_screen.dart';

class _MockProductRepo implements ProductRepository {
  final List<ProductEntity> list = [
    const ProductEntity(
      id: 'p1', storeId: 's1',
      name: 'Dubai Chewy Cookie Dengan Nama Sangat Panjang Sekali',
      price: 28000.0, costPrice: 14000.0, currentStock: 50,
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
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _MockCategoryRepo implements CategoryRepository {
  @override
  Future<List<CategoryEntity>> getCategories() async => [];
  @override
  Future<void> saveCategory(CategoryEntity c) async {}
  @override
  Future<void> deleteCategory(String id) async {}
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

Future<void> _pumpAtPhoneSize(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(360 * 3, 640 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        productRepositoryProvider.overrideWithValue(_MockProductRepo()),
        categoryRepositoryProvider.overrideWithValue(_MockCategoryRepo()),
      ],
      child: MaterialApp(home: screen),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Daftar Produk tidak overflow', (tester) async {
    await _pumpAtPhoneSize(tester, const ProductManagementScreen());
    expect(tester.takeException(), isNull);
  });

  testWidgets('Kelola Kategori tidak overflow', (tester) async {
    await _pumpAtPhoneSize(tester, const CategoryManagementScreen());
    expect(tester.takeException(), isNull);
  });
}
