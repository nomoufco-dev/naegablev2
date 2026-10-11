import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../category_crud/presentation/screens/category_management_screen.dart';
import '../../../product_crud/presentation/screens/product_management_screen.dart';
import 'quick_management_modal.dart';

/// Bottom navigation utama aplikasi — dipakai di semua tab utama
/// (Kasir, Daftar Pesanan, Riwayat Transaksi, Laporan) agar navigasi
/// bawah selalu tampil konsisten di setiap halaman utama.
///
/// Catatan: Layar Kasir (/pos) memakai varian animasi morphing khusus
/// langsung di [PosScreen]; widget ini adalah versi standar untuk
/// tab utama lainnya dengan tampilan visual yang sama.
class MainBottomNav extends StatelessWidget {
  const MainBottomNav({super.key, required this.selectedIndex});

  /// 0 = Kasir, 1 = Daftar Pesanan, 2 = Riwayat Transaksi, 3 = Laporan
  final int selectedIndex;

  void _onItemSelected(BuildContext context, int index) {
    if (index == selectedIndex) return;
    switch (index) {
      case 0:
        context.go('/pos');
        break;
      case 1:
        context.go('/orders');
        break;
      case 2:
        context.go('/history');
        break;
      case 3:
        context.go('/reports');
        break;
    }
  }

  void _showQuickManagement(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => QuickManagementModal(
        onClose: () => Navigator.of(sheetContext).pop(),
        onNavigateToProductCrud: () {
          Navigator.of(sheetContext).pop();
          Navigator.of(sheetContext).push(
            MaterialPageRoute(builder: (_) => const ProductManagementScreen()),
          );
        },
        onNavigateToCategoryCrud: () {
          Navigator.of(sheetContext).pop();
          Navigator.of(sheetContext).push(
            MaterialPageRoute(builder: (_) => const CategoryManagementScreen()),
          );
        },
        onAddNewProduct: () {
          Navigator.of(sheetContext).pop();
          Navigator.of(sheetContext).push(
            MaterialPageRoute(builder: (_) => const ProductManagementScreen()),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Padding bawah mengikuti inset sistem (gesture bar / nav bar) agar
    // pill tidak tertutup bar sistem pada mode edge-to-edge.
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: CustomBottomNavBar(
        selectedIndex: selectedIndex,
        onItemSelected: (index) => _onItemSelected(context, index),
        onFabPressed: () => _showQuickManagement(context),
      ),
    );
  }
}
