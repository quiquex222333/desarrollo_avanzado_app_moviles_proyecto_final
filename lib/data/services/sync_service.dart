import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../db/database.dart';

class SyncService {
  final AppDatabase db;
  final SupabaseClient supabase;

  SyncService(this.db, this.supabase);

  Future<void> syncAll() async {
    final pending = await db.select(db.syncQueue).get();
    for (final op in pending) {
      try {
        switch (op.tablename) {
          case 'products':
            await _syncProducts(op);
            break;
          case 'sales':
            await _syncSales(op);
            break;
          case 'purchases':
            await _syncPurchases(op);
            break;
          case 'stock':
            await _syncStock(op);
            break;
        }
        await (db.delete(db.syncQueue)..where((tbl) => tbl.id.equals(op.id)))
            .go();
      } catch (e) {
        print('❌ Error al sincronizar ${op.tablename}: $e');
      }
    }
  }

  Future<void> _syncProducts(SyncQueueData op) async {
    final record = await (db.select(db.products)
          ..where((t) => t.id.equals(op.recordId)))
        .getSingleOrNull();
    if (record == null) return;

    final data = {
      'id': record.id,
      'code': record.code,
      'name': record.name,
      'category': record.category,
      'unit_price': record.price,
      'updated_at': record.updatedAt.toIso8601String(),
    };

    await supabase.from('products').upsert(data);
    await (db.update(db.products)..where((t) => t.id.equals(record.id)))
        .write(const ProductsCompanion(isSynced: Value(true)));
  }

  Future<void> _syncSales(SyncQueueData op) async {
    // Similar a _syncProducts
  }

  Future<void> _syncPurchases(SyncQueueData op) async {
    // Similar a _syncProducts
  }

  Future<void> _syncStock(SyncQueueData op) async {
    // Similar a _syncProducts
  }

  void initRealtime() {
    supabase
        .channel('products')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'products',
          callback: (payload) async {
            final data = payload.newRecord;
            await db.into(db.products).insertOnConflictUpdate(
                  ProductsCompanion(
                    id: Value(data['id'] as String),
                    name: Value(data['name'] as String),
                    category: Value(data['category'] as String),
                    price: Value((data['price'] as num).toDouble()),
                    isSynced: const Value(true),
                    updatedAt: Value(DateTime.parse(data['updated_at'])),
                  ),
                );
          },
        )
        .subscribe();
  }
}
