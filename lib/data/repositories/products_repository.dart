import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../db/database.dart';

class ProductsRepository {
  final AppDatabase db;
  ProductsRepository(this.db);

  Stream<List<Product>> watchAll() => db.productsDao.watchAll();

  Future<void> create({
    required String code,
    required String name,
    String? description,
    required String category,
    String unit = 'unit',
    double price = 0,
    String? imageUrl,
  }) async {
    final id = const Uuid().v4();
    await db.productsDao.upsert(ProductsCompanion.insert(
      id: Value(id),
      code: code,
      name: name,
      description: Value(description),
      category: category,
      unit: Value(unit),
      price: Value(price),
      imageUrl: Value(imageUrl),
    ));
    await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
          tablename: 'products',
          operation: 'insert',
          recordId: id,
        ));
  }
}
