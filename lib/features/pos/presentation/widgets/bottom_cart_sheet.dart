import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../controllers/cart_controller.dart';

/// Floating Cart Summary Bar yang melayang tepat di atas Bottom Navigation Bar,
/// mencerminkan secara presisi visual `KERANJANG PRIVEW 1.png` (Collapsed)
/// dan `KERANJANG PRIVEW 2.png` (Expanded).
class BottomCartSheet extends StatefulWidget {
  const BottomCartSheet({
    super.key,
    required this.cartState,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onCheckout,
    required this.onOrderTypeChanged,
    this.onClearCart,
  });

  final CartState cartState;
  final ValueChanged<String> onIncrement;
  final ValueChanged<String> onDecrement;
  final ValueChanged<String> onRemove;
  final VoidCallback onCheckout;
  final ValueChanged<String> onOrderTypeChanged;
  final VoidCallback? onClearCart;

  @override
  State<BottomCartSheet> createState() => _BottomCartSheetState();
}

class _BottomCartSheetState extends State<BottomCartSheet> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.cartState.isEmpty) {
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite, // Pure White (#FFFFFF)
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(color: const Color(0xFFEAE5E0), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16.0,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── 1. Baris Ringkasan Cart (KERANJANG PRIVEW 1 & 2) ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    // Ikon Lingkaran Blush Pink dengan Chevron Up/Down
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 42.0,
                        height: 42.0,
                        decoration: const BoxDecoration(
                          color: AppColors.accent, // Blush Pink #F5CBD7
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_up,
                          color: AppColors.primary, // Dark Chocolate Brown #442F2A
                          size: 24.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),

                    // Keterangan Jumlah Item dan Total Rupiah
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${widget.cartState.totalQuantity} Items',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF757575),
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(widget.cartState.grandTotal),
                              style: const TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.noir,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Tombol Kapsul Checkout Cokelat Gelap
                    GestureDetector(
                      onTap: widget.onCheckout,
                      child: Container(
                        height: 40.0,
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        decoration: BoxDecoration(
                          color: AppColors.primary, // Deep Chocolate Brown #442F2A
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Checkout (${widget.cartState.items.length})',
                          style: const TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── 2. Bagian Expanded: Preview Item Persis Desain KERANJANG PRIVEW 2.png ──
              if (_isExpanded) ...[
                const Divider(height: 1.0, thickness: 1.0, color: Color(0xFFF2ECE6)),
                const SizedBox(height: 6.0),

                // Tombol "Kosongkan Keranjang" di sisi kanan
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        widget.onClearCart?.call();
                        setState(() {
                          _isExpanded = false;
                        });
                      },
                      child: const Text(
                        'Kosongkan Keranjang',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.noir,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6.0),

                // Kartu Item Terpilih (Sesuai KERANJANG PRIVEW 2.png)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 180.0),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 10.0),
                    itemCount: widget.cartState.items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8.0),
                    itemBuilder: (context, index) {
                      final item = widget.cartState.items[index];
                      return Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(color: const Color(0xFFEAE5E0), width: 1.0),
                        ),
                        child: Row(
                          children: [
                            // Thumbnail Produk
                            Container(
                              width: 54.0,
                              height: 54.0,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F3EE),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.asset(
                                  item.product.imageUrl ?? AppAssets.dubaiChewyCookie,
                                  cacheWidth: 150,
                                  cacheHeight: 150,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Center(
                                    child: Icon(
                                      Icons.cookie_outlined,
                                      size: 26.0,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12.0),

                            // Nama & Total Harga Item
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    item.product.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.noir,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    CurrencyFormatter.format(item.subtotal),
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.noir,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Kontrol Kuantitas Ringan & Tombol add to chart
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () => widget.onDecrement(item.product.id),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                                      child: Icon(
                                        Icons.remove,
                                        size: 16.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                    child: Text(
                                      '${item.quantity}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => widget.onIncrement(item.product.id),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                                      child: Icon(
                                        Icons.add,
                                        size: 16.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
