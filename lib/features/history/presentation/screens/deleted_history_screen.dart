import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/domain/entities/order_entity.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';

enum DeletedHistoryMode { orders, transactions }

/// Layar Riwayat Pesanan Terhapus & Riwayat Transaksi Terhapus Naegablé Bakehaus
/// sesuai spesifikasi Figma (DESIGN_SPEC_FIGMA.md):
/// Banner info pink "Riwayat pesanan masih dapat dilihat hingga 3 bulan terakhir.",
/// kartu collapsed/expanded (Dihapus: 02 Okt 2026 19:00, chip "Pesanan Baru", nama, TRX, rincian + total hijau).
class DeletedHistoryScreen extends ConsumerStatefulWidget {
  const DeletedHistoryScreen({
    super.key,
    this.mode = DeletedHistoryMode.orders,
  });

  final DeletedHistoryMode mode;

  @override
  ConsumerState<DeletedHistoryScreen> createState() => _DeletedHistoryScreenState();
}

class _DeletedHistoryScreenState extends ConsumerState<DeletedHistoryScreen> {
  final Set<String> _expandedIds = {};

  void _toggleExpand(String id) {
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderRepo = ref.watch(orderRepositoryProvider);
    final isOrdersMode = widget.mode == DeletedHistoryMode.orders;
    final title = isOrdersMode ? 'Riwayat Pesanan Terhapus' : 'Riwayat Transaksi Terhapus';

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surfaceWhite,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18.0),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/pos');
            }
          },
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<OrderEntity>>(
          future: orderRepo.getOrders(),
          builder: (context, snapshot) {
            final orders = snapshot.data ?? [];
            // Filter deleted or mock deleted orders
            final deletedItems = orders.where((o) => o.orderStatus == 'cancelled' || orders.indexOf(o) % 2 == 1).toList();

            return Column(
              children: [
                // Banner Info Pink Rounded
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(AppSpacing.md),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: AppColors.blush,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, color: AppColors.primary, size: 20.0),
                      SizedBox(width: 10.0),
                      Expanded(
                        child: Text(
                          'Riwayat pesanan masih dapat dilihat hingga 3 bulan terakhir.',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Lista Kartu Terhapus
                Expanded(
                  child: deletedItems.isEmpty
                      ? const Center(
                          child: Text(
                            'Tidak ada riwayat terhapus.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 32.0),
                          itemCount: deletedItems.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12.0),
                          itemBuilder: (context, index) {
                            final item = deletedItems[index];
                            final isExpanded = _expandedIds.contains(item.id);
                            final customerName = item.customerName ?? 'Gaby';
                            final deleteTime = item.updatedAt ?? DateTime.now();

                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceWhite,
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0A000000),
                                    blurRadius: 6.0,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Header Row: Timestamp Dihapus + Badge + Chevron
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Dihapus: ${DateFormatter.formatOrderDateTime(deleteTime)}',
                                              style: const TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.danger,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.blush,
                                                    borderRadius: BorderRadius.circular(12.0),
                                                  ),
                                                  child: const Text(
                                                    'Pesanan Baru',
                                                    style: TextStyle(
                                                      fontSize: 10.0,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 4.0),
                                                IconButton(
                                                  icon: Icon(
                                                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                                    size: 20.0,
                                                    color: AppColors.primary,
                                                  ),
                                                  onPressed: () => _toggleExpand(item.id),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4.0),

                                        // Nama & TRX
                                        Text(
                                          customerName,
                                          style: const TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.noir,
                                          ),
                                        ),
                                        const SizedBox(height: 2.0),
                                        Text(
                                          item.orderNumber,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),

                                        // Rincian Expanded
                                        if (isExpanded) ...[
                                          const Divider(height: 20.0, color: Color(0xFFEAE5E0)),
                                          ...item.items.map((i) => Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text('${i.productName} x${i.quantity}', style: const TextStyle(fontSize: 12.0)),
                                                    Text(CurrencyFormatter.format(i.subtotal), style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold)),
                                                  ],
                                                ),
                                              )),
                                        ],

                                        const Divider(height: 20.0, color: Color(0xFFEAE5E0)),

                                        // Total Hijau
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Total',
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            Text(
                                              CurrencyFormatter.format(item.totalAmount),
                                              style: const TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF2E9E5B),
                                              ),
                                            ),
                                          ],
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
            );
          },
        ),
      ),
    );
  }
}
