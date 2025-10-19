import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../data/repositories/sales_repository.dart';

part 'sales_event.dart';
part 'sales_state.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final SalesRepository repo;
  SalesBloc(this.repo) : super(SalesState.initial()) {
    on<SalesStarted>((event, emit) async {
      await emit.forEach<List<Map<String, dynamic>>>(
        repo.watchAll(),
        onData: (data) =>
            state.copyWith(status: SalesStatus.success, sales: data),
      );
    });

    on<SaleCreated>((event, emit) async {
      await repo.insertSale(
        customerName: event.customerName,
        items: event.items,
        total: event.total,
      );
    });
  }
}
