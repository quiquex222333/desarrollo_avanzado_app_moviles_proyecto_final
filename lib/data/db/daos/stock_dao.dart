import 'package:drift/drift.dart';
import 'package:inventario_offline_first/data/db/tables.dart';
import '../database.dart';

part 'stock_dao.g.dart';

@DriftAccessor(tables: [Stock, Products, Stores, Warehouses])
class StockDao extends DatabaseAccessor<AppDatabase> with _$StockDaoMixin {
  StockDao(AppDatabase db) : super(db);

  Future<List<StockData>> getAll() =>
      select(db.stock).get().then((rows) => rows.cast<StockData>());

  /// Devuelve todo el stock con el nombre del producto
  Stream<List<Map<String, dynamic>>> watchFullStock() {
    final query = select(stock).join([
      leftOuterJoin(products, products.id.equalsExp(stock.productId)),
    ]);

    return query.watch().map((rows) => rows.map((row) {
          final s = row.readTable(stock);
          final p = row.readTable(products);
          return {
            'id': s.id,
            'productId': s.productId,
            'product': p.name,
            'quantity': s.quantity,
            'storeId': s.storeId,
            'warehouseId': s.warehouseId,
          };
        }).toList());
  }

  Future<void> updateQuantity(String id, double qty) async {
    await (update(stock)..where((t) => t.id.equals(id)))
        .write(StockCompanion(quantity: Value(qty)));
  }

  Future<void> addOrUpdateStock({
    required String productId,
    String? storeId,
    String? warehouseId,
    required double qty,
  }) async {
    print('INSERTANDO: productId=$productId | qty=$qty');

    await transaction(() async {
      final query = select(stock)
        ..where((tbl) {
          final productMatch = tbl.productId.equals(productId);
          final storeMatch = storeId != null
              ? tbl.storeId.equals(storeId)
              : const Constant(false);
          final warehouseMatch = warehouseId != null
              ? tbl.warehouseId.equals(warehouseId)
              : const Constant(false);
          return productMatch & (storeMatch | warehouseMatch);
        });

      final existing = await query.getSingleOrNull();

      if (existing == null) {
        await into(stock).insert(StockCompanion.insert(
          productId: productId,
          storeId: Value(storeId),
          warehouseId: Value(warehouseId),
          quantity: Value(qty),
        ));
      } else {
        await (update(stock)..where((tbl) => tbl.id.equals(existing.id)))
            .write(StockCompanion(
          quantity: Value(existing.quantity + qty),
          updatedAt: Value(DateTime.now()),
        ));
      }
    });
  }
}
