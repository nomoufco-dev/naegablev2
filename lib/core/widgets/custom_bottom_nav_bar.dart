import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';

/// Navigation bar melayang berbentuk kapsul:
/// - State Normal: `design-system/nav 1.png` (Upward dome melengkung ke atas dengan bulatan FAB pink (+) konsentris)
/// - State Morphing / Terbuka: `design-system/nav 2.png` (Cekungan cradle berlubang ke bawah tempat menempelnya modal)
class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    super.key,
    this.selectedIndex = 0,
    this.onItemSelected,
    this.onFabPressed,
    this.isCloseState = false,
    this.morphProgress,
  });

  final int selectedIndex;
  final ValueChanged<int>? onItemSelected;
  final VoidCallback? onFabPressed;
  final bool isCloseState;
  final double? morphProgress;

  double get effectiveProgress => morphProgress ?? (isCloseState ? 1.0 : 0.0);

  @override
  Widget build(BuildContext context) {
    const baseTop = 18.0;
    const fabRadius = 25.0; // FAB diameter 50.0

    final progress = effectiveProgress;
    final fabScale = (1.0 - progress).clamp(0.0, 1.0);
    final fabOpacity = (1.0 - progress * 2.0).clamp(0.0, 1.0);

    return Container(
      height: 78.0,
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        16.0, // Posisi lebih naik ke atas dari batas bawah layar
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Background Bar Kapsul Melayang Sesuai nav 1.png & nav 2.png
          CustomPaint(
            size: const Size(double.infinity, 78.0),
            painter: _NotchedPillPainter(
              color: const Color(0xFF3E2D2A), // Deep Espresso Brown nav 1.png
              morphProgress: progress,
            ),
            child: SizedBox(
              height: 78.0,
              child: Padding(
                padding: const EdgeInsets.only(top: baseTop),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      icon: Icons.storefront_outlined,
                      tooltip: 'Kasir',
                      index: 0,
                    ),
                    _buildNavItem(
                      icon: Icons.layers_outlined,
                      tooltip: 'Katalog & Kelola',
                      index: 1,
                    ),
                    const SizedBox(width: 72.0), // Gap area tengah dengan margin lengkungan
                    _buildNavItem(
                      icon: Icons.history_outlined,
                      tooltip: 'Riwayat Transaksi',
                      index: 2,
                    ),
                    _buildNavItem(
                      icon: Icons.bar_chart_outlined,
                      tooltip: 'Laporan',
                      index: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Central FAB (+) Sesuai nav 1.png
          // Memberikan margin clearance merata di sekeliling bulatan tombol (+)
          if (fabOpacity > 0.0)
            Positioned(
              top: 8.0, // Memberikan clearance margin dari puncak lengkungan dome y=0
              left: 0,
              right: 0,
              child: Center(
                child: Opacity(
                  opacity: fabOpacity,
                  child: Transform.scale(
                    scale: fabScale,
                    child: GestureDetector(
                      onTap: onFabPressed,
                      child: Container(
                        width: fabRadius * 2,
                        height: fabRadius * 2,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6CAD4), // Pastel Blush Pink nav 1.png
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.16),
                              blurRadius: 6.0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.add,
                          color: Color(0xFF3E2D2A), // Dark Brown plus icon nav 1.png
                          size: 26.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String tooltip,
    required int index,
  }) {
    final isSelected = selectedIndex == index;
    return IconButton(
      tooltip: tooltip,
      onPressed: () => onItemSelected?.call(index),
      icon: Icon(
        icon,
        // nav 1.png: ikon pastel pink (#F6CAD4) dengan opacity halus untuk inaktif
        color: isSelected
            ? const Color(0xFFF6CAD4)
            : const Color(0xFFF6CAD4).withValues(alpha: 0.72),
        size: 24.0,
      ),
    );
  }
}

class _NotchedPillPainter extends CustomPainter {
  _NotchedPillPainter({
    required this.color,
    required this.morphProgress,
  });

  final Color color;
  final double morphProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = const Color(0x33000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    final path = Path();
    final cx = size.width / 2;
    const baseTop = 18.0; // Baseline horizontal atas bar
    final r = (size.height - baseTop) / 2; // radius ujung kapsul (~30.0)

    // Ujung kiri kapsul
    path.moveTo(r, size.height);
    path.arcToPoint(
      Offset(0, baseTop + r),
      radius: Radius.circular(r),
      clockwise: true,
    );
    path.arcToPoint(
      Offset(r, baseTop),
      radius: Radius.circular(r),
      clockwise: true,
    );

    // Interpolasi Halus Antara Upward Dome (nav 1.png) & Concave Cradle (nav 2.png)
    final t = morphProgress.clamp(0.0, 1.0);

    // Lengkungan dome lebih luas (spanW = 42.0) agar bulatan (+) memiliki margin clearance
    final spanW = lerpDouble(42.0, 58.0, t)!;
    final midY = lerpDouble(0.0, baseTop + 24.0, t)!;

    // Control points kiri
    final p1x = lerpDouble(cx - 30.0, cx - 46.0, t)!;
    final p1y = lerpDouble(7.0, baseTop, t)!;
    final p2x = lerpDouble(cx - 16.0, cx - 25.0, t)!;
    final p2y = lerpDouble(0.0, baseTop + 24.0, t)!;

    // Control points kanan
    final p3x = lerpDouble(cx + 16.0, cx + 25.0, t)!;
    final p3y = lerpDouble(0.0, baseTop + 24.0, t)!;
    final p4x = lerpDouble(cx + 30.0, cx + 46.0, t)!;
    final p4y = lerpDouble(7.0, baseTop, t)!;

    // Garis atas lurus ke awal lengkungan tengah
    path.lineTo(cx - spanW, baseTop);

    // Sisi kiri lengkungan ke pusat (cx, midY)
    path.cubicTo(
      p1x,
      p1y,
      p2x,
      p2y,
      cx,
      midY,
    );

    // Sisi kanan lengkungan dari pusat (cx, midY) ke baseline
    path.cubicTo(
      p3x,
      p3y,
      p4x,
      p4y,
      cx + spanW,
      baseTop,
    );

    // Garis atas menuju ujung kanan kapsul
    path.lineTo(size.width - r, baseTop);
    path.arcToPoint(
      Offset(size.width, baseTop + r),
      radius: Radius.circular(r),
      clockwise: true,
    );
    path.arcToPoint(
      Offset(size.width - r, size.height),
      radius: Radius.circular(r),
      clockwise: true,
    );

    // Garis bawah lurus menutup path
    path.lineTo(r, size.height);
    path.close();

    // Gambar bayangan halus lalu kontainer utama
    canvas.drawPath(path.shift(const Offset(0, 3)), shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NotchedPillPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.morphProgress != morphProgress;
  }
}
