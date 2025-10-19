import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';

class PurchasesRepository {
  final AppDatabase db;
  PurchasesRepository(this.db);

  Stream<List<Map<String, dynamic>>> watchAll() =>
      db.purchasesDao.watchAllPurchases();

  Future<void> insertPurchase({
    required String? supplierId,
    required List<Map<String, dynamic>> items,
    required double total,
  }) async {
    final uuid = const Uuid().v4(); // 👈 Generamos manualmente el ID

    final purchase = PurchasesCompanion.insert(
      id: Value(uuid), // 👈 Asignamos ID manualmente
      supplierId: Value(supplierId),
      total: Value(total),
    );

    final purchaseItems = items.map((i) {
      return PurchaseItemsCompanion.insert(
        purchaseId: uuid, // 👈 usamos el mismo ID aquí (usar String, no Value)
        productId: i['productId'],
        quantity: i['quantity'] as double,
        price: Value(i['price'] as double),
      );
    }).toList();

    await db.purchasesDao.insertPurchaseWithItems(
      purchase: purchase,
      items: purchaseItems,
    );
  }
}
