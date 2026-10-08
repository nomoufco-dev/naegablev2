import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../category_crud/presentation/screens/category_management_screen.dart';
import '../../../history/presentation/screens/transaction_history_screen.dart';
import '../../../product_crud/presentation/screens/product_management_screen.dart';
import '../../../reports/presentation/screens/sales_report_screen.dart';
import '../controllers/cart_controller.dart';
import '../controllers/pos_controller.dart';
import '../widgets/bottom_cart_sheet.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/pos_app_bar.dart';
import '../widgets/product_grid_card.dart';
import '../widgets/quick_management_modal.dart';
import 'checkout_screen.dart';

/// Layar Utama POS / Kasir Naegablé Bakehaus,
/// mengimplementasikan secara visual dan fungsional desain
/// `HOME - KASIR PAGE TIPE 1.png` (Grid) dan `HOME - KASIR PAGE TIPE 2.png` (List).
class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> with SingleTickerProviderStateMixin {
  int _currentTabIndex = 0;
  bool _isQuickManagementOpen = false;
  final TextEditingController _searchController = TextEditingController();

  late final AnimationController _morphController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _notchMorphAnimation;

  @override
  void initState() {
    super.initState();
    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
      reverseDuration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _morphController,
        curve: const Cubic(0.2, 0.9, 0.3, 1.05), // Smooth organic pop-in
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _morphController,
        curve: const Interval(0.0, 0.70, curve: Curves.easeOut),
        reverseCurve: const Interval(0.30, 1.0, curve: Curves.easeIn),
      ),
    );

    _notchMorphAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _morphController,
        curve: Curves.easeInOutCubicEmphasized,
        reverseCurve: Curves.easeInOutCubic,
      ),
    );

    _morphController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        if (mounted) {
          setState(() {
            _isQuickManagementOpen = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _morphController.dispose();
    super.dispose();
  }

  void _openQuickManagementSheet() {
    setState(() {
      _isQuickManagementOpen = true;
    });
    _morphController.forward(from: 0.0);
  }

  void _closeQuickManagementSheet() {
    _morphController.reverse();
  }

  void _navigateToCheckout() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          appBar: _currentTabIndex == 0
              ? PosAppBar(
                  searchController: _searchController,
                  onSearchChanged: (val) {
                    ref.read(searchQueryProvider.notifier).state = val;
                  },
                  cartItemCount: cartState.totalQuantity,
                  onCartPressed: () {
                    if (cartState.isNotEmpty) {
                      _navigateToCheckout();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Keranjang masih kosong. Pilih menu terlebih dahulu!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                )
              : null,
          body: Stack(
            children: [
              // Konten Berdasarkan Tab Terpilih (Terisolasi dari animasi agar smooth 120fps)
              IndexedStack(
                index: _currentTabIndex,
                children: [
                  // Tab 0: Katalog Menu Kasir (Mirror HOME - KASIR PAGE TIPE 1 & 2)
                  _buildKasirCatalogView(),

                  // Tab 1: Manajemen Master Produk & Kategori
                  const ProductManagementScreen(),

                  // Tab 2: Riwayat Transaksi Pesanan
                  const TransactionHistoryScreen(),

                  // Tab 3: Laporan & Statistik Penjualan
                  const SalesReportScreen(),
                ],
              ),

              // Floating Cart Summary Bar (Muncul di Tab Kasir jika Keranjang Terisi)
              if (_currentTabIndex == 0 && cartState.isNotEmpty)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 6.0, // Melayang rapat persis di atas navbar sesuai KERANJANG PRIVEW 1 & 2
                  child: BottomCartSheet(
                    cartState: cartState,
                    onIncrement: (productId) {
                      final item = cartState.items.firstWhere((i) => i.product.id == productId);
                      ref.read(cartProvider.notifier).addItem(item.product);
                    },
                    onDecrement: (productId) {
                      ref.read(cartProvider.notifier).decrementItem(productId);
                    },
                    onRemove: (productId) {
                      ref.read(cartProvider.notifier).removeItem(productId);
                    },
                    onClearCart: () {
                      ref.read(cartProvider.notifier).clearCart();
                    },
                    onOrderTypeChanged: (type) {
                      ref.read(cartProvider.notifier).setOrderType(type);
                    },
                    onCheckout: _navigateToCheckout,
                  ),
                ),
            ],
          ),
          bottomNavigationBar: AnimatedBuilder(
            animation: _notchMorphAnimation,
            builder: (context, _) {
              return CustomBottomNavBar(
                selectedIndex: _currentTabIndex,
                morphProgress: _notchMorphAnimation.value,
                isCloseState: _notchMorphAnimation.value > 0.5,
                onItemSelected: (index) {
                  if (_isQuickManagementOpen) _closeQuickManagementSheet();
                  setState(() {
                    _currentTabIndex = index;
                  });
                },
                onFabPressed: () {
                  if (_isQuickManagementOpen) {
                    _closeQuickManagementSheet();
                  } else {
                    _openQuickManagementSheet();
                  }
                },
              );
            },
          ),
        ),

        // Backdrop Redup Fullscreen & Modal Morphing (Menutupi seluruh layar 100% tanpa terpotong navbar)
        if (_isQuickManagementOpen) ...[
          // 1. Backdrop Gelap Full Screen (Full Viewport Dimming)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, _) {
                return GestureDetector(
                  onTap: _closeQuickManagementSheet,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    color: Colors.black.withValues(
                      alpha: (0.45 * _fadeAnimation.value).clamp(0.0, 1.0),
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. Modal Kelola Sistem Sejajar Sempurna di Atas Navbar:
          // Diletakkan sedikit lebih ke bawah agar jarak/gap dengan navbar semakin rapat dan presisi
          // Diisolasi dengan RepaintBoundary & AnimatedBuilder khusus agar animasi buttery smooth
          Positioned(
            left: 16.0,
            right: 16.0,
            bottom: 58.0, // Diturunkan sedikit ke bawah agar pas menempel rapat dengan lekukan navbar
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _morphController,
                builder: (context, _) {
                  return Transform.scale(
                    scale: _scaleAnimation.value.clamp(0.0, 1.0),
                    alignment: const Alignment(0.0, 0.98), // Origin ekspansi persis dari tombol (+)
                    child: Opacity(
                      opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                      child: Material(
                        type: MaterialType.transparency,
                        child: QuickManagementModal(
                        onClose: _closeQuickManagementSheet,
                        onNavigateToProductCrud: () {
                          _closeQuickManagementSheet();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ProductManagementScreen()),
                          );
                        },
                        onNavigateToCategoryCrud: () {
                          _closeQuickManagementSheet();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CategoryManagementScreen()),
                          );
                        },
                        onAddNewProduct: () {
                          _closeQuickManagementSheet();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ProductManagementScreen()),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        ],
      ],
    );
  }

  Widget _buildKasirCatalogView() {
    final categoriesAsync = ref.watch(categoriesListProvider);
    final productsAsync = ref.watch(productsListProvider);
    final selectedCategory = ref.watch(selectedCategoryIdProvider);
    final isCompact = ref.watch(isGridCompactProvider);
    final cartState = ref.watch(cartProvider);

    return Column(
      children: [
        // Sub-Header Category Filter Bar & Toggle Tipe 1 (Grid) / Tipe 2 (List)
        categoriesAsync.when(
          data: (categories) => CategoryFilterBar(
            categories: categories,
            selectedCategoryId: selectedCategory,
            isGridCompact: isCompact,
            onToggleGridLayout: () {
              ref.read(isGridCompactProvider.notifier).state = !isCompact;
            },
            onCategorySelected: (catId) {
              ref.read(selectedCategoryIdProvider.notifier).state = catId;
            },
          ),
          loading: () => const LinearProgressIndicator(
            color: AppColors.primary,
            backgroundColor: Color(0xFFD6D1CB),
            minHeight: 3.0,
          ),
          error: (err, stack) => const SizedBox.shrink(),
        ),

        // Judul Bagian / Kategori Terpilih
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: categoriesAsync.maybeWhen(
                  data: (cats) {
                    if (selectedCategory != null) {
                      final matched = cats.where((c) => c.id == selectedCategory).firstOrNull;
                      if (matched != null) {
                        return Text(
                          matched.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.noir,
                          ),
                        );
                      }
                    }
                    return const Text(
                      'Daftar Menu',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.noir,
                      ),
                    );
                  },
                  orElse: () => const Text(
                    'Daftar Menu',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.noir,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              productsAsync.maybeWhen(
                data: (prods) => Text(
                  '${prods.length} produk',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
        ),

        // Katalog Produk Bakery: Tipe 1 (Grid) atau Tipe 2 (List)
        Expanded(
          child: productsAsync.when(
            data: (products) {
              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_outlined,
                        size: 56.0,
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 8.0),
                      const Text(
                        'Tidak ada produk ditemukan.',
                        style: TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final bottomScrollPadding = cartState.isNotEmpty ? 160.0 : 96.0;

              // Tipe 2: 1-Kolom List View (HOME - KASIR PAGE TIPE 2.png / CARD 2.png)
              if (!isCompact) {
                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    bottomScrollPadding,
                  ),
                  itemCount: products.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10.0),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final cartItem = cartState.items.where((i) => i.product.id == product.id);
                    final quantityInCart = cartItem.isNotEmpty ? cartItem.first.quantity : 0;

                    return ProductGridCard(
                      product: product,
                      quantityInCart: quantityInCart,
                      isCompact: false,
                      onTap: () {
                        ref.read(cartProvider.notifier).addItem(product);
                      },
                    );
                  },
                );
              }

              // Tipe 1: Grid View (HOME - KASIR PAGE TIPE 1.png / CARD 1.png)
              return GridView.builder(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.xs,
                  AppSpacing.sm,
                  bottomScrollPadding,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.58,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final cartItem = cartState.items.where((i) => i.product.id == product.id);
                  final quantityInCart = cartItem.isNotEmpty ? cartItem.first.quantity : 0;

                  return ProductGridCard(
                    product: product,
                    quantityInCart: quantityInCart,
                    isCompact: true,
                    onTap: () {
                      ref.read(cartProvider.notifier).addItem(product);
                    },
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (err, _) => Center(
              child: Text(
                'Terjadi kesalahan memuat menu: $err',
                style: const TextStyle(color: AppColors.danger),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
