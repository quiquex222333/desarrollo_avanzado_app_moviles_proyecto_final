import '../db/database.dart';

class StockRepository {
  final AppDatabase db;
  StockRepository(this.db);

  Stream<List<Map<String, dynamic>>> watchAll() => db.stockDao.watchFullStock();

  Future<void> updateQuantity(String id, double qty) =>
      db.stockDao.updateQuantity(id, qty);

  Future<void> addOrUpdateStock({
  required String productId,
  String? storeId,
  String? warehouseId,
  required double qty,
}) =>
    db.stockDao.addOrUpdateStock(
      productId: productId,
      storeId: storeId,
      warehouseId: warehouseId,
      qty: qty,
    );
}
