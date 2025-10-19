part of 'products_bloc.dart';

enum Status { initial, loading, success, failure }

class ProductsState extends Equatable {
  final Status status;
  final List<Product> items;

  const ProductsState({required this.status, required this.items});
  factory ProductsState.initial() =>
      const ProductsState(status: Status.initial, items: []);

  ProductsState copyWith({Status? status, List<Product>? items}) =>
      ProductsState(status: status ?? this.status, items: items ?? this.items);

  @override
  List<Object?> get props => [status, items];
}
