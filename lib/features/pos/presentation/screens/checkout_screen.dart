import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/domain/entities/order_entity.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../controllers/cart_controller.dart';
import '../controllers/pos_controller.dart';

/// Layar checkout & konfirmasi pesanan dengan desain presisi sesuai mock-up.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  // Metode pemesanan: 'bayar_langsung' (default sesuai desain) atau 'buat_pesanan'
  String _orderMethod = 'bayar_langsung';

  // Toggle biaya tambahan
  bool _hasAdditionalFee = false;
  static const double _additionalFeeAmount = 5000.0;

  bool _isProcessing = false;

  String _formatRpNoSpace(num amount) {
    return 'Rp${CurrencyFormatter.format(amount).replaceAll('Rp', '').trim()}';
  }

  Future<void> _handlePrimaryAction() async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) return;

    if (_orderMethod == 'bayar_langsung') {
      _showPaymentSheet();
    } else {
      await _executeCheckout(paymentMethod: 'unpaid', tendered: 0.0);
    }
  }

  Future<void> _executeCheckout({
    required String paymentMethod,
    required double tendered,
  }) async {
    setState(() => _isProcessing = true);

    try {
      final cart = ref.read(cartProvider);
      final finalTotal = cart.grandTotal + (_hasAdditionalFee ? _additionalFeeAmount : 0.0);

      ref.read(cartProvider.notifier).setCustomerInfo(
            customerName: 'Pelanggan Walk-In',
          );

      final orderRepo = ref.read(orderRepositoryProvider);
      final completedOrder = await ref.read(cartProvider.notifier).checkout(
            orderRepo: orderRepo,
            paymentMethod: paymentMethod,
            amountTendered: tendered > 0 ? tendered : finalTotal,
          );

      ref.invalidate(productsListProvider);
      ref.invalidate(ordersListProvider);

      if (!mounted) return;
      setState(() => _isProcessing = false);

      await _showReceiptDialog(completedOrder);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memproses pesanan: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _showPaymentSheet() {
    final cart = ref.read(cartProvider);
    final finalTotal = cart.grandTotal + (_hasAdditionalFee ? _additionalFeeAmount : 0.0);
    String selectedMethod = 'cash';
    double tendered = finalTotal;
    final cashController = TextEditingController(text: finalTotal.toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final change = tendered - finalTotal;

            return Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 20.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pilih Pembayaran',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111111),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20.0),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        _buildSheetMethodBtn('Tunai', 'cash', selectedMethod, () {
                          setSheetState(() => selectedMethod = 'cash');
                        }),
                        const SizedBox(width: 8.0),
                        _buildSheetMethodBtn('QRIS', 'qris', selectedMethod, () {
                          setSheetState(() => selectedMethod = 'qris');
                        }),
                        const SizedBox(width: 8.0),
                        _buildSheetMethodBtn('Kartu / EDC', 'card', selectedMethod, () {
                          setSheetState(() => selectedMethod = 'card');
                        }),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    if (selectedMethod == 'cash') ...[
                      const Text(
                        'Nominal Uang Diterima',
                        style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6.0),
                      TextField(
                        controller: cashController,
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          final parsed = double.tryParse(val.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                          setSheetState(() => tendered = parsed);
                        },
                        decoration: InputDecoration(
                          prefixText: 'Rp ',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(color: Color(0xFFDCDCDC)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            change >= 0 ? 'Kembalian:' : 'Kurang:',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: change >= 0 ? const Color(0xFF00C853) : Colors.red,
                            ),
                          ),
                          Text(
                            _formatRpNoSpace(change >= 0 ? change : change.abs()),
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: change >= 0 ? const Color(0xFF00C853) : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Center(
                          child: Text(
                            selectedMethod == 'qris'
                                ? 'Pindai kode QRIS pada struk / layar kasir'
                                : 'Silakan lakukan transaksi pada mesin EDC',
                            style: const TextStyle(fontSize: 13.0, color: Color(0xFF555555)),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: selectedMethod == 'cash' && tendered < finalTotal
                          ? null
                          : () {
                              Navigator.of(context).pop();
                              _executeCheckout(
                                paymentMethod: selectedMethod,
                                tendered: selectedMethod == 'cash' ? tendered : finalTotal,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF44322D),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                      child: const Text(
                        'Konfirmasi & Bayar',
                        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSheetMethodBtn(
    String label,
    String key,
    String current,
    VoidCallback onTap,
  ) {
    final active = key == current;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF44322D) : Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: active ? const Color(0xFF44322D) : const Color(0xFFDCDCDC),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: active ? Colors.white : const Color(0xFF111111),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showReceiptDialog(OrderEntity order) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          contentPadding: const EdgeInsets.all(16.0),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48.0,
                  height: 48.0,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF00C853),
                    size: 30.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'Pesanan Berhasil Disimpan',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 2.0),
                const Text(
                  'naegablé BAKEHAUS',
                  style: TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF44322D),
                    letterSpacing: 1.1,
                  ),
                ),
                const Divider(height: 18.0),
                _buildReceiptRow('Nomor Order', order.orderNumber),
                _buildReceiptRow('Waktu', DateFormatter.formatDateTime(order.createdAt ?? DateTime.now())),
                _buildReceiptRow('Metode', order.paymentMethod?.toUpperCase() ?? '-'),
                const Divider(height: 14.0),
                ...order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.productName} x${item.quantity}',
                            style: const TextStyle(fontSize: 12.0, color: Color(0xFF111111)),
                          ),
                        ),
                        Text(
                          _formatRpNoSpace(item.subtotal),
                          style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 14.0),
                _buildReceiptRow('Total', _formatRpNoSpace(order.totalAmount), isBold: true),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF44322D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                minimumSize: const Size(double.infinity, 44.0),
              ),
              child: const Text('Selesai'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? const Color(0xFF111111) : const Color(0xFF666666),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: const Color(0xFF111111),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final orderTotal = cart.grandTotal;
    final grandTotal = orderTotal + (_hasAdditionalFee ? _additionalFeeAmount : 0.0);
    final isBayarLangsung = _orderMethod == 'bayar_langsung';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: AppBar(
          backgroundColor: const Color(0xFF44322D),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 18.0,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Checkout',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Bagian 1: Metode Pemesanan
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Metode Pemesanan',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111111),
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Row(
                            children: [
                              Expanded(
                                child: _buildMethodButton(
                                  label: 'Bayar Langsung',
                                  isActive: isBayarLangsung,
                                  onTap: () {
                                    setState(() => _orderMethod = 'bayar_langsung');
                                  },
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: _buildMethodButton(
                                  label: 'Buat Pesanan',
                                  isActive: !isBayarLangsung,
                                  onTap: () {
                                    setState(() => _orderMethod = 'buat_pesanan');
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Divider(
                      height: 1.0,
                      thickness: 1.0,
                      color: Color(0xFFDCDCDC),
                    ),

                    // Bagian 2: Biaya Tambahan
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Biaya Tambahan',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111111),
                            ),
                          ),
                          Transform.scale(
                            scale: 0.85,
                            child: CupertinoSwitch(
                              value: _hasAdditionalFee,
                              activeTrackColor: const Color(0xFF44322D),
                              inactiveTrackColor: const Color(0xFFCCCCCC),
                              onChanged: (val) {
                                setState(() => _hasAdditionalFee = val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(
                      height: 1.0,
                      thickness: 1.0,
                      color: Color(0xFFDCDCDC),
                    ),

                    // Bagian 3: Rincian Pesanan
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rincian Pesanan',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111111),
                            ),
                          ),
                          const SizedBox(height: 12.0),

                          // Daftar Produk di Keranjang
                          if (cart.items.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Tidak ada produk di keranjang',
                                style: TextStyle(
                                  fontSize: 13.0,
                                  color: Color(0xFF777777),
                                ),
                              ),
                            )
                          else
                            ...cart.items.map((item) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Text(
                                        item.product.name,
                                        style: const TextStyle(
                                          fontSize: 13.0,
                                          color: Color(0xFF111111),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        '${_formatRpNoSpace(item.product.price)} X ${item.quantity}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 13.0,
                                          color: Color(0xFF111111),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        _formatRpNoSpace(item.subtotal),
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF111111),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                          if (_hasAdditionalFee) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
                              child: Row(
                                children: [
                                  const Expanded(
                                    flex: 5,
                                    child: Text(
                                      'Biaya Tambahan',
                                      style: TextStyle(
                                        fontSize: 13.0,
                                        color: Color(0xFF111111),
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    flex: 4,
                                    child: Text(
                                      '-',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13.0,
                                        color: Color(0xFF111111),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      _formatRpNoSpace(_additionalFeeAmount),
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF111111),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 8.0),
                          const Divider(
                            height: 1.0,
                            thickness: 1.0,
                            color: Color(0xFFDCDCDC),
                          ),
                          const SizedBox(height: 12.0),

                          // Total Pesanan Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Pesanan',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111111),
                                ),
                              ),
                              Text(
                                _formatRpNoSpace(orderTotal),
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111111),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),

                          // Total Grand Total Row (Green)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111111),
                                ),
                              ),
                              Text(
                                _formatRpNoSpace(grandTotal),
                                style: const TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00C853),
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

            // Bottom CTA Bar
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFDCDCDC),
                    width: 1.0,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: SizedBox(
                width: double.infinity,
                height: 48.0,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _handlePrimaryAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF44322D),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF44322D).withValues(alpha: 0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.0),
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
                      : Text(
                          isBayarLangsung ? 'Bayar Langsung' : 'Buat Pesanan',
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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

  Widget _buildMethodButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 46.0,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF44322D) : Colors.white,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: isActive ? const Color(0xFF44322D) : const Color(0xFFDCDCDC),
            width: 1.2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : const Color(0xFF111111),
          ),
        ),
      ),
    );
  }
}
