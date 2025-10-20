import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:inventario_offline_first/utils/pdf_report_generator.dart';
import 'package:printing/printing.dart';
import '../../../../data/repositories/reports_repository.dart';
import '../../../../data/db/database.dart';
import '../bloc/reports_bloc.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) =>
          ReportsRepository(RepositoryProvider.of<AppDatabase>(context)),
      child: BlocProvider(
        create: (ctx) => ReportsBloc(ctx.read<ReportsRepository>()),
        child: const _ReportsView(),
      ),
    );
  }
}

class _ReportsView extends StatefulWidget {
  const _ReportsView();

  @override
  State<_ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<_ReportsView> {
  DateTime from = DateTime.now().subtract(const Duration(days: 7));
  DateTime to = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<ReportsBloc>().add(ReportsRequested(from, to));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Exportar a PDF',
            onPressed: () async {
              final bloc = context.read<ReportsBloc>();
              final state = bloc.state;

              if (state.status == ReportsStatus.success) {
                final pdfData = await PDFReportGenerator.generate(
                  from: from,
                  to: to,
                  sales: state.sales,
                  purchases: state.purchases,
                );
                await Printing.layoutPdf(
                  onLayout: (format) async => pdfData,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Primero carga los reportes.')),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<ReportsBloc, ReportsState>(
          builder: (context, state) {
            if (state.status == ReportsStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == ReportsStatus.failure) {
              return const Center(child: Text('Error al cargar reportes'));
            }

            final salesData = state.sales;
            final purchasesData = state.purchases;

            // 👉 Totales
            final totalSales = salesData.fold<double>(
                0, (sum, e) => sum + (e['total'] as double));
            final totalPurchases = purchasesData.fold<double>(
                0, (sum, e) => sum + (e['total'] as double));
            final balance = totalSales - totalPurchases;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🗓️ Filtros de fecha
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: from,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) setState(() => from = picked);
                        },
                        child:
                            Text('Desde: ${from.toString().split(" ").first}'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: to,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) setState(() => to = picked);
                        },
                        child: Text('Hasta: ${to.toString().split(" ").first}'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        context
                            .read<ReportsBloc>()
                            .add(ReportsRequested(from, to));
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 📊 Gráfico
                Expanded(
                  flex: 3,
                  child: LineChart(
                    LineChartData(
                      titlesData: FlTitlesData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: salesData.asMap().entries.map((e) {
                            return FlSpot(
                                e.key.toDouble(), (e.value['total'] as double));
                          }).toList(),
                          color: Colors.green,
                          isCurved: true,
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                        ),
                        LineChartBarData(
                          spots: purchasesData.asMap().entries.map((e) {
                            return FlSpot(
                                e.key.toDouble(), (e.value['total'] as double));
                          }).toList(),
                          color: Colors.blue,
                          isCurved: true,
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🧮 Resumen numérico
                Expanded(
                  flex: 1,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Ventas:',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Text('\$${totalSales.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      color: Colors.green, fontSize: 16)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Compras:',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Text('\$${totalPurchases.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      color: Colors.blue, fontSize: 16)),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Balance:',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                (balance >= 0 ? '+\$' : '-\$') +
                                    balance.abs().toStringAsFixed(2),
                                style: TextStyle(
                                  color: balance >= 0
                                      ? Colors.green[700]
                                      : Colors.red[700],
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
