/// Entitas murni Delivery Settings untuk pengaturan pengiriman toko.
class DeliverySettingsEntity {
  const DeliverySettingsEntity({
    required this.id,
    required this.storeId,
    this.isDeliveryEnabled = true,
    this.deliveryFeeBase = 10000.0,
    this.minimumOrderAmount = 30000.0,
    this.maxDeliveryRadiusKm = 5.0,
    this.updatedBy,
    this.updatedAt,
  });

  final String id;
  final String storeId;
  final bool isDeliveryEnabled;
  final double deliveryFeeBase;
  final double minimumOrderAmount;
  final double maxDeliveryRadiusKm;
  final String? updatedBy;
  final DateTime? updatedAt;

  DeliverySettingsEntity copyWith({
    String? id,
    String? storeId,
    bool? isDeliveryEnabled,
    double? deliveryFeeBase,
    double? minimumOrderAmount,
    double? maxDeliveryRadiusKm,
    String? updatedBy,
    DateTime? updatedAt,
  }) {
    return DeliverySettingsEntity(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      isDeliveryEnabled: isDeliveryEnabled ?? this.isDeliveryEnabled,
      deliveryFeeBase: deliveryFeeBase ?? this.deliveryFeeBase,
      minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
      maxDeliveryRadiusKm: maxDeliveryRadiusKm ?? this.maxDeliveryRadiusKm,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
