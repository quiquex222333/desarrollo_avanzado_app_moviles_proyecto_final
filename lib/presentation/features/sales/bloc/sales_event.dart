part of 'sales_bloc.dart';

abstract class SalesEvent extends Equatable {
  const SalesEvent();
  @override
  List<Object?> get props => [];
}

class SalesStarted extends SalesEvent {}

class SaleCreated extends SalesEvent {
  final String? customerName;
  final List<Map<String, dynamic>> items;
  final double total;
  const SaleCreated(this.customerName, this.items, this.total);
}
