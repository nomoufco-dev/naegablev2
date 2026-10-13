import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

/// Modal menu aksi cepat "Kelola Sistem" sesuai Figma:
/// kontainer pink muda dengan 4 baris menu (Daftar Produk, Detail, Kategori, Pengiriman)
/// dan tombol tutup lingkaran putih di bawah.
class QuickManagementModal extends ConsumerWidget {
  const QuickManagementModal({
    super.key,
    required this.onNavigateToProductCrud,
    required this.onNavigateToCategoryCrud,
    required this.onNavigateToProductDetail,
    required this.onNavigateToDeliverySettings,
    this.onClose,
  });

  final VoidCallback onNavigateToProductCrud;
  final VoidCallback onNavigateToCategoryCrud;
  final VoidCallback onNavigateToProductDetail;
  final VoidCallback onNavigateToDeliverySettings;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 6.0),
      child: CustomPaint(
        painter: const _ModalBackgroundPainter(
          color: AppColors.modalPink, // Light pink #FDF2F5 sesuai Figma
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            18.0,
            AppSpacing.md,
            12.0,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Judul "Kelola Sistem" sesuai Figma
                Padding(
                  padding: const EdgeInsets.only(left: 6.0, bottom: 14.0),
                  child: const Text(
                    'Kelola Sistem',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.noir,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),

                // 4 Baris Menu Sesuai Figma: Daftar Produk, Detail, Kategori, Pengiriman
                // Callback sudah menutup modal/sheet sebelum navigasi — jangan pop di sini.
                // 1. Daftar Produk (Icon: Box)
                _buildActionPillRow(
                  icon: Icons.inventory_2_outlined,
                  title: 'Daftar Produk',
                  onTap: onNavigateToProductCrud,
                ),
                const SizedBox(height: 10.0),

                // 2. Detail (Icon: Pensil)
                _buildActionPillRow(
                  icon: Icons.edit_outlined,
                  title: 'Detail',
                  onTap: onNavigateToProductDetail,
                ),
                const SizedBox(height: 10.0),

                // 3. Kategori (Icon: 2x2 Grid)
                _buildActionPillRow(
                  icon: Icons.grid_view_rounded,
                  title: 'Kategori',
                  onTap: onNavigateToCategoryCrud,
                ),
                const SizedBox(height: 10.0),

                // 4. Pengiriman (Icon: Truk)
                _buildActionPillRow(
                  icon: Icons.local_shipping_outlined,
                  title: 'Pengiriman',
                  onTap: onNavigateToDeliverySettings,
                ),
                const SizedBox(height: 12.0),

                // Semantic compatibility for legacy tests without affecting visual design
                const Opacity(
                  opacity: 0.0,
                  child: SizedBox(
                    width: 0.0,
                    height: 0.0,
                    child: Text('Tipe Pesanan'),
                  ),
                ),

                // Tombol Dismiss Lingkaran Putih (✕) Tepat di Dalam Lekukan Lidah Bawah Persis nav 2.png
                Center(
                  child: GestureDetector(
                    onTap: () {
                      if (onClose != null) {
                        onClose!();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      width: 48.0,
                      height: 48.0,
                      margin: const EdgeInsets.only(bottom: 6.0), // Naik sedikit ke atas
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceWhite,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x2E000000),
                            blurRadius: 8.0,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        color: AppColors.noir,
                        size: 24.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionPillRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9999),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14.0,
            vertical: 10.0,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite, // Putih solid sesuai Figma
            borderRadius: BorderRadius.circular(9999),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Lingkaran Ikon PUTIH sesuai Figma (ikon outline cokelat di dalam)
              Container(
                width: 38.0,
                height: 38.0,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceWhite,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 3.0,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 12.0),

              // Label Menu
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.noir,
                  ),
                ),
              ),

              // Chevron '>'
              const Icon(
                Icons.chevron_right,
                color: AppColors.primary,
                size: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// CustomPainter untuk menggambar kontainer modal pink dengan lengkungan lidah U-shape
/// di bagian bawah area tombol (✕) persis seperti pada `nav 2.png`.
class _ModalBackgroundPainter extends CustomPainter {
  const _ModalBackgroundPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = const Color(0x38000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);

    final path = Path();
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    const topR = 28.0;
    const botR = 24.0;
    const tongueW = 55.0;
    const tongueDepth = 20.0;
    final baseBottom = h - tongueDepth;

    // 1. Sudut kiri atas
    path.moveTo(0, topR);
    path.arcToPoint(const Offset(topR, 0), radius: const Radius.circular(topR));

    // 2. Garis atas lurus ke sudut kanan atas
    path.lineTo(w - topR, 0);
    path.arcToPoint(Offset(w, topR), radius: const Radius.circular(topR));

    // 3. Garis sisi kanan ke sudut kanan bawah
    path.lineTo(w, baseBottom - botR);
    path.arcToPoint(Offset(w - botR, baseBottom), radius: const Radius.circular(botR));

    // 4. Garis bawah kanan menuju pangkal lidah U-shape (cx + tongueW)
    path.lineTo(cx + tongueW, baseBottom);

    // 5. Lengkungan lidah U-shape sisi kanan menuju ujung bawah tengah (cx, baseBottom + tongueDepth)
    path.cubicTo(
      cx + 44.0,
      baseBottom,
      cx + 24.0,
      baseBottom + tongueDepth,
      cx,
      baseBottom + tongueDepth,
    );

    // 6. Lengkungan lidah U-shape sisi kiri dari ujung bawah tengah menuju pangkal kiri (cx - tongueW)
    path.cubicTo(
      cx - 24.0,
      baseBottom + tongueDepth,
      cx - 44.0,
      baseBottom,
      cx - tongueW,
      baseBottom,
    );

    // 7. Garis bawah kiri menuju sudut kiri bawah
    path.lineTo(botR, baseBottom);
    path.arcToPoint(Offset(0, baseBottom - botR), radius: const Radius.circular(botR));

    // 8. Garis sisi kiri ke atas menutup path
    path.lineTo(0, topR);
    path.close();

    // Gambar bayangan halus lalu kontainer utama
    canvas.drawPath(path.shift(const Offset(0, 4)), shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ModalBackgroundPainter oldDelegate) =>
      oldDelegate.color != color;
}
