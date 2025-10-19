part of 'sales_bloc.dart';

enum SalesStatus { initial, loading, success, failure }

class SalesState extends Equatable {
  final SalesStatus status;
  final List<Map<String, dynamic>> sales;
  const SalesState({required this.status, required this.sales});

  factory SalesState.initial() =>
      const SalesState(status: SalesStatus.initial, sales: []);

  SalesState copyWith({
    SalesStatus? status,
    List<Map<String, dynamic>>? sales,
  }) =>
      SalesState(status: status ?? this.status, sales: sales ?? this.sales);

  @override
  List<Object?> get props => [status, sales];
}
