import 'package:go_router/go_router.dart';
import '../features/category_crud/presentation/screens/category_management_screen.dart';
import '../features/history/presentation/screens/transaction_history_screen.dart';
import '../features/pos/presentation/screens/checkout_screen.dart';
import '../features/pos/presentation/screens/pos_screen.dart';
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
      path: '/pos',
      builder: (context, state) => const PosScreen(),
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductManagementScreen(),
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
      path: '/history',
      builder: (context, state) => const TransactionHistoryScreen(),
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const SalesReportScreen(),
    ),
  ],
);
