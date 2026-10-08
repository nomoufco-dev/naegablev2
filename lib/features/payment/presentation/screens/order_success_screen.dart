import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/domain/entities/order_entity.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';

/// Layar Pesanan Berhasil Naegablé Bakehaus sesuai spesifikasi Figma (DESIGN_SPEC_FIGMA.md):
/// Lingkaran centang hijau besar, "Pesanan Berhasil Ditambahkan",
/// kartu info pelanggan ("Gaby" + alamat/order details), tombol "Cetak Struk Pesanan" cokelat.
class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({
    super.key,
    this.order,
  });

  final OrderEntity? order;

  @override
  Widget build(BuildContext context) {
    final customerName = (order?.customerName != null && order!.customerName!.isNotEmpty)
        ? order!.customerName!
        : 'Gaby';
    final address = order?.deliveryAddress ?? 'Jl. Artisan Bakery No. 12, Jakarta';
    final orderNum = order?.orderNumber ?? 'TRX20261002-001';
    final totalAmount = order?.totalAmount ?? 56000.0;
    final createdAt = order?.createdAt ?? DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Pesanan Berhasil'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surfaceWhite,
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 24.0),
                    // Lingkaran Centang Hijau Besar
                    Container(
                      width: 96.0,
                      height: 96.0,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF2E9E5B),
                          size: 72.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Title Header
                    const Text(
                      'Pesanan Berhasil Ditambahkan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.noir,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      'Nomor Order: $orderNum',
                      style: const TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Kartu Info Pelanggan & Pesanan
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0F000000),
                            blurRadius: 10.0,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Informasi Pelanggan',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.noir,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: AppColors.blush,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Text(
                                  (order?.orderType ?? 'take_away').toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24.0, color: Color(0xFFEAE5E0)),

                          // Nama & Alamat
                          Row(
                            children: [
                              const Icon(Icons.person_outline, size: 20.0, color: AppColors.primary),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Text(
                                  customerName,
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.noir,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on_outlined, size: 20.0, color: AppColors.primary),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Text(
                                  address,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 20.0, color: AppColors.primary),
                              const SizedBox(width: 10.0),
                              Text(
                                DateFormatter.formatOrderDateTime(createdAt),
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24.0, color: Color(0xFFEAE5E0)),

                          // Rincian Item jika ada
                          if (order != null && order!.items.isNotEmpty) ...[
                            const Text(
                              'Rincian Item',
                              style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.noir,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            ...order!.items.map((item) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${item.productName} x${item.quantity}',
                                      style: const TextStyle(fontSize: 12.5, color: AppColors.noir),
                                    ),
                                    Text(
                                      CurrencyFormatter.format(item.subtotal),
                                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const Divider(height: 20.0, color: Color(0xFFEAE5E0)),
                          ],

                          // Total Pembayaran
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Pembayaran',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.noir,
                                ),
                              ),
                              Text(
                                CurrencyFormatter.format(totalAmount),
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
              ),
            ),

            // Tombol Bottom Sticky: Cetak Struk Pesanan & Kembali ke POS
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: AppColors.surfaceWhite,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 8.0,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48.0,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mencetak struk pesanan...'),
                            duration: Duration(seconds: 2),
                          ),
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
                      icon: const Icon(Icons.print_outlined, size: 20.0),
                      label: const Text(
                        'Cetak Struk Pesanan',
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.surfaceWhite,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextButton(
                    onPressed: () => context.go('/pos'),
                    child: const Text(
                      'Kembali ke Kasir',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
