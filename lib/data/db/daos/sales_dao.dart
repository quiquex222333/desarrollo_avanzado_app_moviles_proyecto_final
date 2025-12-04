import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'sales_dao.g.dart';

@DriftAccessor(tables: [Sales, SaleItems, Products])
class SalesDao extends DatabaseAccessor<AppDatabase> with _$SalesDaoMixin {
  // ignore: use_super_parameters
  SalesDao(AppDatabase db) : super(db);

  Future<void> insertSaleWithItems({
    required SalesCompanion sale, // 👈 debe ser SalesCompanion, no Map
    required List<SaleItemsCompanion> items,
  }) async {
    await transaction(() async {
      await into(sales).insert(sale); // 👈 esto espera SalesCompanion
      for (final item in items) {
        await into(saleItems).insert(item);
        await db.stockDao.addOrUpdateStock(
          productId: item.productId.value,
          qty: -item.quantity.value,
        );
      }
    });
  }

  Stream<List<Map<String, dynamic>>> watchAllSales() {
    final query = select(sales)..orderBy([(t) => OrderingTerm.desc(t.date)]);
    return query.watch().map((rows) => rows.map((row) {
          final s = row; // ✅ row ya es una instancia de SalesData
          return {
            'id': s.id,
            'customer': s.customerName ?? 'Cliente desconocido',
            'date': s.date,
            'total': s.total,
          };
        }).toList());
  }
}
