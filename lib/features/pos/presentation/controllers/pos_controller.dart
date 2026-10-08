import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/domain/entities/category_entity.dart';
import '../../../../core/domain/entities/delivery_settings_entity.dart';
import '../../../../core/domain/entities/order_entity.dart';
import '../../../../core/domain/entities/product_entity.dart';

// Filter state
final selectedCategoryIdProvider = StateProvider<String?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');
final isGridCompactProvider = StateProvider<bool>((ref) => true); // true = 3-kolom Grid, false = List

// Category list provider
final categoriesListProvider = FutureProvider<List<CategoryEntity>>((ref) async {
  final categoryRepo = ref.watch(categoryRepositoryProvider);
  return categoryRepo.getCategories();
});

// Products list provider (filtered by selected category and search query)
final productsListProvider = FutureProvider<List<ProductEntity>>((ref) async {
  final productRepo = ref.watch(productRepositoryProvider);
  final selectedCategory = ref.watch(selectedCategoryIdProvider);
  final query = ref.watch(searchQueryProvider);

  return productRepo.getProducts(
    categoryId: selectedCategory,
    searchQuery: query.trim().isEmpty ? null : query.trim(),
  );
});

// Delivery settings notifier
class DeliverySettingsNotifier extends StateNotifier<AsyncValue<DeliverySettingsEntity>> {
  DeliverySettingsNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadSettings();
  }

  final Ref _ref;

  Future<void> loadSettings() async {
    try {
      final repo = _ref.read(deliverySettingsRepositoryProvider);
      final settings = await repo.getSettings();
      state = AsyncValue.data(settings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleDelivery() async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(isDeliveryEnabled: !current.isDeliveryEnabled);
    state = AsyncValue.data(updated);

    final repo = _ref.read(deliverySettingsRepositoryProvider);
    await repo.toggleDeliveryStatus(updated.isDeliveryEnabled);
  }

  Future<void> updateFee(double newFee) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(deliveryFeeBase: newFee);
    state = AsyncValue.data(updated);

    final repo = _ref.read(deliverySettingsRepositoryProvider);
    await repo.updateSettings(updated);
  }
}

final deliverySettingsControllerProvider =
    StateNotifierProvider<DeliverySettingsNotifier, AsyncValue<DeliverySettingsEntity>>((ref) {
  return DeliverySettingsNotifier(ref);
});

// Orders list provider for Transaction History
final ordersListProvider = FutureProvider<List<OrderEntity>>((ref) async {
  final orderRepo = ref.watch(orderRepositoryProvider);
  return orderRepo.getOrders();
});
