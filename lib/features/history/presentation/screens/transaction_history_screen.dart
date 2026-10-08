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
import 'package:pos_naegable/features/pos/presentation/controllers/pos_controller.dart';

/// Layar Daftar Pesanan & Riwayat Transaksi POS Naegablé Bakehaus.
/// Mencerminkan secara visual desain resmi pada `screens/daftar pesanan - history pesanan.png`.
class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 0; // 0: Pesanan, 1: Pesanan Dibatalkan
  final Set<String> _expandedOrderIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleExpanded(String orderId) {
    setState(() {
      if (_expandedOrderIds.contains(orderId)) {
        _expandedOrderIds.remove(orderId);
      } else {
        _expandedOrderIds.add(orderId);
      }
    });
  }

  void _showOrderReceipt(BuildContext context, OrderEntity order) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bukti Struk Transaksi',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  order.orderType.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10.0,
                    color: AppColors.textOnDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.orderNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.0,
                  ),
                ),
                Text(
                  DateFormatter.formatOrderDateTime(
                    order.createdAt ?? DateTime.now(),
                  ),
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (order.customerName != null &&
                    order.customerName!.isNotEmpty) ...[
                  const SizedBox(height: 4.0),
                  Text(
                    'Pelanggan: ${order.customerName}',
                    style: const TextStyle(fontSize: 12.0),
                  ),
                ],
                const Divider(height: 16.0),
                ...order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.productName} x${item.quantity}',
                            style: const TextStyle(fontSize: 12.0),
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(item.subtotal),
                          style: const TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal', style: TextStyle(fontSize: 12.0)),
                    Text(
                      CurrencyFormatter.format(order.subtotal),
                      style: const TextStyle(fontSize: 12.0),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pajak PB1 (10%)',
                        style: TextStyle(fontSize: 12.0)),
                    Text(
                      CurrencyFormatter.format(order.taxAmount),
                      style: const TextStyle(fontSize: 12.0),
                    ),
                  ],
                ),
                if (order.deliveryFee > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ongkir Delivery',
                          style: TextStyle(fontSize: 12.0)),
                      Text(
                        CurrencyFormatter.format(order.deliveryFee),
                        style: const TextStyle(fontSize: 12.0),
                      ),
                    ],
                  ),
                const Divider(height: 12.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      CurrencyFormatter.format(order.totalAmount),
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
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

  Future<void> _confirmCancelOrder(
      BuildContext context, OrderEntity order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text(
            'Batalkan Pesanan?',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: AppColors.noir,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin membatalkan pesanan "${order.orderNumber}"? '
            'Stok produk akan dikembalikan secara otomatis.',
            style: const TextStyle(
              fontSize: 13.0,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Kembali'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
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
      ref.invalidate(productsListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pesanan ${order.orderNumber} berhasil dibatalkan'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 1. Header Cokelat Tua Sesuai Desain (Title + Search Pill + Icon)
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
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
                  8.0,
                  AppSpacing.md,
                  14.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Baris Judul "Daftar Pesanan" Rata Tengah
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new,
                                color: AppColors.surfaceWhite, size: 20.0),
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
                        const SizedBox(
                          height: 36.0,
                          child: Center(
                            child: Text(
                              'Daftar Pesanan',
                              style: TextStyle(
                                color: AppColors.surfaceWhite,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),

                    // Baris Search Bar Putih Kapsul & Tombol Aksi Return/History
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
                              controller: _searchController,
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(
                                color: AppColors.noir,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Cari pesanan atau nama...',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF9E9E9E),
                                  fontSize: 12.5,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 10.0,
                                ),
                                border: InputBorder.none,
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear,
                                            size: 18.0,
                                            color: AppColors.textSecondary),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {});
                                        },
                                      )
                                    : const Icon(
                                        Icons.search,
                                        color: AppColors.noir,
                                        size: 22.0,
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),

                        // Tombol Ikon Retur / Refresh di Sisi Kanan Search Bar
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            ref.invalidate(ordersListProvider);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 42.0,
                            height: 42.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surfaceWhite
                                    .withValues(alpha: 0.3),
                                width: 1.2,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.assignment_return_outlined,
                                color: AppColors.surfaceWhite,
                                size: 22.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Segmented Control / Tab Bar (Pesanan vs Pesanan Dibatalkan)
          Container(
            color: AppColors.surfaceWhite,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    index: 0,
                    title: 'Pesanan',
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: _buildTabButton(
                    index: 1,
                    title: 'Pesanan Dibatalkan',
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1.0,
            thickness: 1.0,
            color: Color(0xFFEAE5E0),
          ),

          // 3. Konten Daftar Pesanan (Card Layout Sesuai Desain)
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                // Filter berdasarkan tab (Pesanan Aktif vs Pesanan Dibatalkan)
                final tabFilteredOrders = orders.where((order) {
                  if (_selectedTab == 0) {
                    return order.orderStatus != 'cancelled';
                  } else {
                    return order.orderStatus == 'cancelled';
                  }
                }).toList();

                // Filter pencarian teks
                final query = _searchController.text.trim().toLowerCase();
                final filteredOrders = tabFilteredOrders.where((order) {
                  if (query.isEmpty) return true;
                  final matchNumber =
                      order.orderNumber.toLowerCase().contains(query);
                  final matchCustomer = order.customerName != null &&
                      order.customerName!.toLowerCase().contains(query);
                  final matchItem = order.items.any((item) =>
                      item.productName.toLowerCase().contains(query));
                  return matchNumber || matchCustomer || matchItem;
                }).toList();

                if (filteredOrders.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedTab == 0
                                ? Icons.receipt_long_outlined
                                : Icons.cancel_presentation_outlined,
                            size: 60.0,
                            color: AppColors.textSecondary
                                .withValues(alpha: 0.35),
                          ),
                          const SizedBox(height: 12.0),
                          Text(
                            _selectedTab == 0
                                ? (_searchController.text.isNotEmpty
                                    ? 'Tidak ada pesanan cocok dengan pencarian.'
                                    : 'Belum ada pesanan aktif.')
                                : (_searchController.text.isNotEmpty
                                    ? 'Tidak ada pesanan dibatalkan yang cocok.'
                                    : 'Tidak ada pesanan yang dibatalkan.'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    16.0,
                    14.0,
                    16.0,
                    100.0, // Clearance padding agar tidak terpotong CustomBottomNavBar
                  ),
                  itemCount: filteredOrders.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12.0),
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _buildOrderCard(order, index);
                  },
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
    );
  }

  Widget _buildTabButton({required int index, required String title}) {
    final isSelected = _selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 38.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(9999),
          border: isSelected
              ? null
              : Border.all(
                  color: const Color(0xFFE2DDD7),
                  width: 1.0,
                ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13.0,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? AppColors.surfaceWhite : AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderEntity order, int index) {
    final isExpanded = _expandedOrderIds.contains(order.id);
    final isCancelled = order.orderStatus == 'cancelled';
    final customerName = (order.customerName != null &&
            order.customerName!.trim().isNotEmpty)
        ? order.customerName!
        : 'Gaby';

    // Nomor urut antrian
    final queueNumber = (index + 1).toString().padLeft(2, '0');
    final orderDateTime = order.createdAt ?? DateTime.now();
    final pickupDateTime = orderDateTime.add(const Duration(hours: 1));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFFE2DDD7),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          onTap: () => _toggleExpanded(order.id),
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris Atas: Badge "Pesanan Baru" / "Pesanan Dibatalkan" & Chevron Accordion
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: isCancelled
                            ? const Color(0xFFFFEBEE)
                            : const Color(0xFFF7D1D7), // Pastel Blush Pink
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(
                        isCancelled ? 'Pesanan Dibatalkan' : 'Pesanan Baru',
                        style: TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.bold,
                          color: isCancelled
                              ? AppColors.danger
                              : AppColors.primary,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.noir,
                      size: 22.0,
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),

                // Nama Pelanggan (Bold Black)
                Text(
                  customerName,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.noir,
                  ),
                ),
                const SizedBox(height: 2.0),

                // Nomor Transaksi (Medium Bold Black) + Copy Icon
                Row(
                  children: [
                    Text(
                      order.orderNumber,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.noir,
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: order.orderNumber));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Nomor TRX disalin: ${order.orderNumber}'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.copy_outlined,
                        size: 16.0,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),

                // Waktu Pemesanan & Nomor Antrian (Medium Gray)
                Text(
                  '${DateFormatter.formatOrderDateTime(orderDateTime)} - Antrian $queueNumber',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8.0),

                // Jadwal Pengambilan (Bullet Pink Pastel + Label Gray + Jam Bold Black)
                Row(
                  children: [
                    Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.only(right: 6.0),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF7D1D7),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Jadwal Pengambilan: ',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextSpan(
                              text: DateFormatter.formatOrderDateTime(
                                  pickupDateTime),
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.noir,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Bagian Accordion Terbuka (Detail Menu & Aksi)
                if (isExpanded) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(
                      height: 1.0,
                      thickness: 1.0,
                      color: Color(0xFFEAE5E0),
                    ),
                  ),

                  // Daftar Item
                  ...order.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.productName} x${item.quantity}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.noir,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(item.subtotal),
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.noir,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 8.0),
                  const Divider(
                    height: 1.0,
                    thickness: 1.0,
                    color: Color(0xFFEAE5E0),
                  ),
                  const SizedBox(height: 8.0),

                  // Rincian Subtotal, Pajak, Ongkir
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subtotal',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(order.subtotal),
                        style: const TextStyle(fontSize: 12.0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pajak PB1 (10%)',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(order.taxAmount),
                        style: const TextStyle(fontSize: 12.0),
                      ),
                    ],
                  ),
                  if (order.deliveryFee > 0) ...[
                    const SizedBox(height: 2.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ongkir Delivery',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(order.deliveryFee),
                          style: const TextStyle(fontSize: 12.0),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.noir,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(order.totalAmount),
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12.0),

                  // Baris Tombol Aksi: Lihat Struk & Batalkan Pesanan
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.primary,
                              width: 1.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                          ),
                          onPressed: () => _showOrderReceipt(context, order),
                          icon: const Icon(
                            Icons.receipt_outlined,
                            size: 16.0,
                            color: AppColors.primary,
                          ),
                          label: const Text(
                            'Lihat Struk',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      if (!isCancelled) ...[
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppColors.danger,
                                width: 1.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                            ),
                            onPressed: () =>
                                _confirmCancelOrder(context, order),
                            icon: const Icon(
                              Icons.cancel_outlined,
                              size: 16.0,
                              color: AppColors.danger,
                            ),
                            label: const Text(
                              'Batalkan',
                              style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.danger,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
