import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../data/repositories/purchases_repository.dart';

part 'purchases_event.dart';
part 'purchases_state.dart';

class PurchasesBloc extends Bloc<PurchasesEvent, PurchasesState> {
  final PurchasesRepository repo;
  PurchasesBloc(this.repo) : super(PurchasesState.initial()) {
    on<PurchasesStarted>((event, emit) async {
      await emit.forEach<List<Map<String, dynamic>>>(
        repo.watchAll(),
        onData: (data) =>
            state.copyWith(status: PurchasesStatus.success, purchases: data),
        onError: (_, __) => state.copyWith(status: PurchasesStatus.failure),
      );
    });

    on<PurchaseCreated>((event, emit) async {
      await repo.insertPurchase(
        supplierId: event.supplierId,
        items: event.items,
        total: event.total,
      );
    });
  }
}
