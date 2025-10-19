import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../data/repositories/reports_repository.dart';

part 'reports_event.dart';
part 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ReportsRepository repo;

  ReportsBloc(this.repo) : super(ReportsState.initial()) {
    on<ReportsRequested>((event, emit) async {
      emit(state.copyWith(status: ReportsStatus.loading));
      try {
        final data = await repo.getReports(event.from, event.to);
        emit(state.copyWith(
          status: ReportsStatus.success,
          sales: data['sales']!,
          purchases: data['purchases']!,
        ));
      } catch (_) {
        emit(state.copyWith(status: ReportsStatus.failure));
      }
    });
  }
}
