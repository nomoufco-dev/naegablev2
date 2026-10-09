import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/domain/entities/order_entity.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../pos/presentation/controllers/pos_controller.dart';

/// Layar Daftar Pesanan Naegablé Bakehaus sesuai spesifikasi Figma (DESIGN_SPEC_FIGMA.md):
/// Header + search + ikon trash, kartu expandable (chip pink "Pesanan Baru",
/// nama pelanggan, TRX + ikon copy, tanggal & antrian, jadwal pengambilan, rincian item,
/// total pesanan, total hijau, tombol "Bayar" cokelat pill + menu ⋮ kotak putih di baris bawah).
class OrderListScreen extends ConsumerStatefulWidget {
  const OrderListScreen({super.key});

  @override
  ConsumerState<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends ConsumerState<OrderListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _expandedOrderIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleExpand(String id) {
    setState(() {
      if (_expandedOrderIds.contains(id)) {
        _expandedOrderIds.remove(id);
      } else {
        _expandedOrderIds.add(id);
      }
    });
  }

  void _copyTrxCode(String trxCode) {
    Clipboard.setData(ClipboardData(text: trxCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kode transaksi $trxCode berhasil disalin!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showActionSheet(BuildContext context, OrderEntity order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (bottomSheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36.0,
                  height: 4.0,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCDCDC),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_outlined, color: AppColors.primary),
                  title: const Text(
                    'Struk Pesanan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                  ),
                  onTap: () {
                    Navigator.of(bottomSheetCtx).pop();
                    _showOrderReceiptDialog(context, order);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel_outlined, color: AppColors.danger),
                  title: const Text(
                    'Batalkan Pesanan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: AppColors.danger,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(bottomSheetCtx).pop();
                    _confirmCancelOrder(context, order);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOrderReceiptDialog(BuildContext context, OrderEntity order) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
          title: Text(
            'Struk ${order.orderNumber}',
            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pelanggan: ${order.customerName ?? 'Gaby'}', style: const TextStyle(fontSize: 13.0)),
                Text('Tanggal: ${DateFormatter.formatOrderDateTime(order.createdAt ?? DateTime.now())}',
                    style: const TextStyle(fontSize: 12.0, color: AppColors.textSecondary)),
                const Divider(height: 16.0),
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item.productName} x${item.quantity}', style: const TextStyle(fontSize: 12.5)),
                          Text(CurrencyFormatter.format(item.subtotal), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )),
                const Divider(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                    Text(
                      CurrencyFormatter.format(order.totalAmount),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: Color(0xFF2E9E5B)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmCancelOrder(BuildContext context, OrderEntity order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: const Text('Batalkan Pesanan?', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Batalkan pesanan ${order.orderNumber}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Ya, Batalkan'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final repo = ref.read(orderRepositoryProvider);
      await repo.updateOrderStatus(order.id, 'cancelled');
      ref.invalidate(ordersListProvider);
      if (!mounted || !context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pesanan ${order.orderNumber} berhasil dibatalkan'),
            backgroundColor: AppColors.primary,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersListProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Daftar Pesanan'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.surfaceWhite),
            tooltip: 'Riwayat Pesanan Terhapus',
            onPressed: () => context.push('/deleted-orders'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Cari pesanan atau nama...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.surfaceWhite,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9999),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // List Order Cards
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                final query = _searchController.text.trim().toLowerCase();
                final filtered = orders.where((o) {
                  if (query.isEmpty) return true;
                  final matchNum = o.orderNumber.toLowerCase().contains(query);
                  final matchName = (o.customerName ?? '').toLowerCase().contains(query);
                  return matchNum || matchName;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada pesanan ditemukan.'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 32.0),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12.0),
                  itemBuilder: (context, index) {
                    final order = filtered[index];
                    return _buildExpandableOrderCard(order, index);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableOrderCard(OrderEntity order, int index) {
    final isExpanded = _expandedOrderIds.contains(order.id);
    final customerName = (order.customerName != null && order.customerName!.trim().isNotEmpty)
        ? order.customerName!
        : 'Gaby';
    final queueNumber = (index + 1).toString().padLeft(2, '0');
    final orderDateTime = order.createdAt ?? DateTime.now();
    final pickupDateTime = orderDateTime.add(const Duration(hours: 1));
    final isNewOrder = order.orderStatus != 'cancelled';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(18.0),
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
                // Header Baris: Chip "Pesanan Baru" & Chevron Expand (Tanpa ⋮)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: AppColors.blush,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        isNewOrder ? 'Pesanan Baru' : 'Pesanan Dibatalkan',
                        style: const TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      padding: const EdgeInsets.all(4.0),
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        size: 22.0,
                        color: AppColors.primary,
                      ),
                      onPressed: () => _toggleExpand(order.id),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),

                // Nama Pelanggan
                Text(
                  customerName,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.noir,
                  ),
                ),
                const SizedBox(height: 4.0),

                // TRX Number + Icon Copy
                Row(
                  children: [
                    Text(
                      order.orderNumber,
                      style: const TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    GestureDetector(
                      onTap: () => _copyTrxCode(order.orderNumber),
                      child: const Icon(
                        Icons.copy_outlined,
                        size: 16.0,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),

                // Tanggal & Antrian
                Text(
                  '${DateFormatter.formatOrderDateTime(orderDateTime)} - Antrian $queueNumber',
                  style: const TextStyle(
                    fontSize: 12.0,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6.0),

                // Jadwal Pengambilan
                Row(
                  children: [
                    Container(
                      width: 8.0,
                      height: 8.0,
                      decoration: const BoxDecoration(
                        color: AppColors.blush,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      'Jadwal Pengambilan: ${DateFormatter.formatOrderDateTime(pickupDateTime)}',
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                // Rincian Item (Accordion)
                if (isExpanded) ...[
                  const Divider(height: 20.0, color: Color(0xFFEAE5E0)),
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${item.productName} x${item.quantity}', style: const TextStyle(fontSize: 12.5)),
                            Text(CurrencyFormatter.format(item.subtotal), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Pesanan',
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.noir,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(order.totalAmount),
                        style: const TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.noir,
                        ),
                      ),
                    ],
                  ),
                ],

                const Divider(height: 20.0, color: Color(0xFFEAE5E0)),

                // Baris Total (Bold) / Nominal HIJAU Bold
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.noir,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(order.totalAmount),
                      style: const TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2E9E5B),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14.0),

                // Baris Bawah: [Tombol Bayar Cokelat Lebar] [Tombol Kotak Putih ⋮]
                Row(
                  children: [
                    if (isNewOrder)
                      Expanded(
                        child: SizedBox(
                          height: 44.0,
                          child: ElevatedButton(
                            onPressed: () {
                              context.push(
                                '/payment',
                                extra: {
                                  'totalAmount': order.totalAmount,
                                  'customerName': customerName,
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.surfaceWhite,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9999),
                              ),
                            ),
                            child: const Text(
                              'Bayar',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      const Spacer(),
                    const SizedBox(width: 10.0),
                    SizedBox(
                      width: 44.0,
                      height: 44.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: const Color(0xFFE5E5E5), width: 1.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 4.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showActionSheet(context, order),
                            borderRadius: BorderRadius.circular(12.0),
                            child: const Center(
                              child: Icon(
                                Icons.more_vert,
                                color: Colors.black,
                                size: 20.0,
                              ),
                            ),
                          ),
                        ),
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
  }
}