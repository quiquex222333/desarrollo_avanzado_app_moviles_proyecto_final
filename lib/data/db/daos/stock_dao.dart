import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'stock_dao.g.dart';

@DriftAccessor(tables: [Stock, Products, Stores, Warehouses])
class StockDao extends DatabaseAccessor<AppDatabase> with _$StockDaoMixin {
  StockDao(AppDatabase db) : super(db);

  Future<double> getQuantityByStore(String productId, String storeId) async {
    final q = await (select(db.stock)
          ..where(
              (s) => s.productId.equals(productId) & s.storeId.equals(storeId)))
        .getSingleOrNull();
    return q?.quantity ?? 0;
  }

  Future<void> addToStore(String productId, String storeId, double qty) async {
    await transaction(() async {
      final current = await (select(db.stock)
            ..where((s) =>
                s.productId.equals(productId) & s.storeId.equals(storeId)))
          .getSingleOrNull();

      if (current == null) {
        await into(db.stock).insert(StockCompanion.insert(
          productId: productId,
          storeId: Value(storeId),
          quantity: Value(qty),
        ));
      } else {
        await (update(db.stock)..where((s) => s.id.equals(current.id)))
            .write(StockCompanion(quantity: Value(current.quantity + qty)));
      }
    });
  }
}
