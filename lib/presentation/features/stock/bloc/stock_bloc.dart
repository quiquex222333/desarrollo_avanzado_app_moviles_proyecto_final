import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../data/repositories/stock_repository.dart';

part 'stock_event.dart';
part 'stock_state.dart';

class StockBloc extends Bloc<StockEvent, StockState> {
  final StockRepository repo;

  StockBloc(this.repo) : super(StockState.initial()) {
    on<StockStarted>((event, emit) async {
      await emit.forEach<List<Map<String, dynamic>>>(
        repo.watchAll(),
        onData: (data) => state.copyWith(status: Status.success, items: data),
        onError: (_, __) => state.copyWith(status: Status.failure),
      );
    });

    on<StockQuantityUpdated>((event, emit) async {
      await repo.updateQuantity(event.id, event.newQty);
    });

    on<StockAdded>((event, emit) async {

      print('EVENTO StockAdded -> ${event.productId} : ${event.qty}');
      await repo.addOrUpdateStock(
        productId: event.productId,
        qty: event.qty,
      );
    });
  }
}
