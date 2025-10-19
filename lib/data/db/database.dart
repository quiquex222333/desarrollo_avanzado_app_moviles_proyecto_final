import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:inventario_offline_first/data/db/daos/products_dao.dart';
import 'package:inventario_offline_first/data/db/daos/stock_dao.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'tables.dart';
part 'database.g.dart';

@DriftDatabase(
  tables: [
    Products, Stores, Warehouses, Suppliers, Stock,
  ],
  daos: [
    ProductsDao, StockDao, //StoresDao, WarehousesDao, SuppliersDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Migraciones si subimos schemaVersion
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        onUpgrade: (m, from, to) async {},
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'inventario.db'));
    // drift_sqflite usa sqflite debajo (Android/iOS/web soportado)
    return SqfliteQueryExecutor(path: file.path, singleInstance: true);
  });
}

Future<void> deleteLocalDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  final dbFile = File(p.join(dir.path, 'inventario.db'));
  if (await dbFile.exists()) {
    await dbFile.delete();
    print('🗑️ Base de datos local eliminada.');
  } else {
    print('⚠️ No se encontró la base local.');
  }
}
