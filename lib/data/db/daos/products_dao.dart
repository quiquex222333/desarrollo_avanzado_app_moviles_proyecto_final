import 'package:drift/drift.dart';
import 'package:inventario_offline_first/data/db/tables.dart';
import '../database.dart';

part 'products_dao.g.dart';

@DriftAccessor(tables: [Products])
class ProductsDao extends DatabaseAccessor<AppDatabase>
    with _$ProductsDaoMixin {
  ProductsDao(AppDatabase db) : super(db);

  Future<List<Product>> getAll() =>
      select(db.products).get().then((rows) => rows.cast<Product>());
      
  Stream<List<Product>> watchAll() =>
      select(db.products).watch().map((rows) => rows.cast<Product>());

  Future<void> upsert(ProductsCompanion data) async {
    await into(db.products).insertOnConflictUpdate(data);
  }

  Future<void> remove(String id) =>
      (delete(db.products)..where((tbl) => tbl.id.equals(id))).go();
}
