import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/utils/currency_formatter.dart';

import 'package:pos_naegable/features/pos/presentation/controllers/pos_controller.dart';

import '../../../pos/presentation/widgets/main_bottom_nav.dart';

final salesSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // Watch ordersListProvider so report refreshes automatically when orders change
  ref.watch(ordersListProvider);
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getSalesSummary();
});

/// Layar Laporan & Statistik Toko Naegablé Bakehaus.
///
/// Desain mengikuti Figma "iPhone 17 - 22" (node 205:1249) secara presisi:
/// header cokelat h=110, kartu hero cokelat, dua kartu metrik putih,
/// kartu distribusi produk dengan progress bar blush.
class SalesReportScreen extends ConsumerWidget {
  const SalesReportScreen({super.key});

  void _onBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/pos');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(salesSummaryProvider);
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // --- Header cokelat (Figma: h=110, judul di y=65) ---
          Container(
            height: 110.0,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: Color(0x80000000),
                  blurRadius: 4.0,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 15.0,
                  top: statusBarHeight + 11.0,
                  child: GestureDetector(
                    onTap: () => _onBack(context),
                    behavior: HitTestBehavior.opaque,
                    child: SvgPicture.asset(
                      AppAssets.iconChevronLeft,
                      width: 24.0,
                      height: 24.0,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: statusBarHeight + 11.0,
                  child: const Center(
                    child: Text(
                      'Laporan & Statistik',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'PlusJakartaSans',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- Konten ---
          Expanded(
            child: summaryAsync.when(
              data: (summary) {
                final totalOrders = summary['total_orders'] as int? ?? 0;
                final totalRevenue =
                    (summary['total_revenue'] as num?)?.toDouble() ?? 0.0;
                final totalItemsSold =
                    summary['total_items_sold'] as int? ?? 0;
                final averageOrder =
                    (summary['average_order_value'] as num?)?.toDouble() ?? 0.0;
                final productSales =
                    (summary['product_sales'] as Map<String, dynamic>?) ?? {};

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kartu hero cokelat (Figma: w=372 r=20)
                      // Tinggi mengikuti konten agar tidak overflow saat teks wrap
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x80000000),
                              blurRadius: 4.0,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Pendapatan Toko',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                color: AppColors.blush,
                                fontFamily: 'PlusJakartaSans',
                              ),
                            ),
                            const SizedBox(height: 15.0),
                            Text(
                              CurrencyFormatter.format(totalRevenue),
                              style: const TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: 'PlusJakartaSans',
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            Text(
                              '$totalOrders Transaksi Berhasil - $totalItemsSold Produk Terjual',
                              style: const TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                fontFamily: 'PlusJakartaSans',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // Dua kartu metrik putih (Figma: w=181 h=79 r=20)
                      Row(
                        children: [
                          Expanded(
                            child: _MetricCard(
                              label: 'Total Transaksi',
                              value: '$totalOrders',
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: _MetricCard(
                              label: 'Rata-rata Order',
                              value: CurrencyFormatter.format(averageOrder),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15.0),

                      // Judul seksi distribusi (Figma: 16px bold hitam)
                      const Text(
                        'Distribusi Produk Terjual',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          fontFamily: 'PlusJakartaSans',
                        ),
                      ),
                      const SizedBox(height: 8.0),

                      // Kartu distribusi putih (Figma: r=20, bar blush h=4)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 15.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x80000000),
                              blurRadius: 4.0,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                        child: productSales.isEmpty
                            ? const Center(
                                child: Text(
                                  'Belum ada data produk terjual.',
                                  style: AppTypography.caption,
                                ),
                              )
                            : Column(
                                children: _buildDistributionRows(productSales),
                              ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const MainBottomNav(selectedIndex: 3),
    );
  }

  List<Widget> _buildDistributionRows(Map<String, dynamic> productSales) {
    final maxVal = productSales.values.fold<int>(
      1,
      (max, v) => (v as int) > max ? v : max,
    );
    final entries = productSales.entries.toList();
    final widgets = <Widget>[];
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final ratio = (entry.value as int) / maxVal;
      widgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
                Text(
                  '${entry.value} pcs',
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6.0),
            // Progress bar blush (Figma: h=4, r=20, w penuh=342)
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 4.0,
                backgroundColor: const Color(0xFFF0EBE7),
                color: AppColors.blush,
              ),
            ),
          ],
        ),
      );
      if (i < entries.length - 1) {
        widgets.add(const SizedBox(height: 14.0));
      }
    }
    return widgets;
  }
}

/// Kartu metrik kecil putih (Figma: label 14px medium abu, nilai 16px bold hitam).
class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 4.0,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: Color(0x80000000),
              fontFamily: 'PlusJakartaSans',
            ),
          ),
          const SizedBox(height: 13.0),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              fontFamily: 'PlusJakartaSans',
            ),
          ),
        ],
      ),
    );
  }
}
