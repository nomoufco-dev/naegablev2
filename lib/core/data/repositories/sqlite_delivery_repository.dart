import '../../domain/entities/delivery_settings_entity.dart';
import '../../domain/repositories/delivery_settings_repository.dart';
import '../datasources/sqlite_delivery_datasource.dart';

/// Implementasi DeliverySettingsRepository berbasis database SQLite.
class SqliteDeliveryRepository implements DeliverySettingsRepository {
  SqliteDeliveryRepository(this._datasource);

  final SqliteDeliveryDatasource _datasource;

  @override
  Future<DeliverySettingsEntity> getSettings() async {
    final row = await _datasource.fetchDeliverySettings();
    if (row == null) {
      return const DeliverySettingsEntity(
        id: 'delivery-default',
        storeId: 'store-main-001',
      );
    }
    return _mapRowToEntity(row);
  }

  @override
  Future<void> toggleDeliveryStatus(bool isEnabled) async {
    await _datasource.updateDeliveryStatus(isEnabled);
  }

  @override
  Future<void> updateSettings(DeliverySettingsEntity settings) async {
    await _datasource.saveDeliverySettings(_mapEntityToRow(settings));
  }

  DeliverySettingsEntity _mapRowToEntity(Map<String, dynamic> row) {
    return DeliverySettingsEntity(
      id: row['id'] as String,
      storeId: row['store_id'] as String,
      isDeliveryEnabled: (row['is_delivery_enabled'] as int?) == 1,
      deliveryFeeBase: (row['delivery_fee_base'] as num?)?.toDouble() ?? 10000.0,
      minimumOrderAmount: (row['minimum_order_amount'] as num?)?.toDouble() ?? 30000.0,
      maxDeliveryRadiusKm: (row['max_delivery_radius_km'] as num?)?.toDouble() ?? 5.0,
      updatedBy: row['updated_by'] as String?,
      updatedAt: row['updated_at'] != null ? DateTime.tryParse(row['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> _mapEntityToRow(DeliverySettingsEntity entity) {
    final now = DateTime.now().toIso8601String();
    return {
      'id': entity.id,
      'store_id': entity.storeId,
      'is_delivery_enabled': entity.isDeliveryEnabled ? 1 : 0,
      'delivery_fee_base': entity.deliveryFeeBase,
      'minimum_order_amount': entity.minimumOrderAmount,
      'max_delivery_radius_km': entity.maxDeliveryRadiusKm,
      'updated_by': entity.updatedBy,
      'updated_at': now,
    };
  }
}
