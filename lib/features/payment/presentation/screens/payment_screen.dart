import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/domain/entities/order_entity.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../pos/presentation/controllers/cart_controller.dart';
import '../../../pos/presentation/controllers/pos_controller.dart';

/// Layar Pembayaran Naegablé Bakehaus sesuai spesifikasi Figma (DESIGN_SPEC_FIGMA.md):
/// Total Pembayaran hijau besar ±#2E9E5B, field Nama Pelanggan (opsional),
/// pill toggle "Tunai"/"QRIS", field Jumlah Uang, hitung Kembalian otomatis,
/// tombol cepat Rp50.000/Rp100.000/Pas, tombol "Konfirmasi Pembayaran" cokelat
/// -> modal sukses (kartu putih rounded-2xl, centang hijau, Batal outline + OK cokelat).
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({
    super.key,
    this.totalAmount,
    this.initialCustomerName,
  });

  final double? totalAmount;
  final String? initialCustomerName;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  late final TextEditingController _customerNameController;
  late final TextEditingController _amountController;
  String _paymentMethod = 'cash'; // 'cash' or 'qris'
  double _tenderedAmount = 0.0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _customerNameController = TextEditingController(text: widget.initialCustomerName ?? '');
    
    final cart = ref.read(cartProvider);
    final targetTotal = widget.totalAmount ?? (cart.isNotEmpty ? cart.grandTotal : 56000.0);
    _tenderedAmount = targetTotal;
    _amountController = TextEditingController(text: targetTotal.toInt().toString());
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String val) {
    final clean = val.replaceAll(RegExp(r'[^0-9]'), '');
    final parsed = double.tryParse(clean) ?? 0.0;
    setState(() {
      _tenderedAmount = parsed;
    });
  }

  void _setQuickAmount(double amount) {
    setState(() {
      _tenderedAmount = amount;
      _amountController.text = amount.toInt().toString();
    });
  }

  Future<void> _handleConfirmPayment(double total) async {
    // Show Modal Sukses
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.0,
                height: 64.0,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF2E9E5B),
                  size: 44.0,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Pembayaran ${CurrencyFormatter.format(total)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.noir,
                ),
              ),
              const SizedBox(height: 6.0),
              const Text(
                'Konfirmasi pembayaran transaksi kasir?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.0,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surfaceWhite,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.surfaceWhite,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (result == true) {
      await _processFinalCheckout(total);
    }
  }

  Future<void> _processFinalCheckout(double total) async {
    setState(() => _isProcessing = true);
    try {
      final cart = ref.read(cartProvider);
      final orderRepo = ref.read(orderRepositoryProvider);
      
      final customerName = _customerNameController.text.trim().isNotEmpty
          ? _customerNameController.text.trim()
          : (cart.customerName ?? 'Gaby');

      ref.read(cartProvider.notifier).setCustomerInfo(
            customerName: customerName,
          );

      OrderEntity completedOrder;
      if (cart.isNotEmpty) {
        completedOrder = await ref.read(cartProvider.notifier).checkout(
              orderRepo: orderRepo,
              paymentMethod: _paymentMethod,
              amountTendered: _paymentMethod == 'cash' ? _tenderedAmount : total,
            );
      } else {
        // Fallback dummy order if navigated directly
        final now = DateTime.now();
        final orderId = 'ord-${now.millisecondsSinceEpoch}';
        completedOrder = OrderEntity(
          id: orderId,
          storeId: 'store-main-001',
          orderNumber: 'TRX${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-001',
          orderType: 'take_away',
          orderStatus: 'completed',
          customerName: customerName,
          subtotal: total,
          totalAmount: total,
          paymentMethod: _paymentMethod,
          amountTendered: _paymentMethod == 'cash' ? _tenderedAmount : total,
          changeAmount: (_tenderedAmount - total) > 0 ? (_tenderedAmount - total) : 0.0,
          createdAt: now,
          items: [
            OrderItemEntity(
              id: 'item-1',
              orderId: orderId,
              productId: 'prod-01',
              productName: 'Dubai Chewy Cookie',
              unitPrice: 28000.0,
              quantity: 2,
              subtotal: 56000.0,
            ),
          ],
        );
        await orderRepo.createOrder(completedOrder);
      }

      ref.invalidate(productsListProvider);
      ref.invalidate(ordersListProvider);

      if (!mounted) return;
      context.pushReplacement('/order-success', extra: completedOrder);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memproses pembayaran: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final total = widget.totalAmount ?? (cart.isNotEmpty ? cart.grandTotal : 56000.0);
    final change = _tenderedAmount - total;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Pembayaran'),
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Kartu Total Pembayaran Hijau Besar
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0F000000),
                            blurRadius: 8.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Total Pembayaran',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          Text(
                            CurrencyFormatter.format(total),
                            style: const TextStyle(
                              fontSize: 32.0,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2E9E5B),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18.0),

                    // Field Nama Pelanggan (Opsional)
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nama Pelanggan (Opsional)',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.noir,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          TextField(
                            controller: _customerNameController,
                            decoration: InputDecoration(
                              hintText: 'Contoh: Gaby',
                              hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
                              filled: true,
                              fillColor: AppColors.cream,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18.0),

                    // Kartu Metode Pembayaran: Pill Toggle Tunai / QRIS
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Metode Pembayaran',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.noir,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Row(
                            children: [
                              Expanded(
                                child: _buildMethodPill(
                                  label: 'Tunai',
                                  keyName: 'cash',
                                  icon: Icons.payments_outlined,
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: _buildMethodPill(
                                  label: 'QRIS',
                                  keyName: 'qris',
                                  icon: Icons.qr_code_scanner,
                                ),
                              ),
                            ],
                          ),

                          if (_paymentMethod == 'cash') ...[
                            const SizedBox(height: 16.0),
                            const Text(
                              'Jumlah Uang',
                              style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.noir,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              onChanged: _onAmountChanged,
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.noir,
                              ),
                              decoration: InputDecoration(
                                prefixText: 'Rp ',
                                prefixStyle: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.noir,
                                ),
                                filled: true,
                                fillColor: AppColors.cream,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12.0),

                            // Tombol Cepat Rp50.000 / Rp100.000 / Uang Pas
                            Row(
                              children: [
                                Expanded(
                                  child: _buildQuickAmountBtn('Uang Pas', total),
                                ),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: _buildQuickAmountBtn('Rp50.000', 50000.0),
                                ),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: _buildQuickAmountBtn('Rp100.000', 100000.0),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),

                            // Display Kembalian
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              decoration: BoxDecoration(
                                color: change >= 0 ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    change >= 0 ? 'Kembalian' : 'Uang Kurang',
                                    style: TextStyle(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.bold,
                                      color: change >= 0 ? const Color(0xFF2E9E5B) : AppColors.danger,
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(change >= 0 ? change : change.abs()),
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w800,
                                      color: change >= 0 ? const Color(0xFF2E9E5B) : AppColors.danger,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 16.0),
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: AppColors.cream,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: const Center(
                                child: Text(
                                  'Tunjukkan QRIS pada layar ini untuk di-scan oleh pelanggan.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tombol Sticky Bottom: "Konfirmasi Pembayaran" Cokelat
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
              child: SizedBox(
                width: double.infinity,
                height: 50.0,
                child: ElevatedButton(
                  onPressed: (_paymentMethod == 'cash' && change < 0) || _isProcessing
                      ? null
                      : () => _handleConfirmPayment(total),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surfaceWhite,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 22.0,
                          height: 22.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Konfirmasi Pembayaran',
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.surfaceWhite,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodPill({
    required String label,
    required String keyName,
    required IconData icon,
  }) {
    final isSelected = _paymentMethod == keyName;

    return GestureDetector(
      onTap: () {
        setState(() => _paymentMethod = keyName);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blush : AppColors.cream,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18.0,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6.0),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAmountBtn(String label, double amount) {
    final isCurrent = (_tenderedAmount - amount).abs() < 1;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: isCurrent ? AppColors.primary : AppColors.surfaceWhite,
        foregroundColor: isCurrent ? AppColors.surfaceWhite : AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      ),
      onPressed: () => _setQuickAmount(amount),
      child: Text(
        label,
        maxLines: 1,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
