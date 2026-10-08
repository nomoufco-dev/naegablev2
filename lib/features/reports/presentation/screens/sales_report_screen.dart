import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/utils/currency_formatter.dart';
import 'package:pos_naegable/features/pos/presentation/controllers/pos_controller.dart';

final salesSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // Watch ordersListProvider so report refreshes automatically when orders change
  ref.watch(ordersListProvider);
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getSalesSummary();
});

/// Layar Laporan Penjualan & Statistik Toko Naegablé Bakehaus.
class SalesReportScreen extends ConsumerWidget {
  const SalesReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(salesSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Laporan & Statistik'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnDark,
        automaticallyImplyLeading: false,
      ),
      body: summaryAsync.when(
        data: (summary) {
          final totalOrders = summary['total_orders'] as int? ?? 0;
          final totalRevenue = (summary['total_revenue'] as num?)?.toDouble() ?? 0.0;
          final totalItemsSold = summary['total_items_sold'] as int? ?? 0;
          final averageOrder = (summary['average_order_value'] as num?)?.toDouble() ?? 0.0;
          final productSales = (summary['product_sales'] as Map<String, dynamic>?) ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Total Omzet
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(18.0),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 10.0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOTAL PENDAPATAN TOKO',
                        style: TextStyle(
                          fontSize: 11.5,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        CurrencyFormatter.format(totalRevenue),
                        style: const TextStyle(
                          fontSize: 26.0,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textOnDark,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        '$totalOrders Transaksi Berhasil • $totalItemsSold Produk Terjual',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: AppColors.textOnDark.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Grid 2 Metrik Kartu (Total Transaksi & AOV)
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Total Transaksi',
                        value: '$totalOrders',
                        icon: Icons.receipt_long,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Rata-rata Order',
                        value: CurrencyFormatter.format(averageOrder),
                        icon: Icons.analytics_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Penjualan Terbanyak (Top Products)
                const Text(
                  'Distribusi Produk Terjual',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.noir,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),

                if (productSales.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    child: const Center(
                      child: Text(
                        'Belum ada data produk terjual.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(14.0),
                      border: Border.all(color: const Color(0xFFE2DDD7)),
                    ),
                    child: Column(
                      children: productSales.entries.map((entry) {
                        final maxVal = productSales.values.fold<int>(1, (max, v) => v > max ? v : max);
                        final ratio = (entry.value as int) / maxVal;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.noir,
                                    ),
                                  ),
                                  Text(
                                    '${entry.value} pcs',
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4.0),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4.0),
                                child: LinearProgressIndicator(
                                  value: ratio,
                                  minHeight: 8.0,
                                  backgroundColor: const Color(0xFFF0EBE7),
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: const Color(0xFFE2DDD7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22.0),
          const SizedBox(height: 8.0),
          Text(
            title,
            style: const TextStyle(fontSize: 11.0, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2.0),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: AppColors.noir,
            ),
          ),
        ],
      ),
    );
  }
}
