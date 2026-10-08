import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../pos/presentation/controllers/pos_controller.dart';

/// Layar Pengaturan Pengiriman Naegablé Bakehaus sesuai spesifikasi Figma (DESIGN_SPEC_FIGMA.md):
/// Daftar metode (Delivery Order/DO, Cash on Delivery/COD, Self Pick-Up)
/// masing-masing dengan toggle iOS-style on/off.
class DeliverySettingsScreen extends ConsumerStatefulWidget {
  const DeliverySettingsScreen({super.key});

  @override
  ConsumerState<DeliverySettingsScreen> createState() => _DeliverySettingsScreenState();
}

class _DeliverySettingsScreenState extends ConsumerState<DeliverySettingsScreen> {
  bool _doEnabled = true;
  bool _codEnabled = true;
  bool _selfPickupEnabled = true;

  @override
  Widget build(BuildContext context) {
    final deliveryAsync = ref.watch(deliverySettingsControllerProvider);
    _doEnabled = deliveryAsync.value?.isDeliveryEnabled ?? true;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Pengaturan Pengiriman'),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                child: Text(
                  'Metode Pengiriman Aktif',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.noir,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),

              // 1. Delivery Order (DO)
              _buildMethodToggleTile(
                title: 'Delivery Order (DO)',
                subtitle: 'Pengiriman kurir toko langsung ke alamat pelanggan',
                icon: Icons.local_shipping_outlined,
                value: _doEnabled,
                onChanged: (val) {
                  ref.read(deliverySettingsControllerProvider.notifier).toggleDelivery();
                },
              ),
              const SizedBox(height: 12.0),

              // 2. Cash on Delivery (COD)
              _buildMethodToggleTile(
                title: 'Cash on Delivery (COD)',
                subtitle: 'Pembayaran tunai saat barang diterima di tempat',
                icon: Icons.payments_outlined,
                value: _codEnabled,
                onChanged: (val) {
                  setState(() => _codEnabled = val);
                },
              ),
              const SizedBox(height: 12.0),

              // 3. Self Pick-Up
              _buildMethodToggleTile(
                title: 'Self Pick-Up',
                subtitle: 'Pelanggan mengambil sendiri pesanan di outlet',
                icon: Icons.storefront_outlined,
                value: _selfPickupEnabled,
                onChanged: (val) {
                  setState(() => _selfPickupEnabled = val);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodToggleTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
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
      child: Row(
        children: [
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              color: AppColors.blush,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22.0),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.noir,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Transform.scale(
            scale: 0.85,
            child: CupertinoSwitch(
              value: value,
              activeTrackColor: AppColors.primary,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
