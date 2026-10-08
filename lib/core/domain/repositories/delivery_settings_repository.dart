import '../entities/delivery_settings_entity.dart';

/// Kontrak abstraksi repositori pengaturan delivery.
abstract interface class DeliverySettingsRepository {
  /// Mengambil pengaturan delivery aktif toko.
  Future<DeliverySettingsEntity> getSettings();

  /// Mengubah status aktif layanan delivery (ON / OFF).
  Future<void> toggleDeliveryStatus(bool isEnabled);

  /// Memperbarui seluruh konfigurasi delivery toko.
  Future<void> updateSettings(DeliverySettingsEntity settings);
}
