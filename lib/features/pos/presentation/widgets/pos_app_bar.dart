import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';

/// Top App Bar untuk layar Kasir yang mencerminkan secara visual
/// desain resmi pada `screens/HOME - KASIR PAGE TIPE 1.png` & `TIPE 2.png`.
class PosAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PosAppBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.cartItemCount,
    required this.onCartPressed,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final int cartItemCount;
  final VoidCallback onCartPressed;

  @override
  Size get preferredSize => const Size.fromHeight(116.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            6.0,
            AppSpacing.md,
            10.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Baris Judul "Kasir" - Rata Tengah Sesuai Desain Asli
              SizedBox(
                height: 36.0,
                child: Center(
                  child: Text(
                    'Kasir',
                    style: AppTypography.headerTitle.copyWith(
                      color: AppColors.surfaceWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 22.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6.0),

              // Baris Search Bar Putih Kapsul & Tombol Ikon Keranjang di Sebelah Kanannya
              Row(
                children: [
                  // Search Bar Stadium/Pill Putih Bersih dengan Ikon Kaca Pembesar di Kanan
                  Expanded(
                    child: Container(
                      height: 42.0,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4.0,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: onSearchChanged,
                        style: const TextStyle(
                          color: AppColors.noir,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Cari produk bakery...',
                          hintStyle: TextStyle(
                            color: Color(0xFF9E9E9E),
                            fontSize: 12.5,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 10.0,
                          ),
                          border: InputBorder.none,
                          suffixIcon: Icon(
                            Icons.search,
                            color: AppColors.noir,
                            size: 22.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),

                  // Ikon Keranjang Belanja Wireframe Warna Blush Pink di Sisi Kanan Search Bar
                  GestureDetector(
                    onTap: onCartPressed,
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: 42.0,
                      height: 42.0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.shopping_cart_outlined,
                            color: AppColors.accent, // Blush Pink #F5CBD7
                            size: 24.0,
                          ),
                          if (cartItemCount > 0)
                            Positioned(
                              right: 2,
                              top: 2,
                              child: Container(
                                padding: const EdgeInsets.all(3.0),
                                decoration: const BoxDecoration(
                                  color: AppColors.surfaceWhite,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16.0,
                                  minHeight: 16.0,
                                ),
                                child: Center(
                                  child: Text(
                                    cartItemCount > 99 ? '99+' : '$cartItemCount',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 9.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
