part of 'purchases_bloc.dart';

abstract class PurchasesEvent extends Equatable {
  const PurchasesEvent();
  @override
  List<Object?> get props => [];
}

class PurchasesStarted extends PurchasesEvent {}

class PurchaseCreated extends PurchasesEvent {
  final String? supplierId;
  final List<Map<String, dynamic>> items;
  final double total;
  const PurchaseCreated(this.supplierId, this.items, this.total);
}
