import 'package:drift/drift.dart';
import 'package:inventario_offline_first/data/db/tables.dart';
import '../database.dart';

part 'purchases_dao.g.dart';

@DriftAccessor(tables: [Purchases, PurchaseItems, Products])
class PurchasesDao extends DatabaseAccessor<AppDatabase> with _$PurchasesDaoMixin {
  PurchasesDao(AppDatabase db) : super(db);

  Future<void> insertPurchaseWithItems({
    required dynamic purchase,
    required List<dynamic> items,
  }) async {
    await transaction(() async {
      await into(db.purchases).insert(purchase);
      for (final item in items) {
        await into(db.purchaseItems).insert(item);

        // ✅ Actualiza stock automáticamente
        await db.stockDao.addOrUpdateStock(
          productId: item.productId.value,
          qty: item.quantity.value,
        );
      }
    });
  }

  Stream<List<Map<String, dynamic>>> watchAllPurchases() {
    final query = select(db.purchases)
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    return query.watch().map((rows) => rows.map((p) {
          return {
            'id': p.id,
            'supplierId': p.supplierId,
            'date': p.date,
            'total': p.total,
          };
        }).toList());
  }
}
