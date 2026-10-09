import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/domain/entities/order_entity.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';

enum DeletedHistoryMode { orders, transactions }

/// Layar Riwayat Pesanan Terhapus & Riwayat Transaksi Terhapus Naegablé Bakehaus
/// Ditata dengan nuansa visual LoginScreen (Background cokelat AppColors.primary,
/// kartu putih rounded 28.0, chip blush #F5CBD7 rounded-full).
class DeletedHistoryScreen extends ConsumerStatefulWidget {
  const DeletedHistoryScreen({
    super.key,
    this.mode = DeletedHistoryMode.orders,
  });

  final DeletedHistoryMode mode;

  @override
  ConsumerState<DeletedHistoryScreen> createState() =>
      _DeletedHistoryScreenState();
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
    final title = isOrdersMode
        ? 'Riwayat Pesanan Terhapus'
        : 'Riwayat Transaksi Terhapus';

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // Header Top Bar Cokelat Tua (AppColors.primary)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.surfaceWhite,
                        size: 20.0,
                      ),
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          context.go('/pos');
                        }
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.surfaceWhite,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),

            // Banner Info Pink (Blush #F5CBD7) 3 Bulan
            Container(
              width: double.infinity,
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: AppColors.blush,
                borderRadius: BorderRadius.circular(9999),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 6.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline,
                      color: AppColors.primary, size: 20.0),
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
            const SizedBox(height: 8.0),

            // Konten Daftar Riwayat Terhapus (FutureBuilder)
            Expanded(
              child: FutureBuilder<List<OrderEntity>>(
                future: orderRepo.getOrders(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.surfaceWhite),
                    );
                  }

                  final orders = snapshot.data ?? [];
                  // HAPUS logika mock: hanya tampilkan order yang benar-benar status cancelled
                  // DAN belum kedaluwarsa 3 bulan (pakai updatedAt ?? createdAt)
                  final deletedItems = orders.where((o) {
                    if (o.orderStatus != 'cancelled') return false;
                    final deleteTime = o.updatedAt ?? o.createdAt;
                    if (deleteTime == null) return true;
                    return DateFormatter.isWithin3Months(deleteTime);
                  }).toList();

                  if (deletedItems.isEmpty) {
                    return Center(
                      child: Container(
                        margin: const EdgeInsets.all(24.0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 32.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(28.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x2B000000),
                              blurRadius: 16.0,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Tidak ada riwayat terhapus.',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 32.0),
                    itemCount: deletedItems.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 14.0),
                    itemBuilder: (context, index) {
                      final item = deletedItems[index];
                      final isExpanded = _expandedIds.contains(item.id);
                      final customerName = item.customerName ?? 'Gaby';
                      final deleteTime =
                          item.updatedAt ?? item.createdAt ?? DateTime.now();

                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(28.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x2B000000),
                              blurRadius: 16.0,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20.0),
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
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                        vertical: 4.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.blush,
                                        borderRadius:
                                            BorderRadius.circular(9999),
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
                                        isExpanded
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
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
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
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
                              const Divider(
                                height: 20.0,
                                color: Color(0xFFEAE5E0),
                              ),
                              ...item.items.map((i) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${i.productName} x${i.quantity}',
                                          style: const TextStyle(
                                            fontSize: 12.0,
                                            color: AppColors.noir,
                                          ),
                                        ),
                                        Text(
                                          CurrencyFormatter.format(i.subtotal),
                                          style: const TextStyle(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.noir,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],

                            const Divider(
                              height: 20.0,
                              color: Color(0xFFEAE5E0),
                            ),

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
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}