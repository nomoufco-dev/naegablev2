import 'package:flutter_test/flutter_test.dart';
import 'package:pos_naegable/core/database/database_constants.dart';
import 'package:pos_naegable/core/domain/entities/delivery_settings_entity.dart';
import 'package:pos_naegable/core/domain/entities/product_entity.dart';

void main() {
  group('SQLite Infrastructure & Domain Entities Unit Tests', () {
    test('DatabaseConstants contains valid table names and DDL statements', () {
      expect(DatabaseConstants.tableStores, 'stores');
      expect(DatabaseConstants.tableProducts, 'products');
      expect(DatabaseConstants.tableCategories, 'categories');
      expect(DatabaseConstants.tableDeliverySettings, 'delivery_settings');
      expect(DatabaseConstants.createProductsTable.contains('CREATE TABLE products'), isTrue);
    });

    test('ProductEntity copyWith updates properties correctly', () {
      const product = ProductEntity(
        id: 'test-1',
        storeId: 'store-1',
        name: 'Butter Croissant',
        price: 22000.0,
        currentStock: 10,
      );

      final updated = product.copyWith(price: 25000.0, currentStock: 15);

      expect(updated.id, 'test-1');
      expect(updated.price, 25000.0);
      expect(updated.currentStock, 15);
      expect(updated.name, 'Butter Croissant');
    });

    test('DeliverySettingsEntity handles toggle status', () {
      const settings = DeliverySettingsEntity(
        id: 'del-1',
        storeId: 'store-1',
        isDeliveryEnabled: true,
      );

      final disabled = settings.copyWith(isDeliveryEnabled: false);
      expect(disabled.isDeliveryEnabled, isFalse);
    });
  });
}
