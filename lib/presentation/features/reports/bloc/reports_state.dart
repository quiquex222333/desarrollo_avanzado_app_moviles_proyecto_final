part of 'reports_bloc.dart';

enum ReportsStatus { initial, loading, success, failure }

class ReportsState extends Equatable {
  final ReportsStatus status;
  final List<Map<String, dynamic>> sales;
  final List<Map<String, dynamic>> purchases;

  const ReportsState({
    required this.status,
    required this.sales,
    required this.purchases,
  });

  factory ReportsState.initial() =>
      const ReportsState(status: ReportsStatus.initial, sales: [], purchases: []);

  ReportsState copyWith({
    ReportsStatus? status,
    List<Map<String, dynamic>>? sales,
    List<Map<String, dynamic>>? purchases,
  }) =>
      ReportsState(
        status: status ?? this.status,
        sales: sales ?? this.sales,
        purchases: purchases ?? this.purchases,
      );

  @override
  List<Object?> get props => [status, sales, purchases];
}
