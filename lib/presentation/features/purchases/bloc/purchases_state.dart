part of 'purchases_bloc.dart';

enum PurchasesStatus { initial, loading, success, failure }

class PurchasesState extends Equatable {
  final PurchasesStatus status;
  final List<Map<String, dynamic>> purchases;
  const PurchasesState({required this.status, required this.purchases});

  factory PurchasesState.initial() =>
      const PurchasesState(status: PurchasesStatus.initial, purchases: []);

  PurchasesState copyWith({
    PurchasesStatus? status,
    List<Map<String, dynamic>>? purchases,
  }) =>
      PurchasesState(
        status: status ?? this.status,
        purchases: purchases ?? this.purchases,
      );

  @override
  List<Object?> get props => [status, purchases];
}
