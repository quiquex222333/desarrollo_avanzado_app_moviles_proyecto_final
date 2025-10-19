part of 'stock_bloc.dart';

enum Status { initial, loading, success, failure }

class StockState extends Equatable {
  final Status status;
  final List<Map<String, dynamic>> items;
  const StockState({required this.status, required this.items});

  factory StockState.initial() =>
      const StockState(status: Status.initial, items: []);

  StockState copyWith({
    Status? status,
    List<Map<String, dynamic>>? items,
  }) =>
      StockState(status: status ?? this.status, items: items ?? this.items);

  @override
  List<Object?> get props => [status, items];
}
