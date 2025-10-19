import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../db/database.dart';

class SalesRepository {
  final AppDatabase db;
  SalesRepository(this.db);

  Stream<List<Map<String, dynamic>>> watchAll() => db.salesDao.watchAllSales();

  Future<void> insertSale({
    required String? customerName,
    required List<Map<String, dynamic>> items,
    required double total,
  }) async {
    final uuid = const Uuid().v4();

    // build a plain map for the sale to avoid relying on generated Companion classes
    final sale = SalesCompanion.insert(
      id: Value(uuid),
      customerName: Value(customerName),
      total: Value(total),
    );

    // build a list of SaleItemsCompanion for sale items
    final saleItems = items.map((i) {
      return SaleItemsCompanion.insert(
        saleId: uuid,
        productId: i['productId'] as String,
        quantity: i['quantity'] as double,
        price: Value(i['price'] as double),
      );
    }).toList();

    await db.salesDao.insertSaleWithItems(
      sale: sale,
      items: saleItems,
    );
  }
}
