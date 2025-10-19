part of 'products_bloc.dart';

abstract class ProductsEvent extends Equatable {
  const ProductsEvent();
  @override
  List<Object?> get props => [];
}

class ProductsStarted extends ProductsEvent {}

class ProductCreated extends ProductsEvent {
  final String code;
  final String name;
  final String? description;
  final String category;
  final double price;
  const ProductCreated({
    required this.code,
    required this.name,
    this.description,
    required this.category,
    this.price = 0,
  });
  @override
  List<Object?> get props => [code, name, description, category, price];
}
