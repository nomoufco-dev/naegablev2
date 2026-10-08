import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/domain/entities/product_entity.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Kartu Produk pada Katalog Kasir dengan dukungan Tipe 1 (Vertical Grid Card / CARD 1.png)
/// dan Tipe 2 (Horizontal Row Card / CARD 2.png), mencerminkan presisi visual desain resmi.
class ProductGridCard extends StatelessWidget {
  const ProductGridCard({
    super.key,
    required this.product,
    required this.quantityInCart,
    required this.onTap,
    this.isCompact = true,
  });

  final ProductEntity product;
  final int quantityInCart;
  final VoidCallback onTap;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = product.trackStock && product.currentStock <= 0;

    return RepaintBoundary(
      child: isCompact
          ? _buildVerticalGridCard(context, isOutOfStock)
          : _buildHorizontalListCard(context, isOutOfStock),
    );
  }

  /// Desain CARD 1: Vertical Grid Card
  Widget _buildVerticalGridCard(BuildContext context, bool isOutOfStock) {
    return InkWell(
      onTap: isOutOfStock ? null : onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: quantityInCart > 0 ? AppColors.accent : const Color(0xFFEAE5E0),
            width: quantityInCart > 0 ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar Produk Bakery dengan Sudut Membulat (12px)
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F3EE),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: _buildProductImage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6.0),

                  // Judul Produk
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: isOutOfStock ? AppColors.textSecondary : AppColors.noir,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 2.0),

                  // Indikator Stok Hijau Neon (Stock: 100) persis CARD 1.png
                  Text(
                    isOutOfStock ? 'Habis' : 'Stock: ${product.currentStock}',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: isOutOfStock ? AppColors.danger : AppColors.stockGreen,
                    ),
                  ),
                  const SizedBox(height: 2.0),

                  // Harga Produk Hitam Pekat Sesuai Desain CARD 1.png
                  Text(
                    CurrencyFormatter.format(product.price),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: isOutOfStock ? AppColors.textSecondary : AppColors.noir,
                    ),
                  ),
                  const SizedBox(height: 6.0),

                  // Tombol Aksi Full Width Pill Brown "add to chart" persis CARD 1.png
                  Container(
                    width: double.infinity,
                    height: 26.0,
                    decoration: BoxDecoration(
                      color: isOutOfStock
                          ? const Color(0xFFD6D1CB)
                          : AppColors.primary, // Deep Chocolate Brown #442F2A
                      borderRadius: BorderRadius.circular(9999), // pill shape
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'add to chart',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Badge Jumlah di Keranjang - Kiri Atas
            if (quantityInCart > 0)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7.0,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(9999),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 4.0,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    '$quantityInCart',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Desain CARD 2: Horizontal Row Card
  Widget _buildHorizontalListCard(BuildContext context, bool isOutOfStock) {
    return InkWell(
      onTap: isOutOfStock ? null : onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: quantityInCart > 0 ? AppColors.accent : const Color(0xFFEAE5E0),
            width: quantityInCart > 0 ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail Kiri Persegi Sudut Membulat 12px
            Stack(
              children: [
                Container(
                  width: 82.0,
                  height: 82.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F3EE),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: _buildProductImage(),
                  ),
                ),
                // Badge lingkaran blush pink di sudut kanan atas thumbnail
                if (quantityInCart > 0)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 20.0,
                      height: 20.0,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$quantityInCart',
                        style: const TextStyle(
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12.0),

            // Kolom Tengah: Judul, Stok Hijau, Harga
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: isOutOfStock ? AppColors.textSecondary : AppColors.noir,
                    ),
                  ),
                  const SizedBox(height: 3.0),
                  Text(
                    isOutOfStock ? 'Habis' : 'Stock: ${product.currentStock}',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isOutOfStock ? AppColors.danger : AppColors.stockGreen,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  // Harga Hitam Pekat Sesuai Desain CARD 2.png
                  Text(
                    CurrencyFormatter.format(product.price),
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: isOutOfStock ? AppColors.textSecondary : AppColors.noir,
                    ),
                  ),
                ],
              ),
            ),

            // Tombol add kanan bawah - Pill Brown "add to chart" persis CARD 2.png
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0),
                  decoration: BoxDecoration(
                    color: isOutOfStock
                        ? const Color(0xFFD6D1CB)
                        : AppColors.primary, // Deep Chocolate Brown #442F2A
                    borderRadius: BorderRadius.circular(9999),
                    boxShadow: isOutOfStock ? null : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 6.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'add to chart',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    final assetPath = product.imageUrl ?? AppAssets.dubaiChewyCookie;
    return Image.asset(
      assetPath,
      cacheWidth: 320,
      cacheHeight: 320,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Icon(
            _getBakeryIcon(product.name),
            size: 36.0,
            color: AppColors.primary,
          ),
        );
      },
    );
  }

  IconData _getBakeryIcon(String productName) {
    final lower = productName.toLowerCase();
    if (lower.contains('cookie') || lower.contains('chewy')) return Icons.cookie_outlined;
    if (lower.contains('croissant')) return Icons.bakery_dining;
    if (lower.contains('chocolat') || lower.contains('chocolate') || lower.contains('brownie')) {
      return Icons.cake_outlined;
    }
    if (lower.contains('sourdough') || lower.contains('loaf') || lower.contains('bread')) {
      return Icons.breakfast_dining;
    }
    if (lower.contains('coffee') || lower.contains('latte') || lower.contains('tea')) {
      return Icons.local_cafe_outlined;
    }
    return Icons.lunch_dining_outlined;
  }
}
