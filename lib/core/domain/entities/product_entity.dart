/// Entitas murni Product untuk lapisan domain bisnis.
/// Independen dari SQLite maupun Supabase.
class ProductEntity {
  const ProductEntity({
    required this.id,
    required this.storeId,
    required this.name,
    required this.price,
    this.categoryId,
    this.sku,
    this.barcode,
    this.description,
    this.imageUrl,
    this.costPrice = 0.0,
    this.trackStock = true,
    this.currentStock = 0,
    this.minimumStock = 5,
    this.isAvailable = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String storeId;
  final String? categoryId;
  final String? sku;
  final String? barcode;
  final String name;
  final String? description;
  final String? imageUrl;
  final double price;
  final double costPrice;
  final bool trackStock;
  final int currentStock;
  final int minimumStock;
  final bool isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductEntity copyWith({
    String? id,
    String? storeId,
    String? categoryId,
    String? sku,
    String? barcode,
    String? name,
    String? description,
    String? imageUrl,
    double? price,
    double? costPrice,
    bool? trackStock,
    int? currentStock,
    int? minimumStock,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      categoryId: categoryId ?? this.categoryId,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      trackStock: trackStock ?? this.trackStock,
      currentStock: currentStock ?? this.currentStock,
      minimumStock: minimumStock ?? this.minimumStock,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
