import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

class Products extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get code => text().withLength(min: 1, max: 50)();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text()(); // (dentro de products)
  TextColumn get unit => text().withDefault(const Constant('unit'))();
  RealColumn get price => real().withDefault(const Constant(0))();
  TextColumn get imageUrl => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

class Stores extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get name => text()();
  TextColumn get location => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

class Warehouses extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get name => text()();
  TextColumn get location => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

class Suppliers extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

/// stock por ubicación (store o warehouse) usando columnas separadas
class Stock extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get storeId => text().nullable().references(Stores, #id)();
  TextColumn get warehouseId => text().nullable().references(Warehouses, #id)();
  RealColumn get quantity => real().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Purchases extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get supplierId => text().nullable()(); // FK hacia Suppliers
  TextColumn get destinationStoreId => text().nullable()(); // tienda
  TextColumn get destinationWarehouseId => text().nullable()(); // almacén
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  RealColumn get total => real().withDefault(const Constant(0))();
  TextColumn get createdBy => text().nullable()(); // empleado o usuario
  @override
  Set<Column> get primaryKey => {id};
}

class PurchaseItems extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get purchaseId => text().references(Purchases, #id)();
  TextColumn get productId => text().references(Products, #id)();
  RealColumn get quantity => real()();
  RealColumn get price => real().withDefault(const Constant(0))();
  @override
  Set<Column> get primaryKey => {id};
}

class Sales extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get customerName => text().nullable()(); // opcional
  TextColumn get storeId => text().nullable()(); // tienda que realizó la venta
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  RealColumn get total => real().withDefault(const Constant(0))();
  TextColumn get createdBy => text().nullable()(); // empleado
  @override
  Set<Column> get primaryKey => {id};
}

class SaleItems extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get saleId => text().references(Sales, #id)();
  TextColumn get productId => text().references(Products, #id)();
  RealColumn get quantity => real()();
  RealColumn get price => real().withDefault(const Constant(0))();
  @override
  Set<Column> get primaryKey => {id};
}
