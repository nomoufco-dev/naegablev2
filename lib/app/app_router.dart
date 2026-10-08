import 'package:go_router/go_router.dart';
import '../core/domain/entities/order_entity.dart';

import '../features/auth/presentation/screens/login_screen.dart';
import '../features/category_crud/presentation/screens/category_management_screen.dart';
import '../features/history/presentation/screens/deleted_history_screen.dart';
import '../features/history/presentation/screens/transaction_history_screen.dart';
import '../features/management/presentation/screens/delivery_settings_screen.dart';
import '../features/management/presentation/screens/product_detail_management_screen.dart';
import '../features/orders/presentation/screens/order_list_screen.dart';
import '../features/payment/presentation/screens/order_success_screen.dart';
import '../features/payment/presentation/screens/payment_screen.dart';
import '../features/pos/presentation/screens/checkout_screen.dart';
import '../features/pos/presentation/screens/pos_screen.dart';
import '../features/product_crud/presentation/screens/product_form_screen.dart';
import '../features/product_crud/presentation/screens/product_management_screen.dart';
import '../features/reports/presentation/screens/sales_report_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';

/// Konfigurasi routing deklaratif aplikasi menggunakan GoRouter.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/pos',
      builder: (context, state) => const PosScreen(),
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductManagementScreen(),
    ),
    GoRoute(
      path: '/product-detail',
      builder: (context, state) => const ProductDetailManagementScreen(),
    ),
    GoRoute(
      path: '/product-form',
      builder: (context, state) => const ProductFormScreen(),
    ),
    GoRoute(
      path: '/categories',
      builder: (context, state) => const CategoryManagementScreen(),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/payment',
      builder: (context, state) {
        final extra = state.extra;
        if (extra is Map<String, dynamic>) {
          return PaymentScreen(
            totalAmount: extra['totalAmount'] as double?,
            initialCustomerName: extra['customerName'] as String?,
          );
        }
        return const PaymentScreen();
      },
    ),
    GoRoute(
      path: '/order-success',
      builder: (context, state) {
        final extra = state.extra;
        if (extra is OrderEntity) {
          return OrderSuccessScreen(order: extra);
        }
        return const OrderSuccessScreen();
      },
    ),
    GoRoute(
      path: '/orders',
      builder: (context, state) => const OrderListScreen(),
    ),
    GoRoute(
      path: '/delivery-settings',
      builder: (context, state) => const DeliverySettingsScreen(),
    ),
    GoRoute(
      path: '/deleted-orders',
      builder: (context, state) => const DeletedHistoryScreen(mode: DeletedHistoryMode.orders),
    ),
    GoRoute(
      path: '/deleted-transactions',
      builder: (context, state) => const DeletedHistoryScreen(mode: DeletedHistoryMode.transactions),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const TransactionHistoryScreen(),
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const SalesReportScreen(),
    ),
  ],
);
