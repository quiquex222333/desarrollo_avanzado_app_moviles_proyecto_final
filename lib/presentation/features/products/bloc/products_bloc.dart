import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../data/db/database.dart';
import '../../../../data/repositories/products_repository.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ProductsRepository repo;

  ProductsBloc(this.repo) : super(ProductsState.initial()) {
    on<ProductsStarted>((event, emit) async {
      await emit.forEach<List<Product>>(
        repo.watchAll(),
        onData: (data) => state.copyWith(status: Status.success, items: data),
        onError: (_, __) => state.copyWith(status: Status.failure),
      );
    });

    on<ProductCreated>((event, emit) async {
      await repo.create(
        code: event.code,
        name: event.name,
        description: event.description,
        category: event.category,
        price: event.price,
      );
    });
  }
}
