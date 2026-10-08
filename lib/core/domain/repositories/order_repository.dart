import '../entities/order_entity.dart';

/// Kontrak repositori order / transaksi kasir.
abstract interface class OrderRepository {
  /// Mengambil semua transaksi, terurut terbaru lebih dahulu.
  Future<List<OrderEntity>> getOrders();

  /// Mengambil order berdasarkan ID beserta item-itemnya.
  Future<OrderEntity?> getOrderById(String id);

  /// Menyimpan transaksi baru secara atomik (Order + OrderItems + potong stok).
  Future<void> createOrder(OrderEntity order);

  /// Memperbarui status pesanan (misal: 'completed', 'cancelled').
  Future<void> updateOrderStatus(String id, String status);

  /// Menghapus transaksi (untuk testing/manajemen kasir).
  Future<void> deleteOrder(String id);

  /// Mengambil ringkasan statistik penjualan (Total Omzet, Total Transaksi, Rata-rata Nilai Order).
  Future<Map<String, dynamic>> getSalesSummary();
}
