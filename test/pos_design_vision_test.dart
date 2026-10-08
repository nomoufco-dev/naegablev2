import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_naegable/core/constants/app_assets.dart';
import 'package:pos_naegable/core/constants/app_colors.dart';
import 'package:pos_naegable/core/domain/entities/product_entity.dart';
import 'package:pos_naegable/core/widgets/custom_bottom_nav_bar.dart';
import 'package:pos_naegable/features/pos/presentation/widgets/pos_app_bar.dart';
import 'package:pos_naegable/features/pos/presentation/widgets/product_grid_card.dart';
import 'package:pos_naegable/features/pos/presentation/widgets/quick_management_modal.dart';
import 'package:pos_naegable/features/splash/presentation/screens/splash_screen.dart';

void main() {
  group('POS Naegable Vision UI Mirroring Unit Tests', () {
    testWidgets('1. SplashScreen uses LOGO 1 and Grey Brown background', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColors.primary);

      // Verifikasi Image.asset dengan aset LOGO 1.png
      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);
      final imageWidget = tester.widget<Image>(imageFinder);
      expect((imageWidget.image as AssetImage).assetName, AppAssets.logo1);
    });

    testWidgets('2. PosAppBar has centered Kasir title, white search pill, and blush cart icon', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: PosAppBar(
              searchController: controller,
              onSearchChanged: (_) {},
              cartItemCount: 2,
              onCartPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Kasir'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('3. ProductGridCard renders CARD 1 (Grid) and CARD 2 (List) with add to chart button', (
      WidgetTester tester,
    ) async {
      const testProduct = ProductEntity(
        id: 'p-dubai',
        storeId: 'store-1',
        name: 'Dubai Chewy Cookie',
        price: 28000.0,
        currentStock: 100,
        trackStock: true,
      );

      // Test CARD 1 (Vertical Grid)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductGridCard(
              product: testProduct,
              quantityInCart: 0,
              isCompact: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Dubai Chewy Cookie'), findsOneWidget);
      expect(find.text('Stock: 100'), findsOneWidget);
      expect(find.text('Rp 28.000'), findsOneWidget);
      expect(find.text('add to chart'), findsOneWidget);

      // Test CARD 2 (Horizontal List)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductGridCard(
              product: testProduct,
              quantityInCart: 1,
              isCompact: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Dubai Chewy Cookie'), findsOneWidget);
      expect(find.text('Stock: 100'), findsOneWidget);
      expect(find.text('Rp 28.000'), findsOneWidget);
      expect(find.text('add to chart'), findsOneWidget);
    });

    testWidgets('4. CustomBottomNavBar renders notched pill dock and center FAB (+)', (
      WidgetTester tester,
    ) async {
      int tapped = -1;
      bool fabTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBar(
              selectedIndex: 0,
              onItemSelected: (i) => tapped = i,
              onFabPressed: () => fabTapped = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      await tester.tap(find.byIcon(Icons.add));
      expect(fabTapped, isTrue);

      await tester.tap(find.byIcon(Icons.layers_outlined));
      expect(tapped, 1);
    });

    testWidgets('5. QuickManagementModal renders Kelola Sistem and 4 CRUD pill options with close button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: QuickManagementModal(
                onNavigateToProductCrud: () {},
                onNavigateToCategoryCrud: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Kelola Sistem'), findsOneWidget);
      expect(find.text('Tambah'), findsOneWidget);
      expect(find.text('Detail'), findsOneWidget);
      expect(find.text('Kategori'), findsOneWidget);
      expect(find.text('Pengiriman'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });
}
