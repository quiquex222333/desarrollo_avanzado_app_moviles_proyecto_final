import '../db/database.dart';

class ReportsRepository {
  final AppDatabase db;
  ReportsRepository(this.db);

  Future<Map<String, List<Map<String, dynamic>>>> getReports(
      DateTime from, DateTime to) async {
    final sales = await db.reportsDao.getSalesByDate(from: from, to: to);
    final purchases = await db.reportsDao.getPurchasesByDate(from: from, to: to);
    return {'sales': sales, 'purchases': purchases};
  }
}
