import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PDFReportGenerator {
  static Future<Uint8List> generate({
    required DateTime from,
    required DateTime to,
    required List<Map<String, dynamic>> sales,
    required List<Map<String, dynamic>> purchases,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('yyyy-MM-dd');

    // Totales
    final totalSales = sales.fold<double>(0, (sum, e) => sum + (e['total'] as double));
    final totalPurchases =
        purchases.fold<double>(0, (sum, e) => sum + (e['total'] as double));
    final balance = totalSales - totalPurchases;

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Reporte de Ventas y Compras',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Text(
                  '${dateFormat.format(from)} → ${dateFormat.format(to)}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Totales generales:',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.TableHelper.fromTextArray(
            data: [
              ['Tipo', 'Total'],
              ['Ventas', '\$${totalSales.toStringAsFixed(2)}'],
              ['Compras', '\$${totalPurchases.toStringAsFixed(2)}'],
              ['Balance',
                  (balance >= 0 ? '+' : '-') + '\$${balance.abs().toStringAsFixed(2)}'],
            ],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerRight,
            },
          ),
          pw.SizedBox(height: 20),
          pw.Text('Resumen diario de Ventas:',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.TableHelper.fromTextArray(
            data: [
              ['Fecha', 'Total'],
              ...sales.map((e) => [e['date'], '\$${e['total'].toStringAsFixed(2)}'])
            ],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.green100),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerRight,
            },
          ),
          pw.SizedBox(height: 20),
          pw.Text('Resumen diario de Compras:',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.TableHelper.fromTextArray(
            data: [
              ['Fecha', 'Total'],
              ...purchases.map((e) => [e['date'], '\$${e['total'].toStringAsFixed(2)}'])
            ],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue100),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerRight,
            },
          ),
          pw.SizedBox(height: 20),
          pw.Footer(
            title: pw.Text('Generado automáticamente por el Sistema de Inventario Offline',
                style: const pw.TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );

    return pdf.save();
  }
}
