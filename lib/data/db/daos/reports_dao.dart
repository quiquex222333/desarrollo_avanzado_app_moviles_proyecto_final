import 'package:drift/drift.dart';
import 'package:inventario_offline_first/data/db/tables.dart';
import '../database.dart';

part 'reports_dao.g.dart';

@DriftAccessor(tables: [Sales, Purchases])
class ReportsDao extends DatabaseAccessor<AppDatabase> with _$ReportsDaoMixin {
  ReportsDao(AppDatabase db) : super(db);

  // Totales agrupados por fecha
  Future<List<Map<String, dynamic>>> getSalesByDate({
    required DateTime from,
    required DateTime to,
  }) async {
    final query = await (select(sales)
          ..where((tbl) => tbl.date.isBiggerOrEqualValue(from))
          ..where((tbl) => tbl.date.isSmallerOrEqualValue(to)))
        .get();

    final Map<String, double> grouped = {};
    for (final s in query) {
      final dateKey = s.date.toIso8601String().split('T').first;
      grouped.update(dateKey, (v) => v + s.total, ifAbsent: () => s.total);
    }

    return grouped.entries
        .map((e) => {'date': e.key, 'total': e.value})
        .toList();
  }

  Future<List<Map<String, dynamic>>> getPurchasesByDate({
    required DateTime from,
    required DateTime to,
  }) async {
    final query = await (select(purchases)
          ..where((tbl) => tbl.date.isBiggerOrEqualValue(from))
          ..where((tbl) => tbl.date.isSmallerOrEqualValue(to)))
        .get();

    final Map<String, double> grouped = {};
    for (final p in query) {
      final dateKey = p.date.toIso8601String().split('T').first;
      grouped.update(dateKey, (v) => v + p.total, ifAbsent: () => p.total);
    }

    return grouped.entries
        .map((e) => {'date': e.key, 'total': e.value})
        .toList();
  }
}
