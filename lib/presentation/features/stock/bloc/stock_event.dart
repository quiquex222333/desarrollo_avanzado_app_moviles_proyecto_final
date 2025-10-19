part of 'stock_bloc.dart';

abstract class StockEvent extends Equatable {
  const StockEvent();
  @override
  List<Object?> get props => [];
}

class StockStarted extends StockEvent {}

class StockQuantityUpdated extends StockEvent {
  final String id;
  final double newQty;
  const StockQuantityUpdated(this.id, this.newQty);
  @override
  List<Object?> get props => [id, newQty];
}

class StockAdded extends StockEvent {
  final String productId;
  final double qty;
  const StockAdded(this.productId, this.qty);
  @override
  List<Object?> get props => [productId, qty];
}

